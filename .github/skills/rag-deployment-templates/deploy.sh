#!/bin/bash

# deploy.sh - Deploy Azure infrastructure for RAG templates

set -euo pipefail

# Parse arguments
RESOURCE_GROUP=${1:-demo-rg}
REGION=${2:-eastus}

# Optional model overrides. If omitted, the script auto-detects compatible values by region.
CHAT_MODEL_NAME=${CHAT_MODEL_NAME:-}
CHAT_MODEL_VERSION=${CHAT_MODEL_VERSION:-}
CHAT_SKU_NAME=${CHAT_SKU_NAME:-}
CHAT_SKU_CAPACITY=${CHAT_SKU_CAPACITY:-10}

EMBED_MODEL_NAME=${EMBED_MODEL_NAME:-text-embedding-3-small}
EMBED_MODEL_VERSION=${EMBED_MODEL_VERSION:-}
EMBED_SKU_NAME=${EMBED_SKU_NAME:-}
EMBED_SKU_CAPACITY=${EMBED_SKU_CAPACITY:-50}

# Core infra defaults (can be overridden via env vars for different projects).
SEARCH_TIER=${SEARCH_TIER:-basic}
SEARCH_REPLICA_COUNT=${SEARCH_REPLICA_COUNT:-1}
SEARCH_PARTITION_COUNT=${SEARCH_PARTITION_COUNT:-1}
STORAGE_REDUNDANCY=${STORAGE_REDUNDANCY:-Standard_LRS}
LOG_RETENTION_DAYS=${LOG_RETENTION_DAYS:-30}
ENABLE_MANAGED_IDENTITY=${ENABLE_MANAGED_IDENTITY:-false}

resolve_chat_model() {
  local candidates="${CHAT_MODEL_CANDIDATES:-gpt-5.5,gpt-5.4-mini,gpt-5.4,gpt-5.1,gpt-4o}"
  IFS=',' read -r -a arr <<< "$candidates"

  for model in "${arr[@]}"; do
    local tuple
    tuple=$(az cognitiveservices model list -l "$REGION" \
      --query "[?model.name=='${model}' && model.capabilities.chatCompletion=='true' && model.lifecycleStatus!='Deprecating'] | [0].[model.name, model.version, model.skus[0].name, model.skus[0].capacity.minimum]" \
      -o tsv)
    if [[ -n "$tuple" ]]; then
      echo "$tuple"
      return 0
    fi
  done

  # Fallback: allow deprecating model if no non-deprecating chat model exists
  for model in "${arr[@]}"; do
    local tuple
    tuple=$(az cognitiveservices model list -l "$REGION" \
      --query "[?model.name=='${model}' && model.capabilities.chatCompletion=='true'] | [0].[model.name, model.version, model.skus[0].name, model.skus[0].capacity.minimum]" \
      -o tsv)
    if [[ -n "$tuple" ]]; then
      echo "$tuple"
      return 0
    fi
  done

  return 1
}

resolve_embedding_model() {
  az cognitiveservices model list -l "$REGION" \
    --query "[?model.name=='${EMBED_MODEL_NAME}' && model.lifecycleStatus!='Deprecating'] | [0].[model.name, model.version, model.skus[0].name, model.skus[0].capacity.minimum]" \
    -o tsv
}

max_int() {
  local a=${1:-0}
  local b=${2:-0}
  if [[ "$a" -ge "$b" ]]; then
    echo "$a"
  else
    echo "$b"
  fi
}

echo "Deploying Azure infrastructure..."
echo "Resource Group: $RESOURCE_GROUP"
echo "Region: $REGION"

echo "Validating Azure CLI session..."
az account show --query "{name:name,id:id}" -o table >/dev/null

# Auto-detect chat deployment parameters when not explicitly provided.
if [[ -z "$CHAT_MODEL_NAME" || -z "$CHAT_MODEL_VERSION" || -z "$CHAT_SKU_NAME" ]]; then
  chat_tuple=$(resolve_chat_model || true)
  if [[ -z "$chat_tuple" ]]; then
    echo "ERROR: Could not resolve a chat model for region '$REGION'."
    echo "Set CHAT_MODEL_NAME/CHAT_MODEL_VERSION/CHAT_SKU_NAME manually and retry."
    exit 1
  fi

  read -r detected_chat_name detected_chat_version detected_chat_sku detected_chat_min_capacity <<< "$chat_tuple"
  CHAT_MODEL_NAME=${CHAT_MODEL_NAME:-$detected_chat_name}
  CHAT_MODEL_VERSION=${CHAT_MODEL_VERSION:-$detected_chat_version}
  CHAT_SKU_NAME=${CHAT_SKU_NAME:-$detected_chat_sku}
  if [[ -n "${detected_chat_min_capacity:-}" ]]; then
    CHAT_SKU_CAPACITY=$(max_int "$CHAT_SKU_CAPACITY" "$detected_chat_min_capacity")
  fi
