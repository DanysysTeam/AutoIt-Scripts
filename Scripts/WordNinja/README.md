# WordNinja

[![AutoIt Version](https://img.shields.io/badge/AutoIt-3.3.14.5-blue.svg)]()
[![MIT License](https://img.shields.io/github/license/mashape/apistatus.svg)]()
[![Made with Love](https://img.shields.io/badge/Made%20with-%E2%9D%A4-red.svg?colorB=11a9f7)]()


Probabilistically split concatenated words


### Description

It can insert spaces or split your together words. For example `ineedsomespaces,helpmewordninja!!!` will become `i need some spaces, help me word ninja!!!`

## Usage

##### Example:
```autoit

#include "WordNinja.au3"


#Region Examples
_Example1()
_Example2()
#EndRegion Examples

Func _Example1()
	Local $sStringNoSpaces = "thequickbrownfoxjumpsoverthelazydog."
	Local $sStringWithSpaces = _WN_InferSpaces($sStringNoSpaces)
	MsgBox(0, "WordNinja", "Input: " & @CRLF & $sStringNoSpaces & @CRLF & _
			"Output: " & @CRLF & $sStringWithSpaces)
	Local $aWords = _WN_Split($sStringNoSpaces)
	_ArrayDisplay($aWords, "WordNinja")
EndFunc   ;==>_Example1

Func _Example2()

	Local $sStringNoSpaces = "let'sstart"
	Local $sStringWithSpaces = _WN_InferSpaces($sStringNoSpaces)
	_Print($sStringNoSpaces, $sStringWithSpaces)

	$sStringNoSpaces = "ineedsomespaces,helpmewordninja!!!"
	$sStringWithSpaces = _WN_InferSpaces($sStringNoSpaces)
	_Print($sStringNoSpaces, $sStringWithSpaces)


	$sStringNoSpaces = "hellohowareyou?i'mfinethank's"
	$sStringWithSpaces = _WN_InferSpaces($sStringNoSpaces)
	_Print($sStringNoSpaces, $sStringWithSpaces)

	$sStringNoSpaces = "hewasplanningtostudyfoursubjects:politics,philosophy,sociology,andeconomics."
	$sStringWithSpaces = _WN_InferSpaces($sStringNoSpaces)
	_Print($sStringNoSpaces, $sStringWithSpaces)

	$sStringNoSpaces = "theycanalsobeusedinmathematicalexpressions.forexample,2{1+[23-3]}=x."
	$sStringWithSpaces = _WN_InferSpaces($sStringNoSpaces)
	_Print($sStringNoSpaces, $sStringWithSpaces)

	$sStringNoSpaces = '"one,two,three,four..."'
	$sStringWithSpaces = _WN_InferSpaces($sStringNoSpaces)
	_Print($sStringNoSpaces, $sStringWithSpaces)

	$sStringNoSpaces = "mymother-in-law'srantsmakemefurious!"
	$sStringWithSpaces = _WN_InferSpaces($sStringNoSpaces)
	_Print($sStringNoSpaces, $sStringWithSpaces)

	$sStringNoSpaces = "wethepeopleoftheunitedstatesinordertoformamoreperfectunionestablishjusticeinsuredomestictranquilityprovideforthecommondefencepromotethegeneralwelfareandsecuretheblessingsoflibertytoourselvesandourposteritydoordainandestablishthisconstitutionfortheunitedstatesofamerica"
	$sStringWithSpaces = _WN_InferSpaces($sStringNoSpaces)
	_Print($sStringNoSpaces, $sStringWithSpaces)

EndFunc   ;==>_Example2

Func _Print($sInput, $sOutput)
	ConsoleWrite("Input:  " & $sInput & @CRLF)
	ConsoleWrite("Output: " & $sOutput & @CRLF & @CRLF)
EndFunc   ;==>_Print



```



## Acknowledgments & Credits

https://stackoverflow.com/a/11642687/2449774 \
https://github.com/jiawenhao2015/wordninja \
https://github.com/keredson/wordninja 




## License

Usage is provided under the [MIT](https://choosealicense.com/licenses/mit/) License.

Copyright © 2021, [Danysys.](https://www.danysys.com)
