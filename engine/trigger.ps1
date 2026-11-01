param(
    [string]$Project = "01_isro_rocket",
    [string]$Engine = "BLENDER_WORKBENCH",
    [string]$StartFrame = "1",
    [string]$EndFrame = "900"
)

Clear-Host
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "         BOSS CLOUD 3D ENGINE - INSTANT LAUNCHER          " -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Project     : $Project" -ForegroundColor Green
Write-Host " Engine      : $Engine" -ForegroundColor Green
Write-Host " Frame Range : $StartFrame to $EndFrame" -ForegroundColor Green
Write-Host " Target      : GitHub Cloud (0% Laptop Load)" -ForegroundColor Cyan
Write-Host "----------------------------------------------------------" -ForegroundColor DarkGray

# Fetch token safely from Windows Credential Manager
$credInput = "protocol=https`nhost=github.com`n`n"
$credOutput = $credInput | git credential fill
$tokenLine = $credOutput | Select-String "password="
$token = $tokenLine.ToString().Trim().Replace("password=", "")

if (-not $token) {
    Write-Host "[ERROR] GitHub token not found in Windows Credential Manager." -ForegroundColor Red
    Write-Host "Please use the GitHub web interface: https://github.com/salonivishwakarma902-code/Boss-Cloud-Studio/actions" -ForegroundColor Yellow
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $token"
    "Accept"        = "application/vnd.github+json"
    "User-Agent"    = "Boss-Cloud-Studio"
}

$body = @{
    ref = "main"
    inputs = @{
        project = $Project
        engine = $Engine
        start_frame = $StartFrame
        end_frame = $EndFrame
    }
} | ConvertTo-Json

try {
    Write-Host "[1/2] Sending task to GitHub Cloud Server..." -ForegroundColor Yellow
    Invoke-RestMethod -Uri "https://api.github.com/repos/salonivishwakarma902-code/Boss-Cloud-Studio/actions/workflows/403359420/dispatches" -Method Post -Headers $headers -Body $body -ContentType "application/json"
    Write-Host "[SUCCESS] Cloud Render Started Successfully!" -ForegroundColor Green
    
    Start-Sleep -Seconds 3
    $runs = Invoke-RestMethod -Uri "https://api.github.com/repos/salonivishwakarma902-code/Boss-Cloud-Studio/actions/runs" -Headers $headers
    $latest = $runs.workflow_runs[0]
    
    Write-Host "[2/2] Live Tracking URL:" -ForegroundColor Yellow
    Write-Host "      $($latest.html_url)" -ForegroundColor Cyan
    Write-Host "`nOpening Live Progress in your Browser..." -ForegroundColor White
    Start-Process $latest.html_url
} catch {
    Write-Host "[ERROR] Failed to dispatch workflow: $_" -ForegroundColor Red
}

Write-Host "==========================================================" -ForegroundColor Cyan