fi

# Auto-detect embedding deployment parameters when not explicitly provided.
if [[ -z "$EMBED_MODEL_VERSION" || -z "$EMBED_SKU_NAME" ]]; then
  embed_tuple=$(resolve_embedding_model || true)
  if [[ -z "$embed_tuple" ]]; then
    echo "ERROR: Could not resolve embedding model '${EMBED_MODEL_NAME}' for region '$REGION'."
    echo "Set EMBED_MODEL_NAME/EMBED_MODEL_VERSION/EMBED_SKU_NAME manually and retry."
    exit 1
  fi

  read -r detected_embed_name detected_embed_version detected_embed_sku detected_embed_min_capacity <<< "$embed_tuple"
  EMBED_MODEL_NAME=${EMBED_MODEL_NAME:-$detected_embed_name}
  EMBED_MODEL_VERSION=${EMBED_MODEL_VERSION:-$detected_embed_version}
  EMBED_SKU_NAME=${EMBED_SKU_NAME:-$detected_embed_sku}
  if [[ -n "${detected_embed_min_capacity:-}" ]]; then
    EMBED_SKU_CAPACITY=$(max_int "$EMBED_SKU_CAPACITY" "$detected_embed_min_capacity")
  fi
fi

echo "Resolved chat model: $CHAT_MODEL_NAME $CHAT_MODEL_VERSION (SKU: $CHAT_SKU_NAME, capacity: $CHAT_SKU_CAPACITY)"
echo "Resolved embedding model: $EMBED_MODEL_NAME $EMBED_MODEL_VERSION (SKU: $EMBED_SKU_NAME, capacity: $EMBED_SKU_CAPACITY)"

# Create resource group if it doesn't exist
az group create --name $RESOURCE_GROUP --location $REGION

# Preflight (what-if) to fail fast on invalid combinations.
echo "Running what-if preflight..."
az deployment group what-if \
  --name "rag-whatif-$(date +%Y%m%d%H%M%S)" \
  --resource-group $RESOURCE_GROUP \
  --template-file main.bicep \
  --parameters \
    location=$REGION \
    searchTier=$SEARCH_TIER \
    searchReplicaCount=$SEARCH_REPLICA_COUNT \
    searchPartitionCount=$SEARCH_PARTITION_COUNT \
    storageRedundancy=$STORAGE_REDUNDANCY \
    logRetentionDays=$LOG_RETENTION_DAYS \
    enableManagedIdentity=$ENABLE_MANAGED_IDENTITY \
    openAiChatModelName=$CHAT_MODEL_NAME \
    openAiChatModelVersion=$CHAT_MODEL_VERSION \
    openAiChatSkuName=$CHAT_SKU_NAME \
    openAiChatSkuCapacity=$CHAT_SKU_CAPACITY \
    embeddingModelName=$EMBED_MODEL_NAME \
    embeddingModelVersion=$EMBED_MODEL_VERSION \
    embeddingSkuName=$EMBED_SKU_NAME \
    embeddingSkuCapacity=$EMBED_SKU_CAPACITY \
  --result-format FullResourcePayloads >/dev/null

# Deploy Bicep template
echo "Deploying Bicep template..."
DEPLOYMENT_OUTPUT=$(az deployment group create \
  --resource-group $RESOURCE_GROUP \
  --template-file main.bicep \
  --parameters \
    location=$REGION \
    searchTier=$SEARCH_TIER \
    searchReplicaCount=$SEARCH_REPLICA_COUNT \
    searchPartitionCount=$SEARCH_PARTITION_COUNT \
    storageRedundancy=$STORAGE_REDUNDANCY \
    logRetentionDays=$LOG_RETENTION_DAYS \
    enableManagedIdentity=$ENABLE_MANAGED_IDENTITY \
    openAiChatModelName=$CHAT_MODEL_NAME \
    openAiChatModelVersion=$CHAT_MODEL_VERSION \
    openAiChatSkuName=$CHAT_SKU_NAME \
    openAiChatSkuCapacity=$CHAT_SKU_CAPACITY \
    embeddingModelName=$EMBED_MODEL_NAME \
    embeddingModelVersion=$EMBED_MODEL_VERSION \
    embeddingSkuName=$EMBED_SKU_NAME \
    embeddingSkuCapacity=$EMBED_SKU_CAPACITY \
  --query properties.outputs \
  -o json)

echo "✓ Deployment complete!"
echo "Outputs saved to deployment_summary.json"

# Save outputs
echo "$DEPLOYMENT_OUTPUT" > deployment_summary.json
