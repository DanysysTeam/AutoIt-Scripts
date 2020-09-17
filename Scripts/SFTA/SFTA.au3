#cs Copyright
    Copyright 2020 Danysys. <hello@danysys.com>

    Licensed under the MIT license.
    See LICENSE file or go to https://opensource.org/licenses/MIT for details.
#ce Copyright

#cs Information
    Author(s)......: DanysysTeam (Danyfirex & Dany3j)
    Description....: Set File Type Association Default Application Windows 10
    Version........: 1.0.0
    AutoIt Version.: 3.3.14.5
	Thanks to .....:
					 https://bbs.pediy.com/thread-213954.htm
                     LMongrain - Hash Algorithm PureBasic Version
#ce Information

#Region Settings
#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 6
#EndRegion Settings

#Region Include
#include-once
#include <Crypt.au3>
#include <WinAPIReg.au3>
#include <WinAPIShellEx.au3>
#include <Date.au3>
#EndRegion Include


; #CURRENT# =====================================================================================================================
;_Set_FTA
; ===============================================================================================================================


#Region Public Funcions

; #FUNCTION# ====================================================================================================================
; Name ..........: _Set_FTA
; Description ...:
; Syntax ........: _Set_FTA($sProgId, $sExtension)
; Parameters ....: $sProgId             - Application Program Id.
;                  $sExtension          - File Extension.
; Return values .: Success      - True
;                  Failure      - False
; Author ........: DanysysTeam
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Set_FTA($sProgId, $sExtension)
	Local $sProgIdHash = __FTA_GenerateProgIdHash($sProgId, $sExtension)

	Local $hKey = _WinAPI_RegOpenKey($HKEY_CURRENT_USER, "Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\" & $sExtension & "\UserChoice", $KEY_READ)
	_WinAPI_RegDeleteKey($hKey)
	_WinAPI_RegCloseKey($hKey)

	Local $sRegHash = "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\" & $sExtension & "\UserChoice"
	Local $sRegProgId = "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\" & $sExtension & "\UserChoice"
	RegWrite($sRegHash, "Hash", "REG_SZ", $sProgIdHash)
	RegWrite($sRegProgId, "ProgId", "REG_SZ", $sProgId)
	_WinAPI_ShellChangeNotify($SHCNE_ASSOCCHANGED, $SHCNF_IDLIST, 0, 0)

	Return (RegRead($sRegHash, "Hash") = $sProgIdHash And RegRead($sRegProgId, "ProgId") = $sProgId)
EndFunc   ;==>_SFTA

#EndRegion Public Funcions


#Region #INTERNAL_USE_ONLY#
Func __FTA_GenerateProgIdHash($sProgId, $sExtension)
	Local $sExperienceString = __FTA_GetExperienceString()
	Local $sDateTime = __FTA_GenerateDateTime()
	Local $sUserSid = __FTA_GetUserSid()
	Local $sTextInfo = StringLower($sExtension & $sUserSid & $sProgId & $sDateTime & $sExperienceString)
	Local $sHash = __FTA_GenerateHash($sTextInfo)
	Return $sHash
EndFunc   ;==>__FTA_GenerateProgIdHash


Func __FTA_GetUserSid()
	Local $tSID = _Security__GetAccountSid(@UserName)
	If IsDllStruct($tSID) Then Return _Security__SidToStringSid($tSID)
	Return ""
EndFunc   ;==>__FTA_GetUserSid


Func __FTA_GenerateDateTime()
	Local $tSystem = _Date_Time_GetSystemTime()
	$tSystem.Second = 0
	$tSystem.MSeconds = 0
	Local $tFile = _Date_Time_SystemTimeToFileTime($tSystem)
	Local $tTime = DllStructCreate("wchar Data[17]")
	DllCall("user32.dll", "int:cdecl", "wsprintfW", "ptr", DllStructGetPtr($tTime), "wstr", "%08x%08x", "dword", $tFile.Hi, "dword", $tFile.Lo)
	Local $sTime = $tTime.Data
	Return $sTime
EndFunc   ;==>__FTA_GenerateDateTime


Func __FTA_GetExperienceString()
	Local $sStringToFind = "User Choice set via Windows User Experience"
	Local $i5MB = 1024 * 1024 * 5
	Local $sData = BinaryToString(FileRead(_WinAPI_ShellGetSpecialFolderPath($CSIDL_SYSTEMX86) & "\Shell32.dll", $i5MB), 2)
	Local $iP1 = StringInStr($sData, $sStringToFind, 2)
	Local $iP2 = StringInStr($sData, "}", 2, 1, $iP1)
	Return StringMid($sData, $iP1, $iP2 - $iP1 + 1)
EndFunc   ;==>__FTA_GetExperienceString



Func __FTA_GenerateHash($sTextInfo)

	Local $sbTextInfo = StringToBinary($sTextInfo, 2)
	Local $tbTextInfo = DllStructCreate("Byte Data[" & BinaryLen($sbTextInfo) + 2 & "]")
	$tbTextInfo.Data = $sbTextInfo
	$sbTextInfo = DllStructGetData($tbTextInfo, 1)
	Local $ptbTextInfo = DllStructGetPtr($tbTextInfo, 1)
	Local $iLen = (StringLen($sTextInfo) * 2) + 2

	Local $sbMD5 = _Crypt_HashData($sbTextInfo, $CALG_MD5)
	Local $tMD5 = DllStructCreate("byte Data[" & BinaryLen($sbMD5) / 2 & "]")
	$tMD5.Data = $sbMD5
	Local $pMD5 = DllStructGetPtr($tMD5, 1)
	Local $sbHash = __FTA_Hash($ptbTextInfo, $pMD5, $iLen)

	Local $sHashBase64 = __FTA_Base64Encode($sbHash)
	Return $sHashBase64
EndFunc   ;==>__FTA_GenerateHash


Func __FTA_Hash($ptbTextInfo, $pMD5, $iLen)
	Local $tHash = DllStructCreate("byte Data[16]")
	Local $pHash = DllStructGetPtr($tHash, 1)
	Local $tHashBase = DllStructCreate("byte Data[8]")
	Local $pHashBase = DllStructGetPtr($tHashBase, 1)
	Local $iHLen = (BitAND($iLen, 4) < 1) + __FTA_BitShift($iLen, 2) - 1
	Local Enum $ePDATA, $eCACHE, $eCOUNTER, $eINDEX, $eMD51, $eMD52, $eOUTHASH1, $eOUTHASH2, _
			$eR0, $eR1_0, $eR1_1, $eR2_0, $eR2_1, $eR3, $eR4_0, $eR4_1, $eR5_0, $eR5_1, _
			$eR6_0, $eR6_1, $eR7_0, $eR7_1, $eR7_2, $eR8, $eR9_0, $eR9_1, $eR9_2, $eMAP_SIZE

	If $iHLen < 1 Then Return SetError(1, 0, $tHashBase.Data)

	Local $aMap1[$eMAP_SIZE]
	$aMap1[$eCACHE] = 0
	$aMap1[$eOUTHASH1] = 0
	$aMap1[$ePDATA] = $ptbTextInfo
	$aMap1[$eMD51] = (BitOR(__FTA_PeekL($pMD5), 1) + 0x69FB0000)
	$aMap1[$eMD52] = (BitOR(__FTA_PeekL($pMD5 + 4), 1) + 0x13DB0000)
	$aMap1[$eINDEX] = __FTA_BitShift(($iHLen - 2), 1)
	$aMap1[$eCOUNTER] = $aMap1[$eINDEX] + 1


	While $aMap1[$eCOUNTER]
		$aMap1[$eR0] = __FTA_PeekL($aMap1[$ePDATA]) + $aMap1[$eOUTHASH1]
		$aMap1[$eR1_0] = __FTA_PeekL($aMap1[$ePDATA] + 4)
		$aMap1[$ePDATA] = ($aMap1[$ePDATA] + 8)
		$aMap1[$eR2_0] = ($aMap1[$eR0] * $aMap1[$eMD51]) - (0x10FA9605 * __FTA_BitShift($aMap1[$eR0], 16))
		$aMap1[$eR2_1] = (0x79F8A395 * $aMap1[$eR2_0]) + (0x689B6B9F * __FTA_BitShift($aMap1[$eR2_0], 16))
		$aMap1[$eR3] = ((0xEA970001 * $aMap1[$eR2_1]) - 0x3C101569 * __FTA_BitShift($aMap1[$eR2_1], 16))
		$aMap1[$eR4_0] = $aMap1[$eR3] + $aMap1[$eR1_0]
		$aMap1[$eR5_0] = $aMap1[$eCACHE] + $aMap1[$eR3]
		$aMap1[$eR6_0] = ($aMap1[$eR4_0] * $aMap1[$eMD52]) - (0x3CE8EC25 * __FTA_BitShift($aMap1[$eR4_0], 16))
		$aMap1[$eR6_1] = (0x59C3AF2D * $aMap1[$eR6_0]) - (0x2232E0F1 * __FTA_BitShift($aMap1[$eR6_0], 16))
		$aMap1[$eOUTHASH1] = (0x1EC90001 * $aMap1[$eR6_1]) + (0x35BD1EC9 * __FTA_BitShift($aMap1[$eR6_1], 16))
		$aMap1[$eOUTHASH2] = ($aMap1[$eR5_0] + $aMap1[$eOUTHASH1])
		$aMap1[$eCACHE] = ($aMap1[$eOUTHASH2])
		$aMap1[$eCOUNTER] = $aMap1[$eCOUNTER] - 1
	WEnd

	__FTA_PokeL($pHash, $aMap1[$eOUTHASH1])
	__FTA_PokeL($pHash + 4, $aMap1[$eOUTHASH2])

	Local $aMap2[$eMAP_SIZE]
	$aMap2[$eCACHE] = 0
	$aMap2[$eOUTHASH1] = 0
	$aMap2[$ePDATA] = $ptbTextInfo
	$aMap2[$eMD51] = Number(BitOR(__FTA_PeekL($pMD5), 1), 1)
	$aMap2[$eMD52] = (BitOR(__FTA_PeekL($pMD5 + 4), 1))
	$aMap2[$eINDEX] = __FTA_BitShift(($iHLen - 2), 1)
	$aMap2[$eCOUNTER] = $aMap2[$eINDEX] + 1

	While $aMap2[$eCOUNTER]
		$aMap2[$eR0] = __FTA_PeekL($aMap2[$ePDATA]) + $aMap2[$eOUTHASH1]
		$aMap2[$ePDATA] = ($aMap2[$ePDATA] + 8)
		$aMap2[$eR1_0] = $aMap2[$eR0] * $aMap2[$eMD51]
		$aMap2[$eR1_1] = (0xB1110000 * $aMap2[$eR1_0]) - (0x30674EEF * (__FTA_BitShift($aMap2[$eR1_0], 16)))
		$aMap2[$eR2_0] = (0x5B9F0000 * $aMap2[$eR1_1]) - (0x78F7A461 * (__FTA_BitShift($aMap2[$eR1_1], 16)))
		$aMap2[$eR2_1] = (0x12CEB96D * __FTA_BitShift($aMap2[$eR2_0], 16)) - (0x46930000 * $aMap2[$eR2_0])
		$aMap2[$eR3] = (0x1D830000 * $aMap2[$eR2_1]) + (0x257E1D83 * __FTA_BitShift($aMap2[$eR2_1], 16))
		$aMap2[$eR4_0] = $aMap2[$eMD52] * ($aMap2[$eR3] + (__FTA_PeekL($aMap2[$ePDATA] - 4)))
		$aMap2[$eR4_1] = (0x16F50000 * $aMap2[$eR4_0]) - (0x5D8BE90B * __FTA_BitShift($aMap2[$eR4_0], 16))
		$aMap2[$eR5_0] = (0x96FF0000 * $aMap2[$eR4_1]) - (0x2C7C6901 * __FTA_BitShift($aMap2[$eR4_1], 16))
		$aMap2[$eR5_1] = (0x2B890000 * $aMap2[$eR5_0]) + (0x7C932B89 * __FTA_BitShift($aMap2[$eR5_0], 16))
		$aMap2[$eOUTHASH1] = (0x9F690000 * $aMap2[$eR5_1]) - (0x405B6097 * __FTA_BitShift($aMap2[$eR5_1], 16))
		$aMap2[$eOUTHASH2] = ($aMap2[$eOUTHASH1] + $aMap2[$eCACHE] + $aMap2[$eR3])
		$aMap2[$eCACHE] = $aMap2[$eOUTHASH2]
		$aMap2[$eCOUNTER] = $aMap2[$eCOUNTER] - 1
	WEnd

	__FTA_PokeL($pHash + 8, $aMap2[$eOUTHASH1])
	__FTA_PokeL($pHash + 12, $aMap2[$eOUTHASH2])

	__FTA_PokeL($pHashBase, BitXOR(__FTA_PeekL($pHash + 8), __FTA_PeekL($pHash + 0)))
	__FTA_PokeL($pHashBase + 4, BitXOR(__FTA_PeekL($pHash + 12), __FTA_PeekL($pHash + 4)))

	Return SetError(0, 0, $tHashBase.Data)
EndFunc   ;==>__FTA_Hash


Func __FTA_BitShift($iValue, $iCount)
	Return (BitAND($iValue, 0x80000000) ? BitXOR(BitShift($iValue, $iCount), 0xFFFF0000) : BitShift($iValue, $iCount))
EndFunc   ;==>__FTA_BitShift


Func __FTA_PokeL($pStruct, $iValue)
	Local $tLong = DllStructCreate("long Data", $pStruct)
	$tLong.Data = $iValue
EndFunc   ;==>__FTA_PokeL


Func __FTA_PeekL($pStruct)
	Local $tLong = DllStructCreate("long Data", $pStruct)
	Return $tLong.Data
EndFunc   ;==>__FTA_PeekL


Func __FTA_Base64Encode($input)
	$input = Binary($input)
	Local $struct = DllStructCreate("byte[" & BinaryLen($input) & "]")
	DllStructSetData($struct, 1, $input)
	Local $strc = DllStructCreate("int")

	Local $a_Call = DllCall("Crypt32.dll", "int", "CryptBinaryToString", _
			"ptr", DllStructGetPtr($struct), _
			"int", DllStructGetSize($struct), _
			"int", 1, _
			"ptr", 0, _
			"ptr", DllStructGetPtr($strc))

	If @error Or Not $a_Call[0] Then
		Return SetError(1, 0, "") ; error calculating the length of the buffer needed
	EndIf

	Local $a = DllStructCreate("char[" & DllStructGetData($strc, 1) & "]")

	$a_Call = DllCall("Crypt32.dll", "int", "CryptBinaryToString", _
			"ptr", DllStructGetPtr($struct), _
			"int", DllStructGetSize($struct), _
			"int", 1, _
			"ptr", DllStructGetPtr($a), _
			"ptr", DllStructGetPtr($strc))

	If @error Or Not $a_Call[0] Then
		Return SetError(2, 0, "") ; error encoding
	EndIf

	Return StringReplace(DllStructGetData($a, 1), @CRLF, "")

EndFunc   ;==>__FTA_Base64Encode

#EndRegion #INTERNAL_USE_ONLY#
