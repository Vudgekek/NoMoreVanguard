@echo off

REM Checks for privileges 
net session >nul 2>&1
if %errorLevel% == 0 (
    :Directory
) else (
    echo Please run script as an administrator!
    pause
    exit
)

REM Checks for valid directory
:Directory
if exist "C:\Program Files\Riot Vanguard" (
	:Check
) else (
	echo Vanguard directory is invalid.
	pause
	exit
)

REM Checks for conflicting versions of Vanguard
:Check
pushd "C:\Program Files\Riot Vanguard"
if exist "vgk.sys" (
	:DeleteOld
	:Toggle
) else (
    	:Toggle
)

REM Removes outdated version found
:DeleteOld
if exist "vgk.sys.bak" (
    	del vgk.sys.bak
    	del vgc.exe.bak
    	del vgtray.exe.bak
    	del vgrl.dll.bak
    	del installer.exe.bak
)

REM Actual Script
:Toggle
if exist "vgk.sys" (
	:Disable
) else (
	:Revert
)

REM Renames various files used by Vanguard to make them temporarily unusable, then stops the services
:Disable
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

REM Reverts changes made by disable function and restarts services, then restarts the system
:Revert
ren vgk.sys.bak vgk.sys
ren vgc.exe.bak vgc.exe
ren vgtray.exe.bak vgtray.exe
ren vgrl.dll.bak vgrl.dll
ren installer.exe.bak installer.exe
sc config vgc start= demand
sc config vgk start= system
shutdown /r /f /t 10
