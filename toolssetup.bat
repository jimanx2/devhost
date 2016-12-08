@ECHO OFF

:downloadvms
IF NOT EXIST .\.cache\vboxvmssetup.exe (
	ECHO Downloading VMBoxService...
	wget.exe "https://sourceforge.net/projects/vboxvmservice/files/latest/download?source=files" -O .\.cache\vboxvmssetup.exe
)

:downloadnfs
IF NOT EXIST .\.cache\nfs1222.exe (
	ECHO Downloading HaneWIN NFS Server...
	wget.exe "http://r.hanewin.net/nfs1222.exe" -O .\.cache\nfs1222.exe
)

:setup
ECHO Installing VMBoxService...
.\.cache\vboxvmssetup.exe /SILENT /SP- /SUPPRESSMSGBOXES /NORESTART /LOG=vmboxvmssetup.log
ECHO Installing HaneWIN NFS Server...
.\.cache\nfs1222.exe /SILENT /SP- /SUPPRESSMSGBOXES /NORESTART /LOG=nfs1222.log
verify >nul

:config
SET USER=%USERPROFILE:~9%
SET /P PASS="Please insert your Windows login password (don't worry this is temporary): "
> C:\vms\VBoxVmService.ini (
@echo.[Settings]
@echo.VBOX_USER_HOME=C:\Users\%USER%\.VirtualBox
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
ECHO Adding Firewall entry for: HaneWIN NFS Server...
netsh advfirewall firewall add rule name="nfsd" dir=in action=allow program="C:\Program Files\nfsd\nfsd.exe"
netsh advfirewall firewall add rule name="haneWIN Portmap Daemon" dir=in action=allow program="C:\Program Files\nfsd\pmapd.exe"
ECHO Creating HOST entry...
ECHO 192.168.90.100 devhost >> C:\Windows\System32\drivers\etc\hosts

:finish
EXIT /B