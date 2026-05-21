<#
.SYNOPSIS
    Validates that a spec file meets minimum completeness requirements.
.DESCRIPTION
    Checks that required sections exist in a spec file per the spec-template.
.PARAMETER SpecPath
    Path to the spec.md file to validate.
.EXAMPLE
    .\Validate-Spec.ps1 -SpecPath "specs/validate-deployment/spec.md"
#>
param(
    [Parameter(Mandatory = $true)]
    [string]$SpecPath
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $SpecPath)) {
    Write-Error "Spec file not found: $SpecPath"
    exit 1
}

$content = Get-Content $SpecPath -Raw

$requiredSections = @(
    "## 1. Overview",
    "## 2. Motivation",
    "## 3. Input/Output Contract",
    "## 4. Success Criteria",
    "## 5. Error Handling",
    "## 6. Integration Points"
)

$missing = @()
foreach ($section in $requiredSections) {
    if ($content -notmatch [regex]::Escape($section)) {
        $missing += $section
    }
}

if ($missing.Count -gt 0) {
    Write-Host "FAIL: Spec is incomplete. Missing sections:" -ForegroundColor Red
    $missing | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
    exit 1
}

# Check for I/O schemas
if ($content -notmatch "Input Schema" -or $content -notmatch "Output Schema") {
    Write-Host "FAIL: Spec must define both Input and Output schemas." -ForegroundColor Red
    exit 1
}

# Check for at least one success criterion
if ($content -notmatch "\| .+ \| .+ \| .+ \|") {
    Write-Host "WARN: Success criteria table appears empty." -ForegroundColor Yellow
}

Write-Host "PASS: Spec '$SpecPath' meets completeness requirements." -ForegroundColor Green
exit 0
