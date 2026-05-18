param location string = 'eastus'
param resourceGroupName string = 'demo-rg'

// Resource names
var openaiName = 'openai-${uniqueString(resourceGroup().id)}'
var searchName = 'search-${uniqueString(resourceGroup().id)}'
var appInsightsName = 'appinsights-${uniqueString(resourceGroup().id)}'
var logAnalyticsName = 'logs-${uniqueString(resourceGroup().id)}'

// OpenAI
resource openai 'Microsoft.CognitiveServices/accounts@2023-10-01-preview' = {
  name: openaiName
  location: location
  kind: 'OpenAI'
  sku: {
    name: 'S0'
  }
  properties: {
    apiProperties: {
      statisticsEnabled: false
    }
  }
}

// OpenAI Deployments
// NOTE: scaleSettings is deprecated since API version 2023-05-01.
// Use 'sku' with name (Standard/GlobalStandard) and capacity instead.
// Check available SKUs per region: az cognitiveservices model list --location <region>
// gpt-4o: minimum quality model for RAG (gpt-4o-mini is below quality bar)
resource gpt4oDeployment 'Microsoft.CognitiveServices/accounts/deployments@2023-10-01-preview' = {
  parent: openai
  name: 'gpt-4o'
  sku: {
    name: 'GlobalStandard'
    capacity: 10
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-4o'
      version: '2024-08-06'
    }
  }
}

// Embedding model for vector search
resource embeddingDeployment 'Microsoft.CognitiveServices/accounts/deployments@2023-10-01-preview' = {
  parent: openai
  name: 'text-embedding-3-small'
  dependsOn: [gpt4oDeployment]
  sku: {
    name: 'Standard'
    capacity: 50
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'text-embedding-3-small'
      version: '1'
    }
  }
}

// Search
resource search 'Microsoft.Search/searchServices@2023-11-01' = {
  name: searchName
  location: location
  sku: {
    name: 'standard'
  }
  properties: {
    replicaCount: 1
    partitionCount: 1
  }
}

// Log Analytics
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: logAnalyticsName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

// Application Insights
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalytics.id
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

// Outputs
output openaiEndpoint string = openai.properties.endpoint
output openaiKey string = openai.listKeys().key1
output searchEndpoint string = 'https://${searchName}.search.windows.net'
output searchKey string = search.listAdminKeys().primaryKey
output appInsightsKey string = appInsights.properties.InstrumentationKey
output appInsightsConnectionString string = appInsights.properties.ConnectionString
