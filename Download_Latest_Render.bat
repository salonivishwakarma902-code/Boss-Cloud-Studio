@echo off
title BOSS CLOUD ARTIFACT DOWNLOADER
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0engine\download_latest.ps1"
echo.
pause
