@ECHO OFF

ECHO Performing uninstallation...

ECHO|SET /P="Uninstalling VmVboxService..."
C:\vms\unins000.exe /SILENT /SP- /SUPPRESSMSGBOXES /NORESTART
IF %ERRORLEVEL% GTR 0 ECHO FAIL && GOTO :fail
ECHO DONE

ECHO|SET /P="Uninstalling HaneWIN NFS..."
"C:\Program Files\nfsd\unins000.exe" /SILENT /SP- /SUPPRESSMSGBOXES /NORESTART
IF %ERRORLEVEL% GTR 0 ECHO FAIL && GOTO :fail
ECHO DONE

ECHO|SET /P="Removing devarch VM..."
FOR /F "tokens=8-12" %a IN ('VBoxManage showvminfo devarch_1 ^|find "NIC 2:"') DO SET hostonlyif=%a %b %c %d %e
IF %ERRORLEVEL% GTR 0 ECHO FAIL && GOTO :fail
VBoXManage hostonlyif remove %hostonlyif:~1,-2%
IF %ERRORLEVEL% GTR 0 ECHO FAIL && GOTO :fail
VBoxManage unregistervm devarch_1 --delete
IF %ERRORLEVEL% GTR 0 ECHO FAIL && GOTO :fail
ECHO DONE

EXIT /B

:fail
EXIT /B %ERRORLEVEL%