@ECHO OFF

SET VboxDir=%hasVBoxManage:~0,-14%
IF NOT EXIST .\.cache\devarch.ova (
	ECHO Downloading DevArch VM...
	wget.exe "http://devarch.d0t.co/devarch.ova" -O .\.cache\devarch.ova
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

VBoxManage dhcpserver add --ifname "%newif%" --ip 192.168.90.254 --netmask 255.255.255.0 --lowerip 192.168.90.100 --upperip 192.168.90.100 --enable
IF %ERRORLEVEL% GTR 0 GOTO :fail

VBoxManage modifyvm devarch_1 --nic1 nat --nic2 hostonly --nictype1 Am79C973 --nictype2 Am79C973 --hostonlyadapter2 "%newif%"
IF %ERRORLEVEL% GTR 0 GOTO :fail

GOTO :finish

:fail
EXIT /B %ERRORLEVEL%

:quit
ECHO OK, exit

:finish
EXIT /B