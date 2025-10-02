#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=AutoItv11.ico
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_Fileversion=1.0.0.3
#AutoIt3Wrapper_Res_ProductVersion=1.0.0.3
#AutoIt3Wrapper_Run_After=copy "%outx64%" "%userprofile%\Pictures\Background\lock-screen.exe"
#AutoIt3Wrapper_Run_After=copy "%outx64%" "lock-screen.exe"
#AutoIt3Wrapper_Run_After=copy "%outx64%" "C:\Users\ma\Nextcloud\Cramy\Github\lock-screen"
#AutoIt3Wrapper_Run_After=copy "%in%" "C:\Users\ma\Nextcloud\Cramy\Github\lock-screen"
#AutoIt3Wrapper_Run_Before=WriteTimestampAndVersion.exe "%in%"
#AutoIt3Wrapper_Run_Tidy=y
#Tidy_Parameters=/reel
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/mo
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#Region    ;Timestamp =====================
#    Last compile at : 2025/10/02 13:17:08
#EndRegion ;Timestamp =====================
#cs -----------------------------------------------------------------------------

	Createdd by Marc Arm
	V1.0.0.3 :	24.09.2025
				Unsplash changed the random, so I had to get some other way arround
				all in jpg
	V1.0.0.2 :	24.07.2024
				add: #RequireAdmin (must)
				add: #AutoIt3Wrapper_UseX64=y (must)
	V1.0.0.2 : 	29.06.2024
				remove double backslash
	V1.0.0.1 : 	17.06.2024
				add text to thumbail
	V1.0.0.0 : 	21.11.2023
				initial release

#ce -----------------------------------------------------------------------------

#include <GDIPlus.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <ButtonConstants.au3>
#include <Date.au3>
#include "Json.au3"

If @Compiled Then
	$sBaseFolder = @UserProfileDir & '\Pictures\Background'
Else
	$sBaseFolder = @ScriptDir
EndIf

Global Const $head = ""
Global Const $DesktopWidth = @DesktopWidth, $DesktopHeight = @DesktopHeight
Global Const $sFileJson = $sBaseFolder & "\lock-screen.json"
Global Const $fileini = $sBaseFolder & "\lock-screen.ini"
Global Const $file = $sBaseFolder & "\lockscreen.jpg"
Global Const $filethumb = $sBaseFolder & "\lockscreenThumb.jpg"
Global Const $file1 = $sBaseFolder & "\lock-screen.jpg"
Global Const $ClientID = 'cic9zDBVPUQkXQXZ78d86O79QmowgosybtiKIZUCbeA'
Global Const $JPGQuality = 100
Global $Gui = 0, $pic, $tier, $demitier, $GUI_Button_Next, $GUI_Button_Go, $GUI_Button_Close, $z, $bar, $iItemOnPage = 1

If Not (FileExists($fileini)) Then
	IniWrite($fileini, 'Keyword', 'query', 'nature-wallpaper')
	IniWrite($fileini, "Date", "Date", "2000/01/01")
EndIf

$sQuery = IniRead($fileini, 'Keyword', 'query', 'nature-wallpaper')
$sDate = IniRead($fileini, "Date", "Date", "2000/01/01")

If $CmdLine[0] And $CmdLine[1] = "-a" Then
	If $sDate = _NowCalcDate() Then
		Exit
	EndIf
EndIf

Do
	$bar = WinGetPos("[CLASS:Shell_TrayWnd]")
Until IsArray($bar)

$sUglyLink = "https://api.unsplash.com/search/photos?client_id=***ClientID***&query=***Query***&content_filter=high&page=***Random***&per_page=***Per_page***"

$sLink = _MakeLinks($sUglyLink, $sQuery)

$aArrayInfos = _GetLinks($sLink, $iItemOnPage)
_CreateGUI($aArrayInfos)

While 1
	$msg = GUIGetMsg()
	Select
		Case $msg = $GUI_EVENT_CLOSE Or $msg = $GUI_Button_Close
			_TrayBoxAnimate($Gui, 2, 500)
			Exit
		Case $msg = $GUI_Button_Next
			_TrayBoxAnimate($Gui, 2, 500)
			If $iItemOnPage > 10 Then
				$iItemOnPage = 1
				$sLink = _MakeLinks($sUglyLink, $sQuery)
			Else
				$iItemOnPage += 1
			EndIf
			$aArrayInfos = _GetLinks($sLink, $iItemOnPage)
			_CreateGUI($aArrayInfos)
		Case $msg = $GUI_Button_Go
			ExitLoop
	EndSelect
WEnd

_TrayBoxAnimate($Gui, 2, 500)
GUIDelete($Gui)
; [0]=ubound
; [1]=Source small
; [2]=$SmallWidth
; [3]=$Smallheight
; [4]=Source Big
; [5]=Txt
; [6]=number of item in the json

;~ 	$string = Json_Dump($Json3)
$Command = 'powershell.exe -Command "(New-Object System.Net.WebClient).DownloadFile(' & Chr(39) & $aArrayInfos[4] & Chr(39) & ', ' & Chr(39) & $file & Chr(39) & ')"'
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
$hFont = _GDIPlus_FontCreate($hFamily, 50)
$tLayout = _GDIPlus_RectFCreate(0, 0, 3840) ;x y width of the dray, will be redo in y by _GDIPlus_StringFormatSetAlign centred
_GDIPlus_StringFormatSetAlign($hFormat, 1)
$aInfo = _GDIPlus_GraphicsMeasureString($hGraphics, $aArrayInfos[5], $hFont, $tLayout, $hFormat)
;
Dim $aDim[5]
$aDim[1] = Int(DllStructGetData($aInfo[0], 1))     ; X
$aDim[2] = Int(DllStructGetData($aInfo[0], 2))     ; Y
$aDim[3] = Int(DllStructGetData($aInfo[0], 3))     ; Width
$aDim[4] = Int(DllStructGetData($aInfo[0], 4))     ; Height
;
_GDIPlus_GraphicsFillRect($hGraphics, $aDim[1], $aDim[2], $aDim[3], 65, $hBrush)
_GDIPlus_GraphicsDrawStringEx($hGraphics, $aArrayInfos[5], $hFont, $aInfo[0], $hFormat, $hBrush1)
;
;~ $CLSID = _GDIPlus_EncodersGetCLSID("PNG")

;~ $CLSID = _GDIPlus_EncodersGetCLSID("JPG")
;~ $TParam = _GDIPlus_ParamInit(1)
;~ $Datas = DllStructCreate("int Quality")
;~ DllStructSetData($Datas, "Quality", $JPGQuality)
;~ _GDIPlus_ParamAdd($TParam, $GDIP_EPGQUALITY, 1, $GDIP_EPTLONG, DllStructGetPtr($Datas))
;~ $Param = DllStructGetPtr($TParam)
;~ _GDIPlus_ImageSaveToFileEx($hImage, $file1, $CLSID, $Param)
_GDIPlus_ImageSaveToFile($hImage, $file1)

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

$pid = ShellExecute('RUNDLL32.EXE', 'USER32.DLL,UpdatePerUserSystemParameters 1, True')

IniWrite($fileini, "Date", "Date", _NowCalcDate())

;~ =====================================================================  FUNC  =========================================================

Func _MakeLinks($sRawLink, $sQuery)
	$iRandom = Random(1, 200, 1)
	$iPer_page = 10
	$sURL = StringReplace($sRawLink, '***ClientID***', $ClientID)
	$sURL = StringReplace($sURL, '***Query***', $sQuery)
	$sURL = StringReplace($sURL, '***Per_page***', $iPer_page)
	$sURL = StringReplace($sURL, '***Random***', $iRandom)
	;https://api.unsplash.com/search/photos?client_id=cic9zDBVPUQkXQXZ78d86O79QmowgosybtiKIZUCbeA&query=landscape&content_filter=high&page=57&per_page=10
;~ 	ConsoleWrite($sURL & @CRLF)

	Return $sURL
EndFunc   ;==>_MakeLinks

Func _CreateGUI($Param)
	; [0]=ubound
	; [1]=Source small
	; [2]=$SmallWidth
	; [3]=$Smallheight
	; [4]=Source Big
	; [5]=txt on pics
	; [6]=number of item in the json

	Global $Gui
	If $Gui <> 0 Then GUIDelete($Gui)
	If $Param[2] < 150 Then
		$width = 150 ;need space for the buttons
		$p = 0
	Else
		$width = $Param[2]
		$p = 1
	EndIf
	;

	$Gui = GUICreate($head, $width - 2, $Param[3] + 40 + 20, $DesktopWidth - $width, $DesktopHeight - ($Param[3] + 40 + $bar[3] + 20), BitOR($WS_POPUP, $WS_BORDER))

	$pic = GUICtrlCreatePic($filethumb, (($width - $Param[2]) / 2) - $p, -1, $Param[2], $Param[3], $WS_BORDER)
	$label = GUICtrlCreateLabel($Param[5], 5, $Param[3] + 5, $width - 5, 20)
	$tier = $width / 3
	$demitier = $tier / 2
	$GUI_Button_Next = GUICtrlCreateButton("Change", $demitier - 25, $Param[3] + 5 + 20, 50, 30, BitOR($BS_DEFPUSHBUTTON, $BS_FLAT))
	$GUI_Button_Go = GUICtrlCreateButton("Set", $demitier + $tier - 25, $Param[3] + 5 + 20, 50, 30, $BS_FLAT)
	$GUI_Button_Close = GUICtrlCreateButton("Close", $demitier + $tier + $tier - 25, $Param[3] + 5 + 20, 50, 30, $BS_FLAT)
;~ 	TrayTip("", "", Default)
	_TrayBoxAnimate($Gui, 1, 500)
	GUISetState(@SW_SHOWNA)
