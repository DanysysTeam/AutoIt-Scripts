#cs Copyright
	Copyright 2020 Danysys. <hello@danysys.com>

	Licensed under the MIT license.
	See LICENSE file or go to https://opensource.org/licenses/MIT for details.
#ce Copyright

#cs Information
	Author(s)......: Danyfirex & Dany3j
	Description....: Probabilistically split concatenated words using NLP based on English Wikipedia unigram frequencies.
	Version........: 1.0.0
	AutoIt Version.: 3.3.14.5
	Credits........:
                     https://github.com/jiawenhao2015/wordninja
					 https://github.com/keredson/wordninja
					 https://stackoverflow.com/questions/8870261/how-to-split-text-without-spaces-into-list-of-words/11642687#11642687
#ce Information

#Region Settings
#AutoIt3Wrapper_AU3Check_Parameters=-q -d -w 1 -w 2 -w 3 -w 4 -w 6 -w 7
#EndRegion Settings

#Region Include
#include-once
#include <Array.au3>
#EndRegion Include

; #VARIABLES# ===================================================================================================================
#Region - Internal Variables
Global $__g_oDicWordCost = Null
#EndRegion - Internal Variables


; #CURRENT# =====================================================================================================================
;_WN_InferSpaces
;_WN_Split
;_WN_LoadWordList
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
;__WN_ErrFunc
; ===============================================================================================================================

#Region Public Functions

