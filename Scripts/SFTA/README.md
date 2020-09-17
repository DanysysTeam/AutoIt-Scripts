# SFTA

[![MIT License](https://img.shields.io/github/license/mashape/apistatus.svg)]()
[![Made with Love](https://img.shields.io/badge/Made%20with-%E2%9D%A4-red.svg?colorB=11a9f7)]()


Set File Type Association Default Application Windows 10


### Description

Change the default program associated with an extension in Windows 10.\
Since Windows 8, Microsoft has changed the way to set the default application association. Now It requires a valid Hash for set in the key: `HKEY_CURRENT_USER\ Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\[Extension] \UserChoice`


## Usage

##### Set Sumatra PDF as Default .pdf reader:
```autoit

#include "SFTA.au3"

#Region Example
If _Set_FTA("Applications\SumatraPDF.exe", ".pdf") Then
	ConsoleWrite(">_SerFileTypeAssociation OK" & @CRLF)
EndIf
#EndRegion Example


```


<!-- ## Acknowledgments & Credits -->


## License

Usage is provided under the [MIT](https://choosealicense.com/licenses/mit/) License.

Copyright © 2020, [Danysys.](https://www.danysys.com)
