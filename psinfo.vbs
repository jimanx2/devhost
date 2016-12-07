Const HKLM = &H80000002 'HKEY_LOCAL_MACHINE 
strComputer = "." 
strKey = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" 
strEntry1a = "DisplayName" 
strEntry1b = "QuietDisplayName" 
strEntry2 = "InstallDate" 
strEntry3 = "VersionMajor" 
strEntry4 = "VersionMinor" 
strEntry5 = "EstimatedSize" 

Set objReg = GetObject("winmgmts://" & strComputer & _ 
 "/root/default:StdRegProv") 
objReg.EnumKey HKLM, strKey, arrSubkeys 
WScript.Echo "Installed Applications" & VbCrLf 
For Each strSubkey In arrSubkeys 
  intRet1 = objReg.GetStringValue(HKLM, strKey & strSubkey, _ 
   strEntry1a, strValue1) 
  If intRet1 <> 0 Then 
    objReg.GetStringValue HKLM, strKey & strSubkey, _ 
     strEntry1b, strValue1 
  End If 
  If strValue1 <> "" Then 
		WScript.Echo strValue1 
  End If 
Next 