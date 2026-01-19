<#
.SYNOPSIS
    Installs doclist CLI tool for Windows.
.DESCRIPTION
    Downloads the latest doclist release from GitHub and installs it to ~/bin.
.EXAMPLE
    irm https://raw.githubusercontent.com/zuhairm2001/doclist/main/install.ps1 | iex
#>

$ErrorActionPreference = "Stop"

$repo = "zuhairm2001/doclist"
$binaryName = "doclist.exe"
$installDir = Join-Path $env:USERPROFILE "bin"

Write-Host "Installing doclist..." -ForegroundColor Cyan

# Get latest release info from GitHub API
Write-Host "Fetching latest release..."
try {
    $releaseInfo = Invoke-RestMethod -Uri "https://api.github.com/repos/$repo/releases/latest"
    $version = $releaseInfo.tag_name
    Write-Host "Latest version: $version" -ForegroundColor Green
} catch {
    Write-Host "Error: Failed to fetch release info from GitHub." -ForegroundColor Red
    Write-Host $_.Exception.Message
    exit 1
}

# Find the Windows amd64 asset
$asset = $releaseInfo.assets | Where-Object { $_.name -eq "doclist-windows-amd64.exe" }
if (-not $asset) {
    Write-Host "Error: Could not find Windows amd64 binary in release." -ForegroundColor Red
    exit 1
}

$downloadUrl = $asset.browser_download_url

# Create install directory if it doesn't exist
if (-not (Test-Path $installDir)) {
    Write-Host "Creating directory: $installDir"
    New-Item -ItemType Directory -Path $installDir -Force | Out-Null
}

$installPath = Join-Path $installDir $binaryName

# Download the binary
Write-Host "Downloading $($asset.name)..."
try {
    Invoke-WebRequest -Uri $downloadUrl -OutFile $installPath -UseBasicParsing
} catch {
    Write-Host "Error: Failed to download binary." -ForegroundColor Red
    Write-Host $_.Exception.Message
    exit 1
}

Write-Host "Installed to: $installPath" -ForegroundColor Green

# Check if install directory is in PATH
$userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
if ($userPath -notlike "*$installDir*") {
    Write-Host ""
    Write-Host "Adding $installDir to your PATH..." -ForegroundColor Yellow
    $newPath = "$userPath;$installDir"
    [Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
    Write-Host "PATH updated. Please restart your terminal for changes to take effect." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "doclist $version installed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Usage: doclist <directory>" -ForegroundColor Cyan