EndFunc   ;==>_CreateGUI

Func _TrayBoxAnimate($TBGui, $Xstyle = 1, $Xspeed = 1500)
	; $Xstyle - 1=Fade, 3=Explode, 5=L-Slide, 7=R-Slide, 9=T-Slide, 11=B-Slide,
	;13=TL-Diag-Slide, 15=TR-Diag-Slide, 17=BL-Diag-Slide, 19=BR-Diag-Slide
	Local $Xpick = StringSplit('80000,90000,40010,50010,40001,50002,40002,50001,40004,50008,40008,50004,40005,5000a,40006,50009,40009,50006,4000a,50005', ",")
	DllCall("user32.dll", "int", "AnimateWindow", "hwnd", $TBGui, "int", $Xspeed, "long", "0x000" & $Xpick[$Xstyle])
EndFunc   ;==>_TrayBoxAnimate

Func _GetLinks($sLink, $iNumberOnPage)
	; [0]=ubound
	; [1]=Source small
	; [2]=$SmallWidth
	; [3]=$Smallheight
	; [4]=Source Big
	; [5]=txt on pics
	; [6]=number of item in the json
	Dim $aArrayInfo[7]
	$aArrayInfo[6] = $iNumberOnPage - 1

;~ $text = InetGet("https://api.unsplash.com/photos/random/?client_id=" & $ClientID & "&query=nature-wallpaper&orientation=landscape", @ScriptDir & "\lock-screen.json", 1)
	$text = InetGet($sLink, $sFileJson, 1)
;~ ConsoleWrite($sLink & @CRLF)
	Sleep(200)

	$hFileJson = FileOpen($sFileJson, $FO_UTF8_NOBOM)

	$oJson = FileRead($hFileJson)
	FileClose($hFileJson)
;~ 	$oJson = FileRead(@ScriptDir & "\collection.json")
	$Data1 = Json_Decode($oJson)
;~ 	ConsoleWrite($oJson & @CRLF)
;~ 	$Json3 = Json_Encode($Data1, $Json_PRETTY_PRINT, "  ", "\n", "\n", ",")
;~ 	ConsoleWrite($Json3 & @CRLF)
	$jsonArray = '[results][' & $aArrayInfo[6] & ']'
;~ 	If StringLeft($oJson, 1) = '[' Then
;~ 		$jsonArray = '[0]'
;~ 	EndIf
;~ 	$aArrayInfo[1] = Json_Get($Data1, '[results][0][urls][small]')

	$aArrayInfo[1] = Json_Get($Data1, $jsonArray & '["urls"]["small"]')
;~ 	ConsoleWrite($aArrayInfo[1] & @CRLF)

	$Command = 'powershell.exe -Command "(New-Object System.Net.WebClient).DownloadFile(' & Chr(39) & $aArrayInfo[1] & Chr(39) & ', ' & Chr(39) & $filethumb & Chr(39) & ')"'
	RunWait($Command, '', @SW_HIDE)
	Sleep(10)

	_GDIPlus_Startup()
	$hImage6 = _GDIPlus_ImageLoadFromFile($filethumb)
	$aArrayInfo[2] = _GDIPlus_ImageGetWidth($hImage6)
	$aArrayInfo[3] = _GDIPlus_ImageGetHeight($hImage6)
	_GDIPlus_ImageDispose($hImage6)
	_GDIPlus_Shutdown()

	$aArrayInfo[4] = Json_Get($Data1, $jsonArray & '["urls"]["raw"]') & '&crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&q=' & $JPGQuality & '&w=3840&h=2160'
;~ ConsoleWrite($url & @CRLF)
;~ ConsoleWrite(Json_Get($Data1, '["links"]["html"]') & @CRLF)
	$sLocation = ''
	$sLocation = Json_Get($Data1, $jsonArray & '["location"]["title"]')
	If (StringStripWS($sLocation, 7) = '' Or StringStripWS($sLocation, 7) = 'null') Then
		$sLocation = Json_Get($Data1, $jsonArray & '["location"]["name"]')
		If (StringStripWS($sLocation, 7) = '' Or StringStripWS($sLocation, 7) = 'null') Then
			$sLocation = Json_Get($Data1, $jsonArray & '["location"]["city"]')
			If (StringStripWS($sLocation, 7) = '' Or StringStripWS($sLocation, 7) = 'null') Then
				$sLocation = Json_Get($Data1, $jsonArray & '["location"]["country"]')
				If (StringStripWS($sLocation, 7) = '' Or StringStripWS($sLocation, 7) = 'null') Then
					$sLocation = Json_Get($Data1, $jsonArray & '["description"]')
					If (StringStripWS($sLocation, 7) = '' Or StringStripWS($sLocation, 7) = 'null') Then
						$sLocation = 'No information about Location'
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	$aArrayInfo[5] = $sLocation
	$aArrayInfo[0] = UBound($aArrayInfo) - 1

	Return $aArrayInfo
EndFunc   ;==>_GetLinks
