Clear-Host
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "         BOSS CLOUD 3D ENGINE - ARTIFACT DOWNLOADER       " -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan

# Fetch token safely from Windows Credential Manager
$credInput = "protocol=https`nhost=github.com`n`n"
$credOutput = $credInput | git credential fill
$tokenLine = $credOutput | Select-String "password="
$token = $tokenLine.ToString().Trim().Replace("password=", "")

if (-not $token) {
    Write-Host "[ERROR] GitHub token not found in Windows Credential Manager." -ForegroundColor Red
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $token"
    "Accept"        = "application/vnd.github+json"
    "User-Agent"    = "Boss-Cloud-Studio"
}

Write-Host "[1/3] Checking latest artifacts on GitHub Cloud..." -ForegroundColor Yellow
$arts = Invoke-RestMethod -Uri "https://api.github.com/repos/salonivishwakarma902-code/Boss-Cloud-Studio/actions/artifacts" -Headers $headers

if ($arts.total_count -eq 0) {
    Write-Host "[INFO] No artifacts found yet on GitHub." -ForegroundColor Red
    exit 0
}

$latest = $arts.artifacts[0]
Write-Host " Found Artifact: $($latest.name) ($([math]::Round($latest.size_in_bytes / 1KB, 1)) KB)" -ForegroundColor Green

$outDir = "C:\Users\adita\Downloads\yy\Boss_Cloud_Studio\output"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null
$zipFile = Join-Path $outDir "latest_artifact.zip"

Write-Host "[2/3] Downloading video from GitHub..." -ForegroundColor Yellow
Invoke-WebRequest -Uri $latest.archive_download_url -Headers $headers -OutFile $zipFile

Write-Host "[3/3] Extracting MP4 video..." -ForegroundColor Yellow
Expand-Archive -Path $zipFile -DestinationPath $outDir -Force
Remove-Item $zipFile -Force

$videoFiles = Get-ChildItem -Path $outDir -Filter "*.mp4"
if ($videoFiles) {
    $v = $videoFiles[0]
    Copy-Item $v.FullName "C:\Users\adita\Downloads\yy\$($v.Name)" -Force
    Write-Host "[SUCCESS] Video saved to:" -ForegroundColor Green
    Write-Host "   -> $($v.FullName)" -ForegroundColor Cyan
    Write-Host "   -> C:\Users\adita\Downloads\yy\$($v.Name)" -ForegroundColor Cyan
    Start-Process explorer.exe "/select,$($v.FullName)"
}

Write-Host "==========================================================" -ForegroundColor Cyan
