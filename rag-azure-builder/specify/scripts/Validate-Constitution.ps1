<#
.SYNOPSIS
    Validates that a spec or plan complies with the project constitution.
.DESCRIPTION
    Checks for constitution violations: missing observability, no error handling,
    hardcoded credentials, or missing cost awareness.
.PARAMETER Path
    Path to the spec.md or plan.md to validate.
.EXAMPLE
    .\Validate-Constitution.ps1 -Path "specs/validate-deployment/spec.md"
#>
param(
    [Parameter(Mandatory = $true)]
    [string]$Path
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $Path)) {
    Write-Error "File not found: $Path"
    exit 1
}

$content = Get-Content $Path -Raw
$violations = @()

# Constitution §1: Cost Awareness
# Features that touch Azure must mention cost implications
if ($content -match "Azure|deploy|infrastructure" -and $content -notmatch "cost|budget|pricing") {
    $violations += "[§1 Cost Awareness] Document references Azure resources but has no cost/budget discussion."
}

# Constitution §2: Zero Credential Leaks
$credentialPatterns = @(
    "[a-zA-Z0-9]{32,}",          # Long alphanumeric strings (potential keys)
    "sk-[a-zA-Z0-9]{20,}",       # OpenAI-style keys
    "DefaultEndpointsProtocol"    # Connection strings
)
foreach ($pattern in $credentialPatterns) {
    if ($content -match $pattern) {
        $violations += "[§2 Zero Credential Leaks] Possible credential or secret detected. Use placeholders."
    }
}

# Constitution §3: Observability
if ($content -match "implementation|script|agent" -and $content -notmatch "log|metric|observ|telemetry|monitor") {
    $violations += "[§3 Observability] No mention of logging, metrics, or observability."
}

# Constitution §4: Error Handling
if ($content -match "## [0-9]+\. Error Handling" -or $content -match "error|exception|failure|recovery") {
    # Has error handling - good
} else {
    $violations += "[§4 Error Handling] No error handling section or discussion found."
}

# Results
if ($violations.Count -gt 0) {
    Write-Host "CONSTITUTION VIOLATIONS FOUND:" -ForegroundColor Red
    $violations | ForEach-Object { Write-Host "  $_" -ForegroundColor Yellow }
    Write-Host ""
    Write-Host "Fix these before proceeding. See .github/specify/memory/constitution.md" -ForegroundColor Cyan
    exit 1
}

Write-Host "PASS: No constitution violations detected in '$Path'." -ForegroundColor Green
exit 0
