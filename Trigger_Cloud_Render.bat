@echo off
title BOSS CLOUD RENDER TRIGGER
set /p PROJ="Enter Project folder name (Default: 01_isro_rocket): "
if "%PROJ%"=="" set PROJ=01_isro_rocket

set /p ENGINE="Enter Engine [1] WORKBENCH  [2] EEVEE  [3] CYCLES (Default 1): "
if "%ENGINE%"=="" set ENGINE=BLENDER_WORKBENCH
if "%ENGINE%"=="1" set ENGINE=BLENDER_WORKBENCH
if "%ENGINE%"=="2" set ENGINE=BLENDER_EEVEE
if "%ENGINE%"=="3" set ENGINE=CYCLES

set /p FRAMES="Enter Total Frames to Render (Default 900 for 30s): "
if "%FRAMES%"=="" set FRAMES=900

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0engine\trigger.ps1" -Project "%PROJ%" -Engine "%ENGINE%" -StartFrame "1" -EndFrame "%FRAMES%"
echo.
pause
