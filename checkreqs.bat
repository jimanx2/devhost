@ECHO OFF

FOR /f %%a IN ('wmic ComputerSystem get TotalPhysicalMemory ^|findstr /V /n "TotalPhysicalMemory" ^|find "2:"') DO (
	SET pmem=%%a
)
SET pmem=%pmem:~2%
SET rmem=4294967296
set "tmp_pmem=               %pmem%"
set "tmp_rmem=               %rmem%"
set pad1="%tmp_pmem:~-15%"
set pad2="%tmp_rmem:~-15%"

ECHO|SET /P=Physical Memory: %pmem%
IF NOT %pad1% GTR %pad2% (
	ECHO [FAIL]
	ECHO Your physical memory is not enough. Have you been eating ants lately? 
	ECHO Just kidding. You should upgrade your RAM to at least 4GB.
	GOTO :fail
)
ECHO. [PASS]

FOR /f "tokens=4" %%a IN ('cscript psinfo.vbs ^|find "VirtualBox"') DO (
	SET hasVbox=%%a
	IF "%%a" NEQ "" SET VboxVer=!hasVbox:~0,3!
)
IF "%hasVbox%" == "" (
	ECHO It seems that VirtualBox has not been installed. Install VirtualBox first and re-run this script [FAIL] && GOTO :fail
) ELSE (
	IF ["%VboxVer%"] LSS ["5.1"] ECHO Your virtualbox version is too low. Need version 5.1 and above [FAIL] && GOTO :fail
)

ECHO VirtualBox: %hasVbox% [PASS]

FOR /F "tokens=*" %%a IN ('where VBoxManage.exe') DO SET VboxManage=%%a
IF "%VBoxManage%" EQU "" (
	ECHO VBoxManage.exe is not in PATH! [FAIL]
	GOTO :fail
) ELSE (
	ECHO VBoxManage.exe: %VboxManage% [PASS]
	verify >nul
)

GOTO :success

:fail
EXIT /B 5

:success
verify >nul
EXIT /B
