param(
    [Parameter(Mandatory = $true)]
    [string]$P12Path,

    [Parameter(Mandatory = $true)]
    [string]$MobileProvisionPath
)

if (-not (Test-Path $P12Path)) {
    Write-Error "File not found: $P12Path"
    exit 1
}

if (-not (Test-Path $MobileProvisionPath)) {
    Write-Error "File not found: $MobileProvisionPath"
    exit 1
}

$p12Base64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($P12Path))
$profileBase64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($MobileProvisionPath))

Write-Host ""
Write-Host "=== BUILD_CERTIFICATE_BASE64 ===" -ForegroundColor Cyan
Write-Host $p12Base64
Write-Host ""
Write-Host "=== BUILD_PROVISION_PROFILE_BASE64 ===" -ForegroundColor Cyan
Write-Host $profileBase64
Write-Host ""
Write-Host "Copy each block into GitHub -> Settings -> Secrets -> Actions" -ForegroundColor Green
