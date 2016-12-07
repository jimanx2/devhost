@ECHO OFF

SETLOCAL EnableDelayedExpansion
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
IF NOT "%haveVm%" == "" ECHO VM already installed. Exiting. && GOTO :exit

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
)

:exit
ENDLOCAL