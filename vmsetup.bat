@ECHO OFF

SET FORCEDOWNLOADVM=0

:downloadvm
IF NOT EXIST .\.cache\devarch.ova (
	ECHO Downloading DevArch VM...
	wget.exe "http://devarch.d0t.co/devarch.ova" -O .\.cache\devarch.ova
)

IF "%FORCEDOWNLOADVM%" EQU "1" (
	ECHO Downloading DevArch VM...
	wget.exe "http://devarch.d0t.co/devarch.ova" -O .\.cache\devarch.ova
)

ECHO Verifying downloaded VM...
pushd .cache
FOR /F "tokens=1" %%i IN ('..\md5sum devarch.ova') DO SET MD5SUM=%%i
IF %ERRORLEVEL% GTR 0 (
	ECHO Failed to verify downloaded VM...
	SET /P response="Would you like to redownload VM file? (y/n) "
	IF "!response!" == "y" (
		SET FORCEDOWNLOADVM=1
		GOTO :downloadvm
	) ELSE (
		ECHO Installation cannot proceed without valid VM file. Exit
		GOTO :finish
	)
)
popd

IF "%MD5SUM%" NEQ "1f1bb7769f0cab7f3189581943a1c3d1" (
	ECHO MD5 Checksum Failed!
	SET /P response="Would you like to redownload VM file? (y/n) "
	IF "!response!" == "y" (
		SET FORCEDOWNLOADVM=1
		GOTO :downloadvm
	) ELSE (
		ECHO Installation cannot proceed without valid VM file. Exit
		GOTO :fail
	)
)

ECHO Loading devarch.ova...
VBoxManage import .\.cache\devarch.ova --dry-run

SET /P Result="Proceed? (y/n) "
IF "%Result%" == "y" (
	SET /P Override="Override VBoxManage switches? [empty] "
	IF "!Override!" NEQ "" (
		ECHO !Override! s
		VBoxManage import !Override! .\.cache\devarch.ova
	) ELSE (
		VBoxManage import .\.cache\devarch.ova
	)
	IF %ERRORLEVEL% GTR 0 GOTO :fail
) ELSE GOTO :quit

ECHO Creating special network interface for the created VM...
for /f "tokens=*" %%i IN ('VBoxManage hostonlyif create ^|find "Interface"') do set newif=%%i
SET newif=%newif:~11,-26%
ECHO %newif%

ECHO Setting up network interface...
VBoxManage hostonlyif ipconfig "%newif%" --ip 192.168.90.253 --netmask 255.255.255.0
IF %ERRORLEVEL% GTR 0 GOTO :fail

FOR /F "tokens=1" %%a IN ('VBoxManage list dhcpservers ^|find "192.168.90.254"') DO SET DhcpReady=%%a
)
IF "%DhcpReady%" NEQ "IP:" (
	VBoxManage dhcpserver add --ifname "%newif%" --ip 192.168.90.254 --netmask 255.255.255.0 --lowerip 192.168.90.100 --upperip 192.168.90.100 --enable
	IF %ERRORLEVEL% GTR 0 GOTO :fail
)

VBoxManage modifyvm devarch_1 --nic1 nat --nic2 hostonly --nictype1 Am79C973 --nictype2 Am79C973 --hostonlyadapter2 "%newif%"
IF %ERRORLEVEL% GTR 0 GOTO :fail

GOTO :finish

:fail
SET ERRORLEVEL=4
EXIT /B %ERRORLEVEL%

:quit
ECHO OK, exit

:finish
EXIT /B
