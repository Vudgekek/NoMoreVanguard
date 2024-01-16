@echo off

REM Obtain admin perms by creating a temporary VBS script that calls a UAC prompt
net session >nul 2>&1
if not %errorlevel% == 0 (
    echo Requesting administrative privileges...
    echo set UAC = CreateObject^("Shell.Application"^) > "%temp%\UAC.vbs"
    set "params=%*"
    echo UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\UAC.vbs"
    "%temp%\UAC.vbs"
    del "%temp%\UAC.vbs"
    exit /b
) else (
    pushd "%cd%"
    cd /d "%~dp0"
)

set "VANGUARD_DIR=%PROGRAMFILES%\Riot Vanguard"

REM Checks for valid directory
if not exist "%VANGUARD_DIR%" (
    echo Vanguard directory is invalid. It is either not at the default location or not installed.
    pause
    exit
) 

REM Changes working directory to Vanguard directory
pushd "%VANGUARD_DIR%"

REM Checks for conflicting versions of Vanguard, removes outdated version found
for %%a in ("vgk.sys", "vgc.exe", "vgtray.exe", "vgrl.dll", "installer.exe", "log-uploader.exe") do (
    if exist "%%a" (
        del "%%a.bak" >nul 2>&1
    )
)

REM Actual Script
:Toggle
if exist "vgk.sys" (
    REM Renames various files used by Vanguard to make them temporarily unusable, then stops the services
    echo Disabling Vanguard...
    for %%a in ("vgk.sys", "vgc.exe", "vgtray.exe", "vgrl.dll", "installer.exe", "log-uploader.exe") do (
        ren "%%a" "%%a.bak"
    )
    pushd "Logs"
    del "*log"
    sc config vgc start= disabled >nul 2>&1
    sc config vgk start= disabled >nul 2>&1
    net stop vgc >nul 2>&1
    net stop vgk >nul 2>&1
    taskkill /f /im vgtray.exe >nul 2>&1
) else (
    REM Reverts changes made by disable function and reinstates services, then restarts the system after 30 seconds w/ countdown
    for %%a in ("vgk.sys", "vgc.exe", "vgtray.exe", "vgrl.dll", "installer.exe", "log-uploader.exe") do (
        ren "%%a.bak" "%%a"
    )
    sc config vgc start= demand
    sc config vgk start= system
    for /l %%b in (30 -1 1) do (
        cls
        echo Restarting in: %%b Seconds - [C]ancel / [R]estart Now
        for /f "Delims=" %%c in ('Choice /T 1 /N /C:CSRW /D W') do (
            if %%c==C goto :Toggle
            if %%c==R shutdown /r /f /t 00
        )
    )
    shutdown /r /f /t 00
)

exit
