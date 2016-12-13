@ECHO OFF

SETLOCAL EnableDelayedExpansion
FOR /F "tokens=2" %%a in ("%CMDCMDLINE%") DO (
	IF "%%a" == "/c" CALL :showmessage "Please run this script via Elevated Command Prompt." && GOTO :exit
)

net session 2>nul 1>nul
IF %ERRORLEVEL% GTR 0 ECHO This script needs to be run as administrator && GOTO :exit

ECHO Verifying system requirements...

call checkreqs.bat
IF %ERRORLEVEL% GTR 0 (
	ECHO Some requirements are not met. Come back when you're ready B-^)
	goto :exit
) ELSE (
	ECHO Requirements are satisfied. Proceeding to installation.
)

FOR /F "tokens=*" %%a IN ('VBoxManage list vms ^|find "devarch_1"') DO SET haveVm=%%a
ECHO %haveVm%
IF NOT "%haveVm%" == "" (
	ECHO VM already installed.
	SET /P Response="Force Reinstall? (y/n) "
	IF "!Response!" NEQ "y" (
		GOTO :exit
	) ELSE (
		CALL uninstall.bat
		IF %ERRORLEVEL% GTR 0 ECHO An error occurred while uninstalling existing components. && GOTO :exit
	)
)

call vmsetup.bat
IF %ERRORLEVEL% GTR 0 (
	ECHO VM Setup Failed^^^! This could be a bug. Please report to haziman@abh.my for support.
	goto :exit
) ELSE (
	ECHO VM has been setup successfully^^^!
)

call toolssetup.bat
IF %ERRORLEVEL% GTR 0 (
	ECHO VM Setup Failed^^^! This could be a bug. Please report to haziman@abh.my for support.
	goto :exit
) ELSE (
	ECHO All installation done^^^! Enjoy developing on Windows^^^!
	ECHO Just to make sure everything works, let's reboot.
	SET /P Reboot="Reboot? (y/n)"
	IF "!Reboot!" == "y" SHUTDOWN /r /t 00
)

:exit
ENDLOCAL
EXIT /B

:showmessage
> "%TEMP%\TEMPmessage.vbs" (
	ECHO.MSGBOX %1%
)
CALL %TEMP%\TEMPmessage.vbs
DEL %temp%\TEMPmessage.vbs /f /q