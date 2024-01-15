@echo off

REM Request admin perms through UAC
net session >nul 2>&1

if %errorlevel% NEQ 0 (
    echo Requesting administrative privileges...
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"="
    echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B
) else (
    pushd "%CD%"
    cd /D "%~dp0"
)

set "VANGUARD_DIR=%PROGRAMFILES%\Riot Vanguard"

REM Checks for valid directory
if not exist "%VANGUARD_DIR%" (
    echo Vanguard directory is invalid. It is either not at the default location or Vanguard is not installed.
    pause
    exit
) 

REM Changes working directory to Vanguard directory
pushd "%VANGUARD_DIR%"

REM Checks for conflicting versions of Vanguard, removes outdated version found
for %%a in ("vgk.sys", "vgc.exe", "vgtray.exe", "vgrl.dll", "installer.exe") do (
    if exist "%%a" (
        del "%%a.bak" >nul 2>&1
    )
)

REM Actual Script
:Toggle
if exist "vgk.sys" (
    REM Renames various files used by Vanguard to make them temporarily unusable, then stops the services
    echo Disabling Vanguard...
    ren vgk.sys vgk.sys.bak
    ren vgc.exe vgc.exe.bak
    ren vgtray.exe vgtray.exe.bak
    ren vgrl.dll vgrl.dll.bak
    ren installer.exe installer.exe.bak
    sc config vgc start= disabled >nul 2>&1
    sc config vgk start= disabled >nul 2>&1
    net stop vgc >nul 2>&1
    net stop vgk >nul 2>&1
    taskkill /f /im vgtray.exe >nul 2>&1
) else (
    REM Reverts changes made by disable function and reinstates services, then restarts the system after 30 seconds w/ countdown
    ren vgk.sys.bak vgk.sys
    ren vgc.exe.bak vgc.exe
    ren vgtray.exe.bak vgtray.exe
    ren vgrl.dll.bak vgrl.dll
    ren installer.exe.bak installer.exe
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
