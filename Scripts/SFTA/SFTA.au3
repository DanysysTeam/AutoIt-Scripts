;~ #AutoIt3Wrapper_UseX64=y
#include <Crypt.au3>
#include <WinAPIReg.au3>
#include <WinAPIShellEx.au3>
#include <Date.au3>


#Region Example
If _SerFileTypeAssociation("Applications\SumatraPDF.exe", ".pdf") Then
	ConsoleWrite(">_SerFileTypeAssociation OK" & @CRLF)
EndIf
#EndRegion Example


Func _SerFileTypeAssociation($sProgId, $sExtension)
	Local $sProgIdHash = _GenerateProgIdHash($sProgId, $sExtension)

	Local $hKey = _WinAPI_RegOpenKey($HKEY_CURRENT_USER, "Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\" & $sExtension & "\UserChoice", $KEY_READ)
	_WinAPI_RegDeleteKey($hKey)
	_WinAPI_RegCloseKey($hKey)

	Local $sRegHash = "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\" & $sExtension & "\UserChoice"
	Local $sRegProgId = "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\" & $sExtension & "\UserChoice"
	RegWrite($sRegHash, "Hash", "REG_SZ", $sProgIdHash)
	RegWrite($sRegProgId, "ProgId", "REG_SZ", $sProgId)
	_WinAPI_ShellChangeNotify($SHCNE_ASSOCCHANGED, $SHCNF_IDLIST, 0, 0)

	Return (RegRead($sRegHash, "Hash") = $sProgIdHash And RegRead($sRegProgId, "ProgId") = $sProgId)
EndFunc   ;==>_SerFileTypeAssociation


Func _GenerateProgIdHash($sProgId, $sExtension)
	Local $sExperienceString = _GetExperienceString()
	Local $sDateTime = _GenerateDateTime()
	Local $sUserSid = _GetUserSid()
	Local $sTextInfo = StringLower($sExtension & $sUserSid & $sProgId & $sDateTime & $sExperienceString)
	Local $sHash = _GenerateHash($sTextInfo)
	Return $sHash
EndFunc   ;==>_GenerateProgIdHash


Func _GetUserSid()
	Local $tSID = _Security__GetAccountSid(@UserName)
	If IsDllStruct($tSID) Then Return _Security__SidToStringSid($tSID)
	Return ""
EndFunc   ;==>_GetUserSid


Func _GenerateDateTime()
	Local $tSystem = _Date_Time_GetSystemTime()
	$tSystem.Second = 0
	$tSystem.MSeconds = 0
	Local $tFile = _Date_Time_SystemTimeToFileTime($tSystem)
	Local $tTime = DllStructCreate("wchar Data[17]")
	Local $aCall = DllCall("user32.dll", "int:cdecl", "wsprintfW", "ptr", DllStructGetPtr($tTime), "wstr", "%08x%08x", "dword", $tFile.Hi, "dword", $tFile.Lo)
	Local $sTime = $tTime.Data
	Return $sTime
EndFunc   ;==>_GenerateDateTime


Func _GetExperienceString()
	Local $sStringToFind = "User Choice set via Windows User Experience"
	Local $i5MB = 1024 * 1024 * 5
	Local $sData = BinaryToString(FileRead(_WinAPI_ShellGetSpecialFolderPath($CSIDL_SYSTEMX86) & "\Shell32.dll", $i5MB), 2)
	Local $iP1 = StringInStr($sData, $sStringToFind, 2)
	Local $iP2 = StringInStr($sData, "}", 2, 1, $iP1)
	Return StringMid($sData, $iP1, $iP2 - $iP1 + 1)
EndFunc   ;==>_GetExperienceString



Func _GenerateHash($sTextInfo)

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
	Local $sbHash = _Hash($ptbTextInfo, $pMD5, $iLen)

	Local $sHashBase64 = _Base64Encode($sbHash)
	Return $sHashBase64
EndFunc   ;==>_GenerateHash

;LMongrain - Hash Algorithm PureBasic Version
Func _Hash($ptbTextInfo, $pMD5, $iLen)
	Local $tHash = DllStructCreate("byte Data[16]")
	Local $pHash = DllStructGetPtr($tHash, 1)
	Local $tHashBase = DllStructCreate("byte Data[8]")
	Local $pHashBase = DllStructGetPtr($tHashBase, 1)
	Local $iHLen = (BitAND($iLen, 4) < 1) + _BitShift($iLen, 2) - 1
	Local Enum $ePDATA, $eCACHE, $eCOUNTER, $eINDEX, $eMD51, $eMD52, $eOUTHASH1, $eOUTHASH2, _
			$eR0, $eR1_0, $eR1_1, $eR2_0, $eR2_1, $eR3, $eR4_0, $eR4_1, $eR5_0, $eR5_1, _
			$eR6_0, $eR6_1, $eR7_0, $eR7_1, $eR7_2, $eR8, $eR9_0, $eR9_1, $eR9_2, $eMAP_SIZE
	Local $aMap1[$eMAP_SIZE]
	If $iHLen < 1 Then Return SetError(1, 0, $tHashBase.Data)

	$aMap1[$eCACHE] = 0
	$aMap1[$eOUTHASH1] = 0
	$aMap1[$ePDATA] = $ptbTextInfo
	$aMap1[$eMD51] = (BitOR(_PeekL($pMD5), 1) + 0x69FB0000)
	$aMap1[$eMD52] = (BitOR(_PeekL($pMD5 + 4), 1) + 0x13DB0000)
	$aMap1[$eINDEX] = _BitShift(($iHLen - 2), 1)
	$aMap1[$eCOUNTER] = $aMap1[$eINDEX] + 1


	While $aMap1[$eCOUNTER]
		$aMap1[$eR0] = _PeekL($aMap1[$ePDATA]) + $aMap1[$eOUTHASH1]
		$aMap1[$eR1_0] = _PeekL($aMap1[$ePDATA] + 4)
		$aMap1[$ePDATA] = ($aMap1[$ePDATA] + 8)
		$aMap1[$eR2_0] = ($aMap1[$eR0] * $aMap1[$eMD51]) - (0x10FA9605 * _BitShift($aMap1[$eR0], 16))
		$aMap1[$eR2_1] = (0x79F8A395 * $aMap1[$eR2_0]) + (0x689B6B9F * _BitShift($aMap1[$eR2_0], 16))
		$aMap1[$eR3] = ((0xEA970001 * $aMap1[$eR2_1]) - 0x3C101569 * _BitShift($aMap1[$eR2_1], 16))
		$aMap1[$eR4_0] = $aMap1[$eR3] + $aMap1[$eR1_0]
		$aMap1[$eR5_0] = $aMap1[$eCACHE] + $aMap1[$eR3]
		$aMap1[$eR6_0] = ($aMap1[$eR4_0] * $aMap1[$eMD52]) - (0x3CE8EC25 * _BitShift($aMap1[$eR4_0], 16))
		$aMap1[$eR6_1] = (0x59C3AF2D * $aMap1[$eR6_0]) - (0x2232E0F1 * _BitShift($aMap1[$eR6_0], 16))
		$aMap1[$eOUTHASH1] = (0x1EC90001 * $aMap1[$eR6_1]) + (0x35BD1EC9 * _BitShift($aMap1[$eR6_1], 16))
		$aMap1[$eOUTHASH2] = ($aMap1[$eR5_0] + $aMap1[$eOUTHASH1])
		$aMap1[$eCACHE] = ($aMap1[$eOUTHASH2])
		$aMap1[$eCOUNTER] = $aMap1[$eCOUNTER] - 1
	WEnd

	_PokeL($pHash, $aMap1[$eOUTHASH1])
	_PokeL($pHash + 4, $aMap1[$eOUTHASH2])

	Local $aMap2[$eMAP_SIZE]
	$aMap2[$eCACHE] = 0
	$aMap2[$eOUTHASH1] = 0
	$aMap2[$ePDATA] = $ptbTextInfo
	$aMap2[$eMD51] = Number(BitOR(_PeekL($pMD5), 1), 1)
	$aMap2[$eMD52] = (BitOR(_PeekL($pMD5 + 4), 1))
	$aMap2[$eINDEX] = _BitShift(($iHLen - 2), 1)
	$aMap2[$eCOUNTER] = $aMap2[$eINDEX] + 1

	While $aMap2[$eCOUNTER]
		$aMap2[$eR0] = _PeekL($aMap2[$ePDATA]) + $aMap2[$eOUTHASH1]
		$aMap2[$ePDATA] = ($aMap2[$ePDATA] + 8)
		$aMap2[$eR1_0] = $aMap2[$eR0] * $aMap2[$eMD51]
		$aMap2[$eR1_1] = (0xB1110000 * $aMap2[$eR1_0]) - (0x30674EEF * (_BitShift($aMap2[$eR1_0], 16)))
		$aMap2[$eR2_0] = (0x5B9F0000 * $aMap2[$eR1_1]) - (0x78F7A461 * (_BitShift($aMap2[$eR1_1], 16)))
		$aMap2[$eR2_1] = (0x12CEB96D * _BitShift($aMap2[$eR2_0], 16)) - (0x46930000 * $aMap2[$eR2_0])
		$aMap2[$eR3] = (0x1D830000 * $aMap2[$eR2_1]) + (0x257E1D83 * _BitShift($aMap2[$eR2_1], 16))
		$aMap2[$eR4_0] = $aMap2[$eMD52] * ($aMap2[$eR3] + (_PeekL($aMap2[$ePDATA] - 4)))
		$aMap2[$eR4_1] = (0x16F50000 * $aMap2[$eR4_0]) - (0x5D8BE90B * _BitShift($aMap2[$eR4_0], 16))
		$aMap2[$eR5_0] = (0x96FF0000 * $aMap2[$eR4_1]) - (0x2C7C6901 * _BitShift($aMap2[$eR4_1], 16))
		$aMap2[$eR5_1] = (0x2B890000 * $aMap2[$eR5_0]) + (0x7C932B89 * _BitShift($aMap2[$eR5_0], 16))
		$aMap2[$eOUTHASH1] = (0x9F690000 * $aMap2[$eR5_1]) - (0x405B6097 * _BitShift($aMap2[$eR5_1], 16))
		$aMap2[$eOUTHASH2] = ($aMap2[$eOUTHASH1] + $aMap2[$eCACHE] + $aMap2[$eR3])
		$aMap2[$eCACHE] = $aMap2[$eOUTHASH2]
		$aMap2[$eCOUNTER] = $aMap2[$eCOUNTER] - 1
	WEnd

	_PokeL($pHash + 8, $aMap2[$eOUTHASH1])
	_PokeL($pHash + 12, $aMap2[$eOUTHASH2])

	_PokeL($pHashBase, BitXOR(_PeekL($pHash + 8), _PeekL($pHash + 0)))
	_PokeL($pHashBase + 4, BitXOR(_PeekL($pHash + 12), _PeekL($pHash + 4)))

	Return SetError(0, 0, $tHashBase.Data)
EndFunc   ;==>_Hash


Func _BitShift($iValue, $iCount)
	Return (BitAND($iValue, 0x80000000) ? BitXOR(BitShift($iValue, $iCount), 0xFFFF0000) : BitShift($iValue, $iCount))
EndFunc   ;==>_BitShift


Func _PokeL($pStruct, $iValue)
	Local $tLong = DllStructCreate("long Data", $pStruct)
	$tLong.Data = $iValue
EndFunc   ;==>_PokeL


Func _PeekL($pStruct)
	Local $tLong = DllStructCreate("long Data", $pStruct)
	Return $tLong.Data
EndFunc   ;==>_PeekL


Func _Base64Encode($input)
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

EndFunc   ;==>_Base64Encode