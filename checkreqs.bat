@ECHO OFF

FOR /f %%a IN ('wmic ComputerSystem get TotalPhysicalMemory ^|findstr /V /n "TotalPhysicalMemory" ^|find "2:"') DO (
	SET pmem=%%a
)
SET pmem=%pmem:~2%

ECHO|SET /P=Physical Memory: %pmem%
IF NOT [%pmem%] GTR [2147483648] (
	ECHO [FAIL]
	ECHO Your physical memory is not enough. Have you been eating ants lately? 
	ECHO Just kidding. You should upgrade your RAM to at least 6GB [FAIL]
	GOTO :fail
)
ECHO. [PASS]

FOR /f "tokens=4" %%a IN ('cscript psinfo.vbs ^|find "VirtualBox"') DO SET hasVbox=%%a

IF "%hasVbox%" == "" ECHO It seems that VirtualBox has not been installed. Install VirtualBox first and re-run this script [FAIL] && GOTO :fail

ECHO VirtualBox: %hasVbox% [PASS]

FOR /f "tokens=*" %%a IN ('where VBoxManage.exe') DO SET hasVboxManage=%%a
IF hasVboxManage == "" (
	ECHO VBoxManage.exe is not in PATH! [FAIL]
	GOTO :fail
) ELSE (
	ECHO VBoxManage.exe is in PATH! [PASS]
)

GOTO :success

:fail
EXIT /B 5

:success
verify >nul
EXIT /B