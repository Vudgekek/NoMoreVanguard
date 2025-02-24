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
for %%a in ("installer.exe", "log-uploader.exe", "vgc.exe", "vgc.ico", "vgk.sys", "vgrl.dll", "vgtray.exe") do (
    if exist "%%a" (
        del "%%a.bak" >nul 2>&1
    )
)

if exist "vgk.sys" (
    echo Vanguard is currently enabled.
    choice /c YN /n /m "Would you like to disable it? [Y/N]:"
    if errorlevel 2 exit
    if errorlevel 1 (
        REM Stops Vanguard services, renames key files, and deletes Vanguard logs
        cls
        echo Disabling Vanguard...
        sc config vgc start= disabled >nul 2>&1
        sc config vgk start= disabled >nul 2>&1
        net stop vgc >nul 2>&1
        net stop vgk >nul 2>&1
        taskkill /f /im vgtray.exe >nul 2>&1
        for %%a in (*) do (
            ren "%%a" "%%a.bak"
        )
        del /q "Logs"
    )
) else (
    echo Vanguard is currently disabled.
    choice /c YN /n /m "Would you like to enable it? [Y/N]:"
    if errorlevel 2 exit
    if errorlevel 1 (
        REM Reverts changes made by disable function and reinstates services, then prompts user for restart
        echo Enabling Vanguard...
        for %%a in (*) do (
            ren "%%a" "%%~na"
        )
        sc config vgc start= demand
        sc config vgk start= system
        cls
        echo These changes require a restart.
        choice /c YN /n /m "Would you like to restart now? [Y/N]:"
        if errorlevel 2 exit
        if errorlevel 1 (
            shutdown /r /f /t 00
        )
    )
)

exit
