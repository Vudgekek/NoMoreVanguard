@echo off

REM Checks for privileges 
net session >nul 2>&1

if not %errorLevel% == 0 (
    echo Please run script as an administrator!
    pause
    exit
)

set "VALORANT_DIR=C:\Program Files\Riot Vanguard"

REM Checks for valid directory
if not exist "%VALORANT_DIR%" (
    echo Vanguard directory is invalid.
    pause
    exit
) 

REM Checks for conflicting versions of Vanguard, removes outdated version found
for %%a in ("vgk.sys", "vgc.exe", "vgtray.exe", "vgrl.dll", "installer.exe") do (
    if exist "%VALORANT_DIR%\%%a" (
        del "%VALORANT_DIR%\%%a.bak" >nul 2>&1
    )
)

REM Actual Script
pushd "%VALORANT_DIR%"
if exist "vgk.sys" (
    REM Renames various files used by Vanguard to make them temporarily unusable, then stops the services
    ren vgk.sys vgk.sys.bak
    ren vgc.exe vgc.exe.bak
    ren vgtray.exe vgtray.exe.bak
    ren vgrl.dll vgrl.dll.bak
    ren installer.exe installer.exe.bak
    sc config vgc start= disabled
    sc config vgk start= disabled
    net stop vgc 
    net stop vgk
    taskkill /IM vgtray.exe
) else (
    REM Reverts changes made by disable function and reinstates services, then restarts the system after 60 seconds
    ren vgk.sys.bak vgk.sys
    ren vgc.exe.bak vgc.exe
    ren vgtray.exe.bak vgtray.exe
    ren vgrl.dll.bak vgrl.dll
    ren installer.exe.bak installer.exe
    sc config vgc start= demand
    sc config vgk start= system
    shutdown /r /f /t 60
)

exit