; #FUNCTION# ====================================================================================================================
; Name ..........: _WN_InferSpaces
; Description ...:
; Syntax ........: _WN_InferSpaces($sText)
; Parameters ....: $sText               - a string value.
; Return values .: String
; Author ........: DanysysTeam
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _WN_InferSpaces($sText)
	If Not IsObj($__g_oDicWordCost) Then _WN_LoadWordList()
	Local $iLen = StringLen($sText) + 1
	Local $oDicCost = ObjCreate("Scripting.Dictionary")
	$oDicCost.item(0) = -1

	Local $iMinCost = 0
	Local $iMinCostIndex = 0
	Local $iCurCost = 0.0
	Local $sSubStr = ""
	Local $iIndexI = 0
	Local $iIndexJ = 0

	For $i = 1 To $iLen
		$iMinCost = $oDicCost.Keys()[$i - 1] + 0.9e10
		$iIndexI = $i - 1
		$iMinCostIndex = $iIndexI
		$iIndexI = $iIndexI + 1

		For $j = 1 To $iIndexI
			$iIndexJ = $j
			$sSubStr = StringMid($sText, $iIndexJ, ($iIndexI - $iIndexJ) + 1)
			If Not $__g_oDicWordCost.Exists($sSubStr) Then ContinueLoop
			$iCurCost = $oDicCost.Keys()[$iIndexJ - 1] + $__g_oDicWordCost.Item($sSubStr)
			If ($iMinCost > $iCurCost) Then
				$iMinCost = $iCurCost
				$iMinCostIndex = $iIndexJ - 1
			EndIf
		Next
		$oDicCost.Item($iMinCost) = $iMinCostIndex

	Next


	Local $iN = $iLen - 1
	Local $iPreIndex = 0
	Local $sInsertStr = ""
	Local $aResult[0]

	While $iN > 0
		$iPreIndex = $oDicCost.item($oDicCost.Keys()[$iN])
		$sInsertStr = StringMid($sText, $iPreIndex + 1, ($iN - $iPreIndex))
		If UBound($aResult) > 0 Then
			_ArrayAdd($aResult, $sInsertStr)
		Else
			_ArrayAdd($aResult, $sInsertStr)
		EndIf
		$iN = $iPreIndex
	WEnd

	_ArrayReverse($aResult)

	Local $sOutString = ""
	Local $sWord = ""
	Local $sLastChar = ""
	For $i = 0 To UBound($aResult) - 1
		$sWord = $aResult[$i]
		$sLastChar = StringRight($sOutString, 1)
		If Not ($sWord = "'s") And StringRegExp($sWord, "([A-Za-z])") Then
			If StringIsDigit($sLastChar) Then $sOutString &= " "
			$sOutString &= $sWord & " "
			ContinueLoop
		EndIf

		Switch $sWord

			Case "'s"
				If $sLastChar = " " Then $sOutString = StringLeft($sOutString, StringLen($sOutString) - 1) & $sWord & " "

			Case "'"
				If $sLastChar = " " Then $sOutString = StringLeft($sOutString, StringLen($sOutString) - 1) & $sWord

			Case "."
				If $sLastChar = " " Then $sOutString = StringLeft($sOutString, StringLen($sOutString) - 1) & $sWord & " "

			Case "?"
				If $sLastChar = " " Then $sOutString = StringLeft($sOutString, StringLen($sOutString) - 1) & $sWord & " "

			Case ";"
				If $sLastChar = " " Then $sOutString = StringLeft($sOutString, StringLen($sOutString) - 1) & $sWord & " "

			Case ":"
				If $sLastChar = " " Then $sOutString = StringLeft($sOutString, StringLen($sOutString) - 1) & $sWord & " "

			Case ","
				If $sLastChar = " " Then $sOutString = StringLeft($sOutString, StringLen($sOutString) - 1) & $sWord & " "

			Case "-"
				If $sLastChar = " " Then
					$sOutString = StringLeft($sOutString, StringLen($sOutString) - 1) & $sWord
				Else
					$sOutString &= $sWord
				EndIf

			Case "+"
				If $sLastChar = " " Then
					$sOutString = StringLeft($sOutString, StringLen($sOutString) - 1) & $sWord
				Else
					$sOutString &= $sWord
				EndIf

			Case '"'
				If $sLastChar = " " Then
					$sOutString = StringLeft($sOutString, StringLen($sOutString) - 1) & $sWord & " "
				Else
					$sOutString &= $sWord
				EndIf

			Case '!'
				If $sLastChar = " " Then
					$sOutString = StringLeft($sOutString, StringLen($sOutString) - 1) & $sWord & " "
				Else
					$sOutString &= $sWord
				EndIf

			Case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"
				If StringIsDigit($sWord) Then $sOutString &= $sWord

			Case "["
				$sOutString &= $sWord

			Case "]"
				If $sLastChar = " " Then
					$sOutString = StringLeft($sOutString, StringLen($sOutString) - 1) & $sWord & " "
				Else
					$sOutString &= $sWord
				EndIf

			Case "{"
				$sOutString &= $sWord

			Case "}"
				If $sLastChar = " " Then
					$sOutString = StringLeft($sOutString, StringLen($sOutString) - 1) & $sWord & " "
				Else
					$sOutString &= $sWord
				EndIf

			Case "="
				$sOutString &= $sWord

			Case Else

		EndSwitch
	Next

	Return StringStripWS($sOutString, 3)
EndFunc   ;==>_WN_InferSpaces


; #FUNCTION# ====================================================================================================================
; Name ..........: _WN_Split
; Description ...:
; Syntax ........: _WN_Split($sText)
; Parameters ....: $sText               - a string value.
; Return values .: Array 1D
; Author ........: DanysysTeam
; Modified ......:
; Remarks .......:
; Related .......: _WN_InferSpaces
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _WN_Split($sText)
	Return StringSplit(_WN_InferSpaces($sText), " ", 3)
EndFunc   ;==>_WN_Split


Func _WN_LoadWordList($sFilePath = @ScriptDir & "\english.txt")
	Local $aWords = FileReadToArray($sFilePath)
	Local $oErrorHandler = ObjEvent("AutoIt.Error", "__WN_ErrFunc")
	$__g_oDicWordCost = ObjCreate("Scripting.Dictionary")

	For $i = 0 To UBound($aWords) - 1
		$__g_oDicWordCost.item($aWords[$i]) = (Log(($i + 1) * Log(UBound($aWords))))
	Next
EndFunc   ;==>_WN_LoadWordList

#EndRegion Public Functions


#Region Private Functions

; User's COM error function. Will be called if COM error occurs
Func __WN_ErrFunc($oError)
	; Do anything here.
EndFunc   ;==>__WN_ErrFunc

#EndRegion Private Functions

