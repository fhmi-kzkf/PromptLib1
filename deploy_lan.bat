@echo off
REM ============================================
REM  PromptLib LAN Server Deploy Script
REM  Deploys Flutter web build to backend and
REM  starts server accessible on local network
REM ============================================

echo.
echo ========================================
echo   PromptLib - LAN Deploy Script
echo ========================================
echo.

REM Step 1: Build Flutter web
echo [1/3] Building Flutter web app...
cd /d "%~dp0frontend"
call flutter build web --release --base-href=/app/
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Flutter build failed!
    pause
    exit /b 1
)
echo       Flutter build complete!

REM Step 2: Copy build output to backend/public/app
echo [2/3] Deploying to backend...
set SOURCE=%~dp0frontend\build\web
set DEST=%~dp0backend\public\app

REM Clean old build
if exist "%DEST%" rmdir /s /q "%DEST%"

REM Copy new build
xcopy "%SOURCE%" "%DEST%" /E /I /Q /Y > nul
echo       Deploy complete!

REM Step 3: Get LAN IP and start server
echo [3/3] Starting LAN server...
echo.

REM Find LAN IP
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /i "IPv4" ^| findstr /v "192.168.56"') do (
    set LANIP=%%a
)
set LANIP=%LANIP: =%

echo ========================================
echo   Server is running!
echo.
echo   Local:   http://localhost:8080
echo   Network: http://%LANIP%:8080
echo.
echo   Share the Network URL with friends!
echo   They can open it on their phone browser.
echo ========================================
echo.
echo Press Ctrl+C to stop the server.
echo.

cd /d "%~dp0backend"
php spark serve --host 0.0.0.0 --port 8080
