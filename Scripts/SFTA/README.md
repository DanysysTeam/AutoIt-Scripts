# SFTA

[![AutoIt Version](https://img.shields.io/badge/AutoIt-3.3.14.5-blue.svg)]()
[![MIT License](https://img.shields.io/github/license/mashape/apistatus.svg)]()
[![Made with Love](https://img.shields.io/badge/Made%20with-%E2%9D%A4-red.svg?colorB=11a9f7)]()


Set File/Protocol Type Association Default Application Windows 10


### Description

Change the default program associated with an extension in Windows 10.\
Since Windows 8, Microsoft has changed the way to set the default application association. Now It requires a valid Hash for set in the key: `HKEY_CURRENT_USER\ Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\[Extension] \UserChoice`


## Usage

##### Set Sumatra PDF as Default .pdf reader:
```autoit

#include "SFTA.au3"

#Region Example
If _Set_FTA("Applications\SumatraPDF.exe", ".pdf") Then
	ConsoleWrite(">_Set_FTA OK" & @CRLF)
EndIf
#EndRegion Example


```

##### Set Google Chrome as Default for http Protocol:
```autoit

#include "SFTA.au3"

#Region Example
If _Set_PTA("ChromeHTML", "http") Then
		ConsoleWrite(">_Set_PTA OK" & @CRLF)
		ShellExecute("http:\\autoit.com")
EndIf
#EndRegion Example


```




##### Register Custom Application and Extension:
```autoit
#include "SFTA.au3"

#Region Example
_Example()
#EndRegion Example


Func _Example()
	Local Const $sAut2Exe = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\AutoIt v3\Autoit", "InstallDir") & "\Aut2Exe\Aut2Exe.exe"
	If Not FileExists($sAut2Exe) Then Exit MsgBox(0, "Error", "Unable to find Aut2Exe.exe Path")

	;Create CustomApp Script and .fta File
	Local Const $sMyCustomApp = '#include <Array.au3>' & @CRLF & 'MsgBox(0,"I''m Default App for .fta files",_ArrayToString($CmdLine,@CRLF))'
	FileDelete(@ScriptDir & "\CustomApp.au3")
	FileWrite(@ScriptDir & "\CustomApp.au3", $sMyCustomApp)
	FileWrite(@ScriptDir & "\Danyfirex.fta", "Hello World")

	;Compile CustomApp
	Local $sParameters = '/in "' & @ScriptDir & "\CustomApp.au3" & '" /out "' & @ScriptDir & "\CustomApp.exe" & '"'
	Local $iRet = RunWait($sAut2Exe & " " & $sParameters)

	;Test Association
	_Register_FTA(@ScriptDir & "\CustomApp.exe", ".fta", "", "shell32.dll,100")
	Sleep(1000)
	ShellExecuteWait(@ScriptDir & "\Danyfirex.fta") ;test associated application
	Sleep(1000)
	_Remove_FTA(@ScriptDir & "\CustomApp.exe", ".fta")
	ShellExecuteWait(@ScriptDir & "\Danyfirex.fta") ;test again associated application. It will fail.

	;Remove/Delete
	FileDelete(@ScriptDir & "\CustomApp.au3")
	FileDelete(@ScriptDir & "\CustomApp.exe")
	FileDelete(@ScriptDir & "\Danyfirex.fta")
EndFunc   ;==>_Example

```




<!-- ## Acknowledgments & Credits -->


## License

Usage is provided under the [MIT](https://choosealicense.com/licenses/mit/) License.

Copyright © 2021, [Danysys.](https://www.danysys.com)
