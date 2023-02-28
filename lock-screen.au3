#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=AutoItv11.ico
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_Fileversion=2.1.0.2
#AutoIt3Wrapper_Run_After=copy "%outx64%" "%userprofile%\Pictures\Background\lock-screen.exe"
#AutoIt3Wrapper_Run_Tidy=y
#Tidy_Parameters=/reel
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/mo
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#comments-start

	Modified by cramaboule le 28.02.2023

	V2.1.0.2 : Change font to match with W11
	V2.1.0.1 : Improve location
	V2.1.0.0 : Change output to jpg file at 85% quality, Ini file to be able to change keyword search
	V2.0.0.1 : White background centrerd at dimmention of text, text smaller and Verdana
	V2.0.0.0 : API with location centered
	V1.0.0.0 : initial release


#comments-end

If @Compiled Then
	$sBaseFolder = @HomeDrive & @HomePath & '\Pictures\Background'
	DirCreate($sBaseFolder)
Else
	$sBaseFolder = @ScriptDir
EndIf

#include <GDIPlus.au3>
#include <GUIConstantsEx.au3>
#include "Json.au3"

$sFileJson = $sBaseFolder & "\lock-screen.json"
$fileini = $sBaseFolder & "\lock-screen.ini"
$file = $sBaseFolder & "\lockscreen.png"
$file1 = $sBaseFolder & "\lock-screen.jpg"

$ClientID = 'YOUR_KEY_FROM_UNSPLASH.COM'

If FileExists($fileini) Then
	$sQuery = IniRead($fileini, 'Keyword', 'query', 'nature-wallpaper')
Else
	IniWrite($fileini, 'Keyword', 'query', 'nature-wallpaper')
	$sQuery = IniRead($fileini, 'Keyword', 'query', 'nature-wallpaper')
EndIf

$JPGQuality = 85

$sLink = "https://api.unsplash.com/photos/random/?client_id=" & $ClientID & "&query=" & $sQuery ;& "&orientation=landscape"

;~ $text = InetGet("https://api.unsplash.com/photos/random/?client_id=" & $ClientID & "&query=nature-wallpaper&orientation=landscape", @ScriptDir & "\lock-screen.json", 1)
$text = InetGet($sLink, $sFileJson, 1)
;~ ConsoleWrite($sLink & @CRLF)
Sleep(200)

$hFileJson = FileOpen($sFileJson, $FO_UTF8_NOBOM)

$oJson = FileRead($hFileJson)
FileClose($hFileJson)
;~ 	$oJson = FileRead(@ScriptDir & "\collection.json")
$Data1 = Json_Decode($oJson)
$Json3 = Json_Encode($Data1, $Json_PRETTY_PRINT, "  ", "\n", "\n", ",")

;~ ConsoleWrite($Json3 & @CRLF)
$url = Json_Get($Data1, '["urls"]["raw"]') & '&crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&q=85&w=1920&h=1080'
;~ ConsoleWrite($url & @CRLF)
;~ ConsoleWrite(Json_Get($Data1, '["links"]["html"]') & @CRLF)
$sLocation = ''
$sLocation = Json_Get($Data1, '["location"]["title"]')
If (StringStripWS($sLocation, 7) = '' Or StringStripWS($sLocation, 7) = 'null') Then
	$sLocation = Json_Get($Data1, '["location"]["name"]')
	If (StringStripWS($sLocation, 7) = '' Or StringStripWS($sLocation, 7) = 'null') Then
		$sLocation = Json_Get($Data1, '["location"]["city"]')
		If (StringStripWS($sLocation, 7) = '' Or StringStripWS($sLocation, 7) = 'null') Then
			$sLocation = Json_Get($Data1, '["location"]["country"]')
			If (StringStripWS($sLocation, 7) = '' Or StringStripWS($sLocation, 7) = 'null') Then
				$sLocation = Json_Get($Data1, '["description"]')
				If (StringStripWS($sLocation, 7) = '' Or StringStripWS($sLocation, 7) = 'null') Then
					$sLocation = 'No information about Location'
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

;~ 	$string = Json_Dump($Json3)
$Command = 'powershell.exe -Command "(New-Object System.Net.WebClient).DownloadFile(' & Chr(39) & $url & Chr(39) & ', ' & Chr(39) & $file & Chr(39) & ')"'
RunWait($Command, '', @SW_HIDE)
Sleep(100)

_GDIPlus_Startup()
$hImage = _GDIPlus_ImageLoadFromFile($file)
$hGraphics = _GDIPlus_ImageGetGraphicsContext($hImage)
$hBrush1 = _GDIPlus_BrushCreateSolid(0xff000000) ; text color
$hBrush = _GDIPlus_BrushCreateSolid("0x60ffffff") ; layout

;

$hFormat = _GDIPlus_StringFormatCreate()
$hFamily = _GDIPlus_FontFamilyCreate("Segoe UI Variable Small")
$hFont = _GDIPlus_FontCreate($hFamily, 25)
$tLayout = _GDIPlus_RectFCreate(0, 0, 1920) ;x y width of the dray, will be redo in y by _GDIPlus_StringFormatSetAlign centred
_GDIPlus_StringFormatSetAlign($hFormat, 1)
$aInfo = _GDIPlus_GraphicsMeasureString($hGraphics, $sLocation, $hFont, $tLayout, $hFormat)
;
Dim $aDim[5]
$aDim[1] = Int(DllStructGetData($aInfo[0], 1))     ; X
$aDim[2] = Int(DllStructGetData($aInfo[0], 2))     ; Y
$aDim[3] = Int(DllStructGetData($aInfo[0], 3))     ; Width
$aDim[4] = Int(DllStructGetData($aInfo[0], 4))     ; Height
;
_GDIPlus_GraphicsFillRect($hGraphics, $aDim[1], $aDim[2], $aDim[3], 35, $hBrush)
_GDIPlus_GraphicsDrawStringEx($hGraphics, $sLocation, $hFont, $aInfo[0], $hFormat, $hBrush1)
;
;~ $CLSID = _GDIPlus_EncodersGetCLSID("PNG")

$CLSID = _GDIPlus_EncodersGetCLSID("JPG")
$TParam = _GDIPlus_ParamInit(1)
$Datas = DllStructCreate("int Quality")
DllStructSetData($Datas, "Quality", $JPGQuality)
_GDIPlus_ParamAdd($TParam, $GDIP_EPGQUALITY, 1, $GDIP_EPTLONG, DllStructGetPtr($Datas))
$Param = DllStructGetPtr($TParam)
_GDIPlus_ImageSaveToFileEx($hImage, $file1, $CLSID, $Param)

; Clean up resources
_GDIPlus_FontDispose($hFont)
_GDIPlus_FontFamilyDispose($hFamily)
_GDIPlus_StringFormatDispose($hFormat)
_GDIPlus_BrushDispose($hBrush)
_GDIPlus_BrushDispose($hBrush1)
_GDIPlus_GraphicsDispose($hGraphics)
_GDIPlus_Shutdown()

RegWrite('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager', 'RotatingLockScreenEnabled', "REG_DWORD", '000000000')

RegWrite('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP', 'LockScreenImageUrl', "REG_SZ", $file1)

RegWrite('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP', 'LockScreenImagePath', "REG_SZ", $file1)

RegWrite('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP', 'LockScreenImageStatus', "REG_DWORD", '000000001')

