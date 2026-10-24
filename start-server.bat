@echo off
title LifeDrop Blood Donation & Search Platform
echo ====================================================
echo 🩸 Starting LifeDrop Platform Server & Database...
echo ====================================================
cd /d "%~dp0"

echo Opening browser at http://localhost:5000 ...
timeout /t 2 /nobreak >nul
start http://localhost:5000

node server.js
if %errorlevel% neq 0 (
    echo.
    echo Server stopped with error.
    pause
)

