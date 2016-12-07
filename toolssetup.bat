@ECHO OFF

:downloadvm
IF NOT EXIST .\.cache\devarch.ova (
	ECHO Downloading DevArch VM...
	wget.exe "http://devarch.d0t.co/devarch.ova" -O .\.cache\devarch.ova
)

:downloadvms
IF NOT EXIST .\.cache\vboxvmssetup.exe (
	ECHO Downloading VMBoxService...
	wget.exe "http://downloads.sourceforge.net/project/vboxvmservice/vboxvmservice/Versions%205.x/VBoxVmService-5.1-Plum.exe?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Fvboxvmservice%2Ffiles%2F&ts=1481094961&use_mirror=jaist" -O .\.cache\vboxvmssetup.exe
)

:downloadnfs
IF NOT EXIST .\.cache\nfs1222.exe (
	ECHO Downloading HaneWIN NFS Server...
	wget.exe "http://r.hanewin.net/nfs1222.exe" -O .\.cache\nfs1222.exe
)

:setup
ECHO Installing VMBoxService...
.\.cache\vboxvmssetup.exe /SILENT /LOG=vmboxvmssetup.log /SP-
ECHO Installing HaneWIN NFS Server...
.\.cache\nfs1222.exe /SILENT /LOG=nfs1222.log /SP-
verify >nul

:config
SET USER=%USERPROFILE:~9%
SET /P PASS="Please insert your Windows login password (don't worry this is temporary): "
> C:\vms\VBoxVmService.ini (
@echo.[Settings]
@echo.VBOX_USER_HOME=C:\Users\haziman\.VirtualBox
@echo.RunWebService=no
@echo.PauseShutdown=5000
@echo.RunAsUser=.\%USER%
@echo.UserPassword=%PASS%
@echo.[Vm0]
@echo.VmName=devarch_1
@echo.ShutdownMethod=acpishutdown
@echo.AutoStart=yes
)
ECHO C:\Users\%USER% -public > "C:\Program Files\nfsd\exports"
ECHO Installing VmBoxService service...
C:\vms\VmServiceControl.exe -i >nul
ECHO Creating HOST entry
ECHO 192.168.90.100 devhost >> C:\Windows\System32\drivers\etc\hosts

:finish
EXIT /B