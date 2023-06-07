@echo off

REM Checks for privileges 
net session >nul 2>&1
if %errorLevel% == 0 (
    goto :Check
) else (
    echo Please run script as an administrator!
    pause
    exit
)

REM Checks for conflicting versions of Vanguard
:Check
pushd "C:\Program Files\Riot Vanguard"
if exist "vgk.sys" (
	if exist "vgk.sys.bak" (
    		del vgk.sys.bak
    		del vgc.exe.bak
    		del vgtray.exe.bak
    		del vgrl.dll.bak
    		del installer.exe.bak
    		goto :Toggle
	) else (
    		goto :Toggle
	)
)

REM Actual Script, shutdown at bottom is configurable for time (default is 10)
:Toggle
pushd "C:\Program Files\Riot Vanguard"
if exist "vgk.sys" (
    ren vgk.sys vgk.sys.bak
    ren vgc.exe vgc.exe.bak
    ren vgtray.exe vgtray.exe.bak
    ren vgrl.dll vgrl.dll.bak
    ren installer.exe installer.exe.bak
    sc config vgc start= disabled & sc config vgk start= disabled & net stop vgc & net stop vgk & taskkill /IM vgtray.exe
) else (
    if exist "vgk.sys.bak" (
        ren vgk.sys.bak vgk.sys
        ren vgc.exe.bak vgc.exe
        ren vgtray.exe.bak vgtray.exe
        ren vgrl.dll.bak vgrl.dll
        ren installer.exe.bak installer.exe
        sc config vgc start= demand & sc config vgk start= system & shutdown /r /f /t 10
    ) 
)
