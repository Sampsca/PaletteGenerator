;
; AutoHotkey Version: 1.1.27.07
; Language:       English
; Platform:       Optimized for Windows 10
; Author:         Sam.
;

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn All, StdOut  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance Force  ; Skips the dialog box and replaces the old instance automatically, which is similar in effect to the Reload command.
#NoTrayIcon

PS_Author:="Sam."
PS_Copyright:="Copyright (c) 2017 Sam Schmitz"

;;; Enable Drag&Drop ;;;
DllCall( "ChangeWindowMessageFilter", uInt, "0x" 49, uint, 1)
DllCall( "ChangeWindowMessageFilter", uInt, "0x" 233, uint, 1)

Global PaletteLookUp ; MPALETTE.BMP
	PaletteLookUp:={}
Global Palette
	Palette:={}
Global Gradient1, Gradient2, Gradient3, Gradient4, Gradient5, Gradient6, Gradient7 ; Set all selected palettes to 0
	Gradient1:=Gradient2:=Gradient3:=Gradient4:=Gradient5:=Gradient6:=Gradient7:=0
Global GradientImages, PaletteImage, TestImage, TestImageRaw, TestImageBytes
	GradientImages:={}, PaletteImage:={}, TestImage:={}, TestImageRaw:="", TestImageBytes:=0
Global pToken
	pToken:=LocalGDIPlus_StartUp()
Global GradientComboBoxOptions, TestImageComboBoxOptions, TestImageCombo, Zoom, CheckBox1, DropDownList1, DropDownList2, MPALETTEDropDownListOptions, Text1, Slider1
	Zoom:=1
Global Pic1, Pic2, Pic3, Pic4, Pic5, Pic6, Pic7, Pic8, Pic9, Pic9Width, Pic9Height
Global OldMPALETTE
	OldMPALETTE:=""

try {
	;LoadPaletteLookUp()
	GenerateMPALETTEDropDownListOptions()
	Loop, %A_ScriptDir%\res\mpalette\*.bmp, 0, 0
		{
		SplitPath, A_LoopFileLongPath, , , , MPALETTEtoload
		LoadPaletteLookUpBMP(MPALETTEtoload)
		Break
		}
	GenerateGradientImages()
	GeneratePalette()
	GenerateTestImageComboBoxOptions()
	Loop, %A_ScriptDir%\res\paperdolls\*.bmp, 0, 0
		{
		TestImageBytes:=LoadTestImage(A_LoopFileLongPath,TestImageRaw)
		Break
		}
	GenerateTestImage(TestImageRaw, TestImageBytes)
	LoadGUIMain()
	GenerateHotkeys()
	Return
} catch e {
	ThrowMsg(16,"Error!","Exception thrown!`n`nWhat	=	" e.what "`nFile	=	" e.file "`nLine	=	" e.line "`nMessage	=	" e.message "`nExtra	=	" e.extra)
	}

GuiDropFiles(GuiHwnd, FileArray, CtrlHwnd, X, Y) {
    for i, file in FileArray
        ImportPalette(file)
}

OnExit:
GuiClose:
	{
	DestroyGradientImages()
	LocalGDIPlus_ShutDown(pToken)
	ExitApp
	}

DestroyGradientImages(){
	For Gradient, Handle in GradientImages
		DllCall("DeleteObject","ptr",Handle)
}

LoadGUIMain(){
	Gui, Destroy

   Gui, Color, 202028, 101020
   Gui, Font, c646481
   Gui, +HwndhGui1

   Gui, Font, bold

   Gui, Add, Button, gRandomColors xm+90, Random Colors
   Gui, Add, Picture, xm vPic1, % "hBitmap:*" GradientImages[Gradient1]
   Gui, Add, Text, xm, Grey Gradient
   Gui, Add, ComboBox, % "w50 vGradient1 gUpdateGUIMain Choose" (Gradient1+1), %GradientComboBoxOptions%
   
   Gui, Add, Text, xp+150 yp, · · · ^

   Gui, Add, Picture, xm vPic2, % "hBitmap:*" GradientImages[Gradient2]
   Gui, Add, Text, xm, Teal Gradient
   Gui, Add, ComboBox, % "w50 vGradient2 gUpdateGUIMain Choose" (Gradient2+1), %GradientComboBoxOptions%

   Gui, Add, Text, xp+150 yp, · · · ^

   Gui, Add, Picture, xm vPic3, % "hBitmap:*" GradientImages[Gradient3]
   Gui, Add, Text, xm, Pink Gradient
   Gui, Add, ComboBox, % "w50 vGradient3 gUpdateGUIMain Choose" (Gradient3+1), %GradientComboBoxOptions%

   Gui, Add, Text, xp+150 yp, · · · ^

   Gui, Add, Picture, xm vPic4, % "hBitmap:*" GradientImages[Gradient4]
   Gui, Add, Text, xm, Yellow Gradient
   Gui, Add, ComboBox, % "w50 vGradient4 gUpdateGUIMain Choose" (Gradient4+1), %GradientComboBoxOptions%

   Gui, Add, Text, xp+150 yp, · · · ^

   Gui, Add, Picture, xm vPic5, % "hBitmap:*" GradientImages[Gradient5]
   Gui, Add, Text, xm, Red Gradient
   Gui, Add, ComboBox, % "w50 vGradient5 gUpdateGUIMain Choose" (Gradient5+1), %GradientComboBoxOptions%

   Gui, Add, Text, xp+150 yp, · · · ^

   Gui, Add, Picture, xm vPic6, % "hBitmap:*" GradientImages[Gradient6]
   Gui, Add, Text, xm, Blue Gradient
   Gui, Add, ComboBox, % "w50 vGradient6 gUpdateGUIMain Choose" (Gradient6+1), %GradientComboBoxOptions%

   Gui, Add, Text, xp+150 yp, · · · ^

   Gui, Add, Picture, xm vPic7, % "hBitmap:*" GradientImages[Gradient7]
   Gui, Add, Text, xm, Green Gradient
   Gui, Add, ComboBox, % "w50 vGradient7 gUpdateGUIMain Choose" (Gradient7+1), %GradientComboBoxOptions%
   
   Gui, Add, Text, xp+150 yp, · · · ^
   
   Gui, Add, Text, section, `n
   Gui, Add, Button, xm+20 default gUpdateGUIMain, View
   Gui, Add, DropDownList, vDropDownList1 Choose6 AltSubmit yp x+30, Adobe ACT|All|Bitmap|Raw/BIN|Visual Bitmap|Windows PAL
   Gui, Add, Button, gExport yp x+m, Export
   Gui, Add, Text, yp-20 xp-130, Export Palette As:
   Gui, Add, Button, gExportBitmap xm+20 y+60, Export Repaletted Bitmap
   Gui, Add, Button, gImportPalette xm+20, Import Palette
   
   Gui, Add, Text, ym Section, Select MPALETTE.bmp:
   Gui, Add, DropDownList, vDropDownList2 gUpdateGUIMain Choose1, %MPALETTEDropDownListOptions%
   Gui, Add, Picture, vPic8 y+20, % "hBitmap:" PaletteImage[1]
   Gui, Add, ComboBox, % "w150 vTestImageCombo gUpdateGUIMain Choose" 1, %TestImageComboBoxOptions%
   ;Gui, Add, CheckBox, vCheckBox1 gUpdateGUIMain x+20 yp+5, Zoom
   Gui, Add, Text, vText1 xp+220 yp-20, Zoom:
   Gui, Add, Slider, Buddy1Text1 vSlider1 gUpdateGUIMain Range-8-8 ToolTip NoTicks AltSubmit, %Zoom%
   Gui, Add, Picture, vPic9 xs, % "hBitmap:" TestImage[1] ;w-1 h%Pic9Height%
   
   Gui, +Resize
   Gui, Show, Autosize Center, Palette Mixer
}

UpdateGUIMain(){
	Critical
	Gui, Submit, NoHide
	ReloadMPALETTE:=(OldMPALETTE<>DropDownList2?1:0)
	LoadPaletteLookUpBMP(DropDownList2)
	Loop, 7
		{
		If (ReloadMPALETTE)
			{
			;GuiControlGet, tmp, , Gradient%A_Index%
			tmp:=Gradient%A_Index%
			GuiControl, , Gradient%A_Index%, % "|" GradientComboBoxOptions
			GuiControl, Choose, Gradient%A_Index%, % tmp+1
			}
		If Gradient%A_Index% is not integer
			{
			Gradient%A_Index%:=0
			GuiControl, Choose, Gradient%A_Index%, 1
			}
		Else If (Gradient%A_Index%<PaletteLookUp.MinIndex()) OR (Gradient%A_Index%>PaletteLookUp.MaxIndex())
			{
			Gradient%A_Index%:=0
			GuiControl, Choose, Gradient%A_Index%, 1
			}
		GuiControl,,Pic%A_Index%, % "hBitmap:*" GradientImages[Gradient%A_Index%]
		}
	GeneratePalette()
	GuiControl,,Pic8, % "hBitmap:" PaletteImage[1]
	IfExist, % A_ScriptDir "\res\paperdolls\" TestImageCombo ".bmp"
		GenerateTestImage(TestImageRaw,TestImageBytes:=LoadTestImage(A_ScriptDir "\res\paperdolls\" TestImageCombo ".bmp",TestImageRaw))
	Else
		GenerateTestImage(TestImageRaw,TestImageBytes)
	;~ If (CheckBox1=1)
		;~ Zoom:=250
	;~ Else
		;~ Zoom:=0
	;Zoom:=Pic9Height*Slider1//100
	Zoom:=Floor(Pic9Height*(Slider1<0?1/Abs(Slider1):Slider1))
	;MsgBox %Pic9Height%`n%Slider1%`n%Zoom%
	GuiControl,,Pic9, % "*w-1 *h" Zoom " hBitmap:" TestImage[1]
}

GenerateHotkeys(){
	Global
	Hotkey, IfWinActive, ahk_id %hGui1%
	Hotkey, F5, UpdateGUIMain
}

RandomColors(){
	Loop, 7
		{
		Random, Random, % PaletteLookUp.MinIndex(), % PaletteLookUp.MaxIndex()
		GuiControl, Choose, Gradient%A_Index%, %Random%
		}
	UpdateGUIMain()
}

Export(){
	Gui, Submit, NoHide
	; Adobe ACT|All|Bitmap|Raw/BIN|Visual Bitmap|Windows Palette
	If (DropDownList1=1)
		Type:="ACT"
	Else If (DropDownList1=2)
		Type:="All"
	Else If (DropDownList1=3)
		Type:="BMP"
	Else If (DropDownList1=4)
		Type:="Raw"
	Else If (DropDownList1=5)
		Type:="BMPV"
	Else If (DropDownList1=6)
		Type:="PAL"
	Gui +OwnDialogs
		FileSelectFile, Path, S2, , Select the path and filename prefix (without extension) for the exported palette.
	If (Path<>"")
		ExportPalette(Type,Path)
}

ExportBitmap(){
	Gui, Submit, NoHide
	Gui +OwnDialogs
		FileSelectFile, Path, S2, , Select the path and filename for the exported repaletted bitmap., Bitmap (*.bmp)
	If (Path<>"")
		{
		SplitPath, Path, , , OutExtension
		If (OutExtension<>"bmp")
			Path.=".bmp"
		ExportBitmapBIN(TestImageRaw,Path)
		}
}

ExportBitmapBIN(ByRef TestImageRaw,Path:=""){
	file0:=FileOpen(Path,"w-d")
		file0.RawWrite(TestImageRaw,TestImageBytes)
	file0.Close()
}

LoadPaletteLookUp(){
	;;;;; Load PaletteLookUp from Palette_Sequences.txt ;;;;;
	FileRead, Data, %A_ScriptDir%\Palette_Sequences.txt
	Loop, Parse, Data, `n, `r
		{
		If (A_LoopField="")
			Continue
		Else IfInString, A_LoopField, GRADIENT
			{
			StringMid, GradientNum, A_LoopField, 17
			Entry:=1 ; Might should be 0 instead of 1
			Triplet:="RR"
			}
		Else
			{
			PaletteLookUp[GradientNum,Entry,Triplet]:=A_LoopField
			PaletteLookUp[GradientNum,Entry,"AA"]:=0
			If (Triplet="RR")
				Triplet:="GG"
			Else If (Triplet="GG")
				Triplet:="BB"
			Else If (Triplet="BB")
				{
				Triplet:="RR"
				Entry+=1
				}
				
			}
		}
	GradientComboBoxOptions:=""
	For key, val in PaletteLookUp
		GradientComboBoxOptions.=key "|"
}

LoadPaletteLookUpBMP(MPALETTE){
	If (OldMPALETTE<>MPALETTE)
		{
		IfExist, %A_ScriptDir%\res\mpalette\%MPALETTE%.bmp
			{
			OldMPALETTE:=MPALETTE
			; http://www.fileformat.info/format/bmp/egff.htm
			/* BMP Version 3 (Microsoft Windows 3.x)
			Offset	Type	Size	Data	Description
			0	WORD	2	FileType	File type, always 4D42h ("BM")
			2	DWORD	4	FileSize	Size of the file in bytes
			6	WORD	2	Reserved1	Always 0
			8	WORD	2	Reserved2	Always 0
			10	DWORD	4	BitmapOffset	Starting position of image data in bytes
			14	DWORD	4	Size	Size of this header in bytes
			18	LONG	4	Width	Image width in pixels
			22	LONG	4	Height	Image height in pixels
			26	WORD	2	Planes	Number of color planes
			28	WORD	2	BitsPerPixel	Number of bits per pixel
			30	DWORD	4	Compression	Compression methods used
			34	DWORD	4	SizeOfBitmap	Size of bitmap in bytes
			38	LONG	4	HorzResolution	Horizontal resolution in pixels per meter
			42	LONG	4	VertResolution	Vertical resolution in pixels per meter
			46	DWORD	4	ColorsUsed	Number of colors in the image
			50	DWORD	4	ColorsImportant	Minimum number of important colors
			*/
			File0:=FileOpen(A_ScriptDir "\res\mpalette\" MPALETTE ".bmp","r-d")
				File0.RawRead(Data,sz:=File0.Length)
			File0.Close()
			file1:=New MemoryFileIO(Data,sz)
				file1.Seek("0","0")
				InputFileSize:=file1.Length
				FileType:=file1.Read("2")		; FileType = "BM"
				FileSize:=file1.ReadUInt()		; FileSize = ?
				Reserved1:=file1.ReadUShort()	; Reserved1 = 0
				Reserved2:=file1.ReadUShort()	; Reserved2 = 0
				BitmapOffset:=file1.ReadUInt()	; BitmapOffset = 54
				Size:=file1.ReadUInt()			; Size = 40
				Width:=file1.ReadInt()			; Width = 12
				Height:=file1.ReadInt()			; Height = 120 or 256
				Planes:=file1.ReadUShort()		; Planes = 1
				BitsPerPixel:=file1.ReadShort()	; BitsPerPixel = 24
				Compression:=file1.ReadUInt()	; Compression = 0
				SizeOfBitmap:=file1.ReadUInt()	; SizeOfBitmap = 0
				HorzResolution:=file1.ReadInt()	; HorzResolution = 2834
				VertResolution:=file1.ReadInt()	; VertResolution = 2834
				ColorsUsed:=file1.ReadUInt()	; ColorsUsed = 0
				ColorsImportant:=file1.ReadUInt() ; ColorsImportant
				file1.Seek(BitmapOffset,0)
			If (FileType="BM") AND (Size=40) AND (Width=12) AND (BitsPerPixel=24) AND (Compression=0)
				{
				ScanLinePadding:=0
				While (Mod(Width+ScanLinePadding,4)>0)
					ScanLinePadding++
				PaletteLookUp:="", PaletteLookUp:={}
				Loop, % Abs(Height)
					{
					GradientNum:=(Height<1?A_Index-1:Abs(Height)-A_Index)
					Loop, %Width%
						{
						PaletteLookUp[GradientNum,A_Index,"BB"]:=file1.ReadUChar()
						PaletteLookUp[GradientNum,A_Index,"GG"]:=file1.ReadUChar()
						PaletteLookUp[GradientNum,A_Index,"RR"]:=file1.ReadUChar()
						PaletteLookUp[GradientNum,A_Index,"AA"]:=0
						}
					}
				}
			Else
				throw { what: (IsFunc(A_ThisFunc)?"function: " A_ThisFunc "()":"") A_Tab (IsLabel(A_ThisLabel)?"label: " A_ThisLabel:""), file: A_LineFile, line: A_LineNumber, message: "ErrorLevel=" ErrorLevel A_Tab "A_LastError=" A_LastError, extra: A_ScriptDir "\res\mpalette\" MPALETTE ".bmp" " is not a valid 24-bit uncompressed Microsoft Windows 3.x MPALETTE.bmp Bitmap."}
			GradientComboBoxOptions:=""
			For key, val in PaletteLookUp
				GradientComboBoxOptions.=key "|"
			DestroyGradientImages()
			GenerateGradientImages()
			}
		}
}

/*
grey = 1
teal = 2
pink = 3
yellow = 4
red = 5
blue = 6
green = 7


grey, teal	= 1,2
grey, pink	= 1,3
grey, yellow	= 1,4
grey, red	= 1,5
grey, blue	= 1,6
grey, green	= 1,7

teal, pink	= 2,3
teal, yellow	= 2,4
teal, red	= 2,5
teal, blue	= 2,6
teal, green	= 2,7

pink, yellow	= 3,4
pink, red	= 3,5
pink, blue	= 3,6
pink, green	= 3,7

yellow, red	= 4,5
yellow, blue	= 4,6
yellow, green	= 4,7

red, blue	= 5,6
red, green	= 5,7

blue, green	= 6,7
*/

GeneratePalette(){
	Gradient:=0
	Entry:=1
	; 0th Gradient spans the first 4 palette entries which are for reserved colors
	Palette[Entry,"RR"]:=0
	Palette[Entry,"GG"]:=255
	Palette[Entry,"BB"]:=0
	Palette[Entry,"AA"]:=0
	Entry+=1
	Palette[Entry,"RR"]:=0
	Palette[Entry,"GG"]:=0
	Palette[Entry,"BB"]:=0
	Palette[Entry,"AA"]:=0
	Entry+=1
	Palette[Entry,"RR"]:=255
	Palette[Entry,"GG"]:=128
	Palette[Entry,"BB"]:=0
	Palette[Entry,"AA"]:=0
	Entry+=1
	Palette[Entry,"RR"]:=255
	Palette[Entry,"GG"]:=128
	Palette[Entry,"BB"]:=0
	Palette[Entry,"AA"]:=0
	Entry+=1
	Gradient+=1
	Loop, 7 ; Next 7 Gradients are not mixed and span 12 palette entries each
		{
		Loop, 12
			{
			LookupID:="Gradient" Gradient
			Palette[Entry,"RR"]:=PaletteLookUp[%LookupID%,A_Index,"RR"]
			Palette[Entry,"GG"]:=PaletteLookUp[%LookupID%,A_Index,"GG"]
			Palette[Entry,"BB"]:=PaletteLookUp[%LookupID%,A_Index,"BB"]
			Palette[Entry,"AA"]:=0
			Entry+=1
			}
		Gradient+=1
		}
	Loop, 6 ; Next 21 Gradients are mixed and span 8 palette entries each
		{
		Index:=A_Index
		Loop, % (7-Index)
			{
			Indexi:=Index+A_Index
			LookupID1:="Gradient" Index
			LookupID2:="Gradient" Indexi
			Loop, 8
				{ ; Eventually we should probably drop the Round and use floor divide instead - done
				Palette[Entry,"RR"]:=(PaletteLookUp[%LookupID1%,A_Index+2,"RR"]+PaletteLookUp[%LookupID2%,A_Index+2,"RR"])//2
				Palette[Entry,"GG"]:=(PaletteLookUp[%LookupID1%,A_Index+2,"GG"]+PaletteLookUp[%LookupID2%,A_Index+2,"GG"])//2
				Palette[Entry,"BB"]:=(PaletteLookUp[%LookupID1%,A_Index+2,"BB"]+PaletteLookUp[%LookupID2%,A_Index+2,"BB"])//2
				Palette[Entry,"AA"]:=0
				Entry+=1
				}
			Gradient+=1
			}
		}
	GeneratePaletteImage()
}

LoadTestImage(InPath,ByRef TestImageRaw){
	file:=FileOpen(InPath,"r-d")
		file.RawRead(TestImageRaw,file.Length)
		Bytes:=file.Length
		file.seek(18,0)
		Pic9Width:=file.ReadInt()
		Pic9Height:=file.ReadInt()
	file.Close()
	Return Bytes
}

GenerateTestImageComboBoxOptions(){
	TestImageComboBoxOptions:=""
	Loop, %A_ScriptDir%\res\paperdolls\*.bmp, 0, 0
		{
		SplitPath, A_LoopFileLongPath, , , , OutNameNoExt
		TestImageComboBoxOptions.=OutNameNoExt "|"
		}
}

GenerateMPALETTEDropDownListOptions(){
	MPALETTEDropDownListOptions:=""
	Loop, %A_ScriptDir%\res\mpalette\*.bmp, 0, 0
		{
		SplitPath, A_LoopFileLongPath, , , , OutNameNoExt
		MPALETTEDropDownListOptions.=OutNameNoExt "|"
		}
}

GenerateTestImage(ByRef TestImageRaw, TestImageBytes){
	TestImageBIN:=New MemoryFileIO(TestImageRaw,TestImageBytes)
	TestImageBIN.Seek(54,0)
	Loop, % (Palette.MaxIndex()-Palette.MinIndex()+1)
		{
		Index:=A_Index
		TestImageBIN.WriteUChar(Palette[Index,"BB"])
		TestImageBIN.WriteUChar(Palette[Index,"GG"])
		TestImageBIN.WriteUChar(Palette[Index,"RR"])
		TestImageBIN.WriteUChar(Palette[Index,"AA"])
		}
	Offset:=TestImageBIN.Tell()
	While Offset<1078
		{
		TestImageBIN.WriteUChar(0)
		Offset++
		}
	TestImage[1]:=GDIPlus_hBitmapFromBuffer(TestImageRaw,TestImageBytes)
	TestImageBIN:=""
}

GenerateGradientImages(){
	TD:="Qk2GDgAAAAAAAHYAAAAoAAAAaAEAABQAAAABAAQAAAAAABAOAAAAAAAAAAAAABAAAAAQAAAAAAAAAAEBAQACAgIAAwMDAAQEBAAFBQUABgYGAAcHBwAICAgACQkJAAoKCgALCwsAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABERERERERERERERERERESIiIiIiIiIiIiIiIiIiIjMzMzMzMzMzMzMzMzMzM0RERERERERERERERERERFVVVVVVVVVVVVVVVVVVVWZmZmZmZmZmZmZmZmZmZnd3d3d3d3d3d3d3d3d3d4iIiIiIiIiIiIiIiIiIiJmZmZmZmZmZmZmZmZmZmaqqqqqqqqqqqqqqqqqqqru7u7u7u7u7u7u7u7u7uwAAAAAAAAAAAAAAAAAAABERERERERERERERERERESIiIiIiIiIiIiIiIiIiIjMzMzMzMzMzMzMzMzMzM0RERERERERERERERERERFVVVVVVVVVVVVVVVVVVVWZmZmZmZmZmZmZmZmZmZnd3d3d3d3d3d3d3d3d3d4iIiIiIiIiIiIiIiIiIiJmZmZmZmZmZmZmZmZmZmaqqqqqqqqqqqqqqqqqqqru7u7u7u7u7u7u7u7u7uwAAAAAAAAAAAAAAAAAAABERERERERERERERERERESIiIiIiIiIiIiIiIiIiIjMzMzMzMzMzMzMzMzMzM0RERERERERERERERERERFVVVVVVVVVVVVVVVVVVVWZmZmZmZmZmZmZmZmZmZnd3d3d3d3d3d3d3d3d3d4iIiIiIiIiIiIiIiIiIiJmZmZmZmZmZmZmZmZmZmaqqqqqqqqqqqqqqqqqqqru7u7u7u7u7u7u7u7u7uwAAAAAAAAAAAAAAAAAAABERERERERERERERERERESIiIiIiIiIiIiIiIiIiIjMzMzMzMzMzMzMzMzMzM0RERERERERERERERERERFVVVVVVVVVVVVVVVVVVVWZmZmZmZmZmZmZmZmZmZnd3d3d3d3d3d3d3d3d3d4iIiIiIiIiIiIiIiIiIiJmZmZmZmZmZmZmZmZmZmaqqqqqqqqqqqqqqqqqqqru7u7u7u7u7u7u7u7u7uwAAAAAAAAAAAAAAAAAAABERERERERERERERERERESIiIiIiIiIiIiIiIiIiIjMzMzMzMzMzMzMzMzMzM0RERERERERERERERERERFVVVVVVVVVVVVVVVVVVVWZmZmZmZmZmZmZmZmZmZnd3d3d3d3d3d3d3d3d3d4iIiIiIiIiIiIiIiIiIiJmZmZmZmZmZmZmZmZmZmaqqqqqqqqqqqqqqqqqqqru7u7u7u7u7u7u7u7u7uwAAAAAAAAAAAAAAAAAAABERERERERERERERERERESIiIiIiIiIiIiIiIiIiIjMzMzMzMzMzMzMzMzMzM0RERERERERERERERERERFVVVVVVVVVVVVVVVVVVVWZmZmZmZmZmZmZmZmZmZnd3d3d3d3d3d3d3d3d3d4iIiIiIiIiIiIiIiIiIiJmZmZmZmZmZmZmZmZmZmaqqqqqqqqqqqqqqqqqqqru7u7u7u7u7u7u7u7u7uwAAAAAAAAAAAAAAAAAAABERERERERERERERERERESIiIiIiIiIiIiIiIiIiIjMzMzMzMzMzMzMzMzMzM0RERERERERERERERERERFVVVVVVVVVVVVVVVVVVVWZmZmZmZmZmZmZmZmZmZnd3d3d3d3d3d3d3d3d3d4iIiIiIiIiIiIiIiIiIiJmZmZmZmZmZmZmZmZmZmaqqqqqqqqqqqqqqqqqqqru7u7u7u7u7u7u7u7u7uwAAAAAAAAAAAAAAAAAAABERERERERERERERERERESIiIiIiIiIiIiIiIiIiIjMzMzMzMzMzMzMzMzMzM0RERERERERERERERERERFVVVVVVVVVVVVVVVVVVVWZmZmZmZmZmZmZmZmZmZnd3d3d3d3d3d3d3d3d3d4iIiIiIiIiIiIiIiIiIiJmZmZmZmZmZmZmZmZmZmaqqqqqqqqqqqqqqqqqqqru7u7u7u7u7u7u7u7u7uwAAAAAAAAAAAAAAAAAAABERERERERERERERERERESIiIiIiIiIiIiIiIiIiIjMzMzMzMzMzMzMzMzMzM0RERERERERERERERERERFVVVVVVVVVVVVVVVVVVVWZmZmZmZmZmZmZmZmZmZnd3d3d3d3d3d3d3d3d3d4iIiIiIiIiIiIiIiIiIiJmZmZmZmZmZmZmZmZmZmaqqqqqqqqqqqqqqqqqqqru7u7u7u7u7u7u7u7u7uwAAAAAAAAAAAAAAAAAAABERERERERERERERERERESIiIiIiIiIiIiIiIiIiIjMzMzMzMzMzMzMzMzMzM0RERERERERERERERERERFVVVVVVVVVVVVVVVVVVVWZmZmZmZmZmZmZmZmZmZnd3d3d3d3d3d3d3d3d3d4iIiIiIiIiIiIiIiIiIiJmZmZmZmZmZmZmZmZmZmaqqqqqqqqqqqqqqqqqqqru7u7u7u7u7u7u7u7u7uwAAAAAAAAAAAAAAAAAAABERERERERERERERERERESIiIiIiIiIiIiIiIiIiIjMzMzMzMzMzMzMzMzMzM0RERERERERERERERERERFVVVVVVVVVVVVVVVVVVVWZmZmZmZmZmZmZmZmZmZnd3d3d3d3d3d3d3d3d3d4iIiIiIiIiIiIiIiIiIiJmZmZmZmZmZmZmZmZmZmaqqqqqqqqqqqqqqqqqqqru7u7u7u7u7u7u7u7u7uwAAAAAAAAAAAAAAAAAAABERERERERERERERERERESIiIiIiIiIiIiIiIiIiIjMzMzMzMzMzMzMzMzMzM0RERERERERERERERERERFVVVVVVVVVVVVVVVVVVVWZmZmZmZmZmZmZmZmZmZnd3d3d3d3d3d3d3d3d3d4iIiIiIiIiIiIiIiIiIiJmZmZmZmZmZmZmZmZmZmaqqqqqqqqqqqqqqqqqqqru7u7u7u7u7u7u7u7u7uwAAAAAAAAAAAAAAAAAAABERERERERERERERERERESIiIiIiIiIiIiIiIiIiIjMzMzMzMzMzMzMzMzMzM0RERERERERERERERERERFVVVVVVVVVVVVVVVVVVVWZmZmZmZmZmZmZmZmZmZnd3d3d3d3d3d3d3d3d3d4iIiIiIiIiIiIiIiIiIiJmZmZmZmZmZmZmZmZmZmaqqqqqqqqqqqqqqqqqqqru7u7u7u7u7u7u7u7u7uwAAAAAAAAAAAAAAAAAAABERERERERERERERERERESIiIiIiIiIiIiIiIiIiIjMzMzMzMzMzMzMzMzMzM0RERERERERERERERERERFVVVVVVVVVVVVVVVVVVVWZmZmZmZmZmZmZmZmZmZnd3d3d3d3d3d3d3d3d3d4iIiIiIiIiIiIiIiIiIiJmZmZmZmZmZmZmZmZmZmaqqqqqqqqqqqqqqqqqqqru7u7u7u7u7u7u7u7u7uwAAAAAAAAAAAAAAAAAAABERERERERERERERERERESIiIiIiIiIiIiIiIiIiIjMzMzMzMzMzMzMzMzMzM0RERERERERERERERERERFVVVVVVVVVVVVVVVVVVVWZmZmZmZmZmZmZmZmZmZnd3d3d3d3d3d3d3d3d3d4iIiIiIiIiIiIiIiIiIiJmZmZmZmZmZmZmZmZmZmaqqqqqqqqqqqqqqqqqqqru7u7u7u7u7u7u7u7u7uwAAAAAAAAAAAAAAAAAAABERERERERERERERERERESIiIiIiIiIiIiIiIiIiIjMzMzMzMzMzMzMzMzMzM0RERERERERERERERERERFVVVVVVVVVVVVVVVVVVVWZmZmZmZmZmZmZmZmZmZnd3d3d3d3d3d3d3d3d3d4iIiIiIiIiIiIiIiIiIiJmZmZmZmZmZmZmZmZmZmaqqqqqqqqqqqqqqqqqqqru7u7u7u7u7u7u7u7u7uwAAAAAAAAAAAAAAAAAAABERERERERERERERERERESIiIiIiIiIiIiIiIiIiIjMzMzMzMzMzMzMzMzMzM0RERERERERERERERERERFVVVVVVVVVVVVVVVVVVVWZmZmZmZmZmZmZmZmZmZnd3d3d3d3d3d3d3d3d3d4iIiIiIiIiIiIiIiIiIiJmZmZmZmZmZmZmZmZmZmaqqqqqqqqqqqqqqqqqqqru7u7u7u7u7u7u7u7u7uwAAAAAAAAAAAAAAAAAAABERERERERERERERERERESIiIiIiIiIiIiIiIiIiIjMzMzMzMzMzMzMzMzMzM0RERERERERERERERERERFVVVVVVVVVVVVVVVVVVVWZmZmZmZmZmZmZmZmZmZnd3d3d3d3d3d3d3d3d3d4iIiIiIiIiIiIiIiIiIiJmZmZmZmZmZmZmZmZmZmaqqqqqqqqqqqqqqqqqqqru7u7u7u7u7u7u7u7u7uwAAAAAAAAAAAAAAAAAAABERERERERERERERERERESIiIiIiIiIiIiIiIiIiIjMzMzMzMzMzMzMzMzMzM0RERERERERERERERERERFVVVVVVVVVVVVVVVVVVVWZmZmZmZmZmZmZmZmZmZnd3d3d3d3d3d3d3d3d3d4iIiIiIiIiIiIiIiIiIiJmZmZmZmZmZmZmZmZmZmaqqqqqqqqqqqqqqqqqqqru7u7u7u7u7u7u7u7u7uwAAAAAAAAAAAAAAAAAAABERERERERERERERERERESIiIiIiIiIiIiIiIiIiIjMzMzMzMzMzMzMzMzMzM0RERERERERERERERERERFVVVVVVVVVVVVVVVVVVVWZmZmZmZmZmZmZmZmZmZnd3d3d3d3d3d3d3d3d3d4iIiIiIiIiIiIiIiIiIiJmZmZmZmZmZmZmZmZmZmaqqqqqqqqqqqqqqqqqqqru7u7u7u7u7u7u7u7u7uw=="
	VarSetCapacity(Out_Data,Bytes:=3718,0)
	ErrorLevel:=DllCall("Crypt32.dll\CryptStringToBinary","Ptr",&TD,"UInt",0,"UInt",1,"Ptr",&Out_Data,"UIntP",Bytes,"Int",0,"Int",0,"CDECL Int")
	If !(ErrorLevel)
		throw { what: (IsFunc(A_ThisFunc)?"function: " A_ThisFunc "()":"") A_Tab (IsLabel(A_ThisLabel)?"label: " A_ThisLabel:""), file: A_LineFile, line: A_LineNumber, message: "ErrorLevel=" ErrorLevel A_Tab "A_LastError=" A_LastError, extra: "CryptStringToBinary Error"}
	TD:=""
	PaletteBIN:=New MemoryFileIO(Out_Data,Bytes)
	Gradient:=PaletteLookUp.MinIndex()
	;pToken:=LocalGDIPlus_StartUp()
	Loop, % (PaletteLookUp.MaxIndex()-PaletteLookUp.MinIndex()+1) ; For each gradient
		{
		PaletteBIN.Seek(54,0)
		Loop, 12 ; For each color in the gradient
			{
			Index:=A_Index
			PaletteBIN.WriteUChar(PaletteLookUp[Gradient,Index,"BB"])
			PaletteBIN.WriteUChar(PaletteLookUp[Gradient,Index,"GG"])
			PaletteBIN.WriteUChar(PaletteLookUp[Gradient,Index,"RR"])
			PaletteBIN.WriteUChar(PaletteLookUp[Gradient,Index,"AA"])
			}
		GradientImages[Gradient]:=GDIPlus_hBitmapFromBuffer(Out_Data,Bytes)
		Gradient++
		}
	;LocalGDIPlus_ShutDown(pToken)
	PaletteBIN:=""
}

GeneratePaletteImage(){
	TD:=""
	Static 4 = "Qk02aAAAAAAAADYEAAAoAAAAQAEAAFAAAAABAAgAAAAAAABkAAAAAAAAAAAAAAABAAAAAQAAAAAAAAEBAQACAgIAAwMDAAQEBAAFBQUABgYGAAcHBwAICAgACQkJAAoKCgALCwsADAwMAA0NDQAODg4ADw8PABAQEAAREREAEhISABMTEwAUFBQAFRUVABYWFgAXFxcAGBgYABkZGQAaGhoAGxsbABwcHAAdHR0AHh4eAB8fHwAgICAAISEhACIiIgAjIyMAJCQkACUlJQAmJiYAJycnACgoKAApKSkAKioqACsrKwAsLCwALS0tAC4uLgAvLy8AMDAwADExMQAyMjIAMzMzADQ0NAA1NTUANjY2ADc3NwA4ODgAOTk5ADo6OgA7OzsAPDw8AD09PQA+Pj4APz8/AEBAQABBQUEAQkJCAENDQwBEREQARUVFAEZGRgBHR0cASEhIAElJSQBKSkoAS0tLAExMTABNTU0ATk5OAE9PTwBQUFAAUVFRAFJSUgBTU1MAVFRUAFVVVQBWVlYAV1dXAFhYWABZWVkAWlpaAFtbWwBcXFwAXV1dAF5eXgBfX18AYGBgAGFhYQBiYmIAY2NjAGRkZABlZWUAZmZmAGdnZwBoaGgAaWlpAGpqagBra2sAbGxsAG1tbQBubm4Ab29vAHBwcABxcXEAcnJyAHNzcwB0dHQAdXV1AHZ2dgB3d3cAeHh4AHl5eQB6enoAe3t7AHx8fAB9fX0Afn5+AH9/fwCAgIAAgYGBAIKCggCDg4MAhISEAIWFhQCGhoYAh4eHAIiIiACJiYkAioqKAIuLiwCMjIwAjY2NAI6OjgCPj48AkJCQAJGRkQCSkpIAk5OTAJSUlACVlZUAlpaWAJeXlwCYmJgAmZmZAJqamgCbm5sAnJycAJ2dnQCenp4An5+fAKCgoAChoaEAoqKiAKOjowCkpKQApaWlAKampgCnp6cAqKioAKmpqQCqqqoAq6urAKysrACtra0Arq6uAK+vrwCwsLAAsbGxALKysgCzs7MAtLS0ALW1tQC2trYAt7e3ALi4uAC5ubkAurq6ALu7uwC8vLwAvb29AL6+vgC/v78AwMDAAMHBwQDCwsIAw8PDAMTExADFxcUAxsbGAMfHxwDIyMgAycnJAMrKygDLy8sAzMzMAM3NzQDOzs4Az8/PANDQ0ADR0dEA0tLSANPT0wDU1NQA1dXVANbW1gDX19cA2NjYANnZ2QDa2toA29vbANzc3ADd3d0A3t7eAN/f3wDg4OAA4eHhAOLi4gDj4+MA5OTkAOXl5QDm5uYA5+fnAOjo6ADp6ekA6urqAOvr6wDs7OwA7e3tAO7u7gDv7+8A8PDwAPHx8QDy8vIA8/PzAPT09AD19fUA9vb2APf39wD4+PgA+fn5APr6+gD7+/sA/Pz8AP39/QD+/v4A////AODg4ODg4ODg4ODh4eHh4eHh4eHh4uLi4uLi4uLi4uPj4+Pj4+Pj4+Pk5OTk5OTk5OTk5eXl5eXl5eXl5ebm5ubm5ubm5ubn5+fn5+fn5+fn6Ojo6Ojo6Ojo6Onp6enp6enp6enq6urq6urq6urq6+vr6+vr6+vr6+zs7Ozs7Ozs7Ozt7e3t7e3t7e3t7u7u7u7u7u7u7u/v7+/v7+/v7+/w8PDw8PDw8PDw8fHx8fHx8fHx8fLy8vLy8vLy8vLz8/Pz8/Pz8/Pz9PT09PT09PT09PX19fX19fX19fX29vb29vb29vb29/f39/f39/f39/j4+Pj4+Pj4+Pj5+fn5+fn5+fn5+vr6+vr6+vr6+vv7+/v7+/v7+/v8/Pz8/Pz8/Pz8/f39/f39/f39/f7+/v7+/v7+/v7/////////////4ODg4ODg4ODg4OHh4eHh4eHh4eHi4uLi4uLi4uLi4+Pj4+Pj4+Pj4+Tk5OTk5OTk5OTl5eXl5eXl5eXl5ubm5ubm5ubm5ufn5+fn5+fn5+fo6Ojo6Ojo6Ojo6enp6enp6enp6erq6urq6urq6urr6+vr6+vr6+vr7Ozs7Ozs7Ozs7O3t7e3t7e3t7e3u7u7u7u7u7u7u7+/v7+/v7+/v7/Dw8PDw8PDw8PDx8fHx8fHx8fHx8vLy8vLy8vLy8vPz8/Pz8/Pz8/P09PT09PT09PT09fX19fX19fX19fb29vb29vb29vb39/f39/f39/f3+Pj4+Pj4+Pj4+Pn5+fn5+fn5+fn6+vr6+vr6+vr6+/v7+/v7+/v7+/z8/Pz8/Pz8/Pz9/f39/f39/f39/v7+/v7+/v7+/v/////////////g4ODg4ODg4ODg4eHh4eHh4eHh4eLi4uLi4uLi4uLj4+Pj4+Pj4+Pj5OTk5OTk5OTk5OXl5eXl5eXl5eXm5ubm5ubm5ubm5+fn5+fn5+fn5+jo6Ojo6Ojo6Ojp6enp6enp6enp6urq6urq6urq6uvr6+vr6+vr6+vs7Ozs7Ozs7Ozs7e3t7e3t7e3t7e7u7u7u7u7u7u7v7+/v7+/v7+/v8PDw8PDw8PDw8PHx8fHx8fHx8fHy8vLy8vLy8vLy8/Pz8/Pz8/Pz8/T09PT09PT09PT19fX19fX19fX19vb29vb29vb29vf39/f39/f39/f4+Pj4+Pj4+Pj4+fn5+fn5+fn5+fr6+vr6+vr6+vr7+/v7+/v7+/v7/Pz8/Pz8/Pz8/P39/f39/f39/f3+/v7+/v7+/v7+/////////////+Dg4ODg4ODg4ODh4eHh4eHh4eHh4uLi4uLi4uLi4uPj4+Pj4+Pj4+Pk5OTk5OTk5OTk5eXl5eXl5eXl5ebm5ubm5ubm5ubn5+fn5+fn5+fn6Ojo6Ojo6Ojo6Onp6enp6enp6enq6urq6urq6urq6+vr6+vr6+vr6+zs7Ozs7Ozs7Ozt7e3t7e3t7e3t7u7u7u7u7u7u7u/v7+/v7+/v7+/w8PDw8PDw8PDw8fHx8fHx8fHx8fLy8vLy8vLy8vLz8/Pz8/Pz8/Pz9PT09PT09PT09PX19fX19fX19fX29vb29vb29vb29/f39/f39/f39/j4+Pj4+Pj4+Pj5+fn5+fn5+fn5+vr6+vr6+vr6+vv7+/v7+/v7+/v8/Pz8/Pz8/Pz8/f39/f39/f39/f7+/v7+/v7+/v7/////////////4ODg4ODg4ODg4OHh4eHh4eHh4eHi4uLi4uLi4uLi4+Pj4+Pj4+Pj4+Tk5OTk5OTk5OTl5eXl5eXl5eXl5ubm5ubm5ubm5ufn5+fn5+fn5+fo6Ojo6Ojo6Ojo6enp6enp6enp6erq6urq6urq6urr6+vr6+vr6+vr7Ozs7Ozs7Ozs7O3t7e3t7e3t7e3u7u7u7u7u7u7u7+/v7+/v7+/v7/Dw8PDw8PDw8PDx8fHx8fHx8fHx8vLy8vLy8vLy8vPz8/Pz8/Pz8/P09PT09PT09PT09fX19fX19fX19fb29vb29vb29vb39/f39/f39/f3+Pj4+Pj4+Pj4+Pn5+fn5+fn5+fn6+vr6+vr6+vr6+/v7+/v7+/v7+/z8/Pz8/Pz8/Pz9/f39/f39/f39/v7+/v7+/v7+/v/////////////g4ODg4ODg4ODg4eHh4eHh4eHh4eLi4uLi4uLi4uLj4+Pj4+Pj4+Pj5OTk5OTk5OTk5OXl5eXl5eXl5eXm5ubm5ubm5ubm5+fn5+fn5+fn5+jo6Ojo6Ojo6Ojp6enp6enp6enp6urq6urq6urq6uvr6+vr6+vr6+vs7Ozs7Ozs7Ozs7e3t7e3t7e3t7e7u7u7u7u7u7u7v7+/v7+/v7+/v8PDw8PDw8PDw8PHx8fHx8fHx8fHy8vLy8vLy8vLy8/Pz8/Pz8/Pz8/T09PT09PT09PT19fX19fX19fX19vb29vb29vb29vf39/f39/f39/f4+Pj4+Pj4+Pj4+fn5+fn5+fn5+fr6+vr6+vr6+vr7+/v7+/v7+/v7/Pz8/Pz8/Pz8/P39/f39/f39/f3+/v7+/v7+/v7+/////////////+Dg4ODg4ODg4ODh4eHh4eHh4eHh4uLi4uLi4uLi4uPj4+Pj4+Pj4+Pk5OTk5OTk5OTk5eXl5eXl5eXl5ebm5ubm5ubm5ubn5+fn5+fn5+fn6Ojo6Ojo6Ojo6Onp6enp6enp6enq6urq6urq6urq6+vr6+vr6+vr6+zs7Ozs7Ozs7Ozt7e3t7e3t7e3t7u7u7u7u7u7u7u/v7+/v7+/v7+/w8PDw8PDw8PDw8fHx8fHx8fHx8fLy8vLy8vLy8vLz8/Pz8/Pz8/Pz9PT09PT09PT09PX19fX19fX19fX29vb29vb29vb29/f39/f39/f39/j4+Pj4+Pj4+Pj5+fn5+fn5+fn5+vr6+vr6+vr6+vv7+/v7+/v7+/v8/Pz8/Pz8/Pz8/f39/f39/f39/f7+/v7+/v7+/v7/////////////4ODg4ODg4ODg4OHh4eHh4eHh4eHi4uLi4uLi4uLi4+Pj4+Pj4+Pj4+Tk5OTk5OTk5OTl5eXl5eXl5eXl5ubm5ubm5ubm5ufn5+fn5+fn5+fo6Ojo6Ojo6Ojo6enp6enp6enp6erq6urq6urq6urr6+vr6+vr6+vr7Ozs7Ozs7Ozs7O3t7e3t7e3t7e3u7u7u7u7u7u7u7+/v7+/v7+/v7/Dw8PDw8PDw8PDx8fHx8fHx8fHx8vLy8vLy8vLy8vPz8/Pz8/Pz8/P09PT09PT09PT09fX19fX19fX19fb29vb29vb29vb39/f39/f39/f3+Pj4+Pj4+Pj4+Pn5+fn5+fn5+fn6+vr6+vr6+vr6+/v7+/v7+/v7+/z8/Pz8/Pz8/Pz9/f39/f39/f39/v7+/v7+/v7+/v/////////////g4ODg4ODg4ODg4eHh4eHh4eHh4eLi4uLi4uLi4uLj4+Pj4+Pj4+Pj5OTk5OTk5OTk5OXl5eXl5eXl5eXm5ubm5ubm5ubm5+fn5+fn5+fn5+jo6Ojo6Ojo6Ojp6enp6enp6enp6urq6urq6urq6uvr6+vr6+vr6+vs7Ozs7Ozs7Ozs7e3t7e3t7e3t7e7u7u7u7u7u7u7v7+/v7+/v7+/v8PDw8PDw8PDw8PHx8fHx8fHx8fHy8vLy8vLy8vLy8/Pz8/Pz8/Pz8/T09PT09PT09PT19fX19fX19fX19vb29vb29vb29vf39/f39/f39/f4+Pj4+Pj4+Pj4+fn5+fn5+fn5+fr6+vr6+vr6+vr7+/v7+/v7+/v7/Pz8/Pz8/Pz8/P39/f39/f39/f3+/v7+/v7+/v7+/////////////+Dg4ODg4ODg4ODh4eHh4eHh4eHh4uLi4uLi4uLi4uPj4+Pj4+Pj4+Pk5OTk5OTk5OTk5eXl5eXl5eXl5ebm5ubm5ubm5ubn5+fn5+fn5+fn6Ojo6Ojo6Ojo6Onp6enp6enp6enq6urq6urq6urq6+vr6+vr6+vr6+zs7Ozs7Ozs7Ozt7e3t7e3t7e3t7u7u7u7u7u7u7u/v7+/v7+/v7+/w8PDw8PDw8PDw8fHx8fHx8fHx8fLy8vLy8vLy8vLz8/Pz8/Pz8/Pz9PT09PT09PT09PX19fX19fX19fX29vb29vb29vb29/f39/f39/f39/j4+Pj4+Pj4+Pj5+fn5+fn5+fn5+vr6+vr6+vr6+vv7+/v7+/v7+/v8/Pz8/Pz8/Pz8/f39/f39/f39/f7+/v7+/v7+/v7/////////////wMDAwMDAwMDAwMHBwcHBwcHBwcHCwsLCwsLCwsLCw8PDw8PDw8PDw8TExMTExMTExMTFxcXFxcXFxcXFxsbGxsbGxsbGxsfHx8fHx8fHx8fIyMjIyMjIyMjIycnJycnJycnJycrKysrKysrKysrLy8vLy8vLy8vLzMzMzMzMzMzMzM3Nzc3Nzc3Nzc3Ozs7Ozs7Ozs7Oz8/Pz8/Pz8/Pz9DQ0NDQ0NDQ0NDR0dHR0dHR0dHR0tLS0tLS0tLS0tPT09PT09PT09PU1NTU1NTU1NTU1dXV1dXV1dXV1dbW1tbW1tbW1tbX19fX19fX19fX2NjY2NjY2NjY2NnZ2dnZ2dnZ2dna2tra2tra2tra29vb29vb29vb29zc3Nzc3Nzc3Nzd3d3d3d3d3d3d3t7e3t7e3t7e3t/f39/f39/f39/AwMDAwMDAwMDAwcHBwcHBwcHBwcLCwsLCwsLCwsLDw8PDw8PDw8PDxMTExMTExMTExMXFxcXFxcXFxcXGxsbGxsbGxsbGx8fHx8fHx8fHx8jIyMjIyMjIyMjJycnJycnJycnJysrKysrKysrKysvLy8vLy8vLy8vMzMzMzMzMzMzMzc3Nzc3Nzc3Nzc7Ozs7Ozs7Ozs7Pz8/Pz8/Pz8/P0NDQ0NDQ0NDQ0NHR0dHR0dHR0dHS0tLS0tLS0tLS09PT09PT09PT09TU1NTU1NTU1NTV1dXV1dXV1dXV1tbW1tbW1tbW1tfX19fX19fX19fY2NjY2NjY2NjY2dnZ2dnZ2dnZ2dra2tra2tra2trb29vb29vb29vb3Nzc3Nzc3Nzc3N3d3d3d3d3d3d3e3t7e3t7e3t7e39/f39/f39/f38DAwMDAwMDAwMDBwcHBwcHBwcHBwsLCwsLCwsLCwsPDw8PDw8PDw8PExMTExMTExMTExcXFxcXFxcXFxcbGxsbGxsbGxsbHx8fHx8fHx8fHyMjIyMjIyMjIyMnJycnJycnJycnKysrKysrKysrKy8vLy8vLy8vLy8zMzMzMzMzMzMzNzc3Nzc3Nzc3Nzs7Ozs7Ozs7Ozs/Pz8/Pz8/Pz8/Q0NDQ0NDQ0NDQ0dHR0dHR0dHR0dLS0tLS0tLS0tLT09PT09PT09PT1NTU1NTU1NTU1NXV1dXV1dXV1dXW1tbW1tbW1tbW19fX19fX19fX19jY2NjY2NjY2NjZ2dnZ2dnZ2dnZ2tra2tra2tra2tvb29vb29vb29vc3Nzc3Nzc3Nzc3d3d3d3d3d3d3d7e3t7e3t7e3t7f39/f39/f39/fwMDAwMDAwMDAwMHBwcHBwcHBwcHCwsLCwsLCwsLCw8PDw8PDw8PDw8TExMTExMTExMTFxcXFxcXFxcXFxsbGxsbGxsbGxsfHx8fHx8fHx8fIyMjIyMjIyMjIycnJycnJycnJycrKysrKysrKysrLy8vLy8vLy8vLzMzMzMzMzMzMzM3Nzc3Nzc3Nzc3Ozs7Ozs7Ozs7Oz8/Pz8/Pz8/Pz9DQ0NDQ0NDQ0NDR0dHR0dHR0dHR0tLS0tLS0tLS0tPT09PT09PT09PU1NTU1NTU1NTU1dXV1dXV1dXV1dbW1tbW1tbW1tbX19fX19fX19fX2NjY2NjY2NjY2NnZ2dnZ2dnZ2dna2tra2tra2tra29vb29vb29vb29zc3Nzc3Nzc3Nzd3d3d3d3d3d3d3t7e3t7e3t7e3t/f39/f39/f39/AwMDAwMDAwMDAwcHBwcHBwcHBwcLCwsLCwsLCwsLDw8PDw8PDw8PDxMTExMTExMTExMXFxcXFxcXFxcXGxsbGxsbGxsbGx8fHx8fHx8fHx8jIyMjIyMjIyMjJycnJycnJycnJysrKysrKysrKysvLy8vLy8vLy8vMzMzMzMzMzMzMzc3Nzc3Nzc3Nzc7Ozs7Ozs7Ozs7Pz8/Pz8/Pz8/P0NDQ0NDQ0NDQ0NHR0dHR0dHR0dHS0tLS0tLS0tLS09PT09PT09PT09TU1NTU1NTU1NTV1dXV1dXV1dXV1tbW1tbW1tbW1tfX19fX19fX19fY2NjY2NjY2NjY2dnZ2dnZ2dnZ2dra2tra2tra2trb29vb29vb29vb3Nzc3Nzc3Nzc3N3d3d3d3d3d3d3e3t7e3t7e3t7e39/f39/f39/f38DAwMDAwMDAwMDBwcHBwcHBwcHBwsLCwsLCwsLCwsPDw8PDw8PDw8PExMTExMTExMTExcXFxcXFxcXFxcbGxsbGxsbGxsbHx8fHx8fHx8fHyMjIyMjIyMjIyMnJycnJycnJycnKysrKysrKysrKy8vLy8vLy8vLy8zMzMzMzMzMzMzNzc3Nzc3Nzc3Nzs7Ozs7Ozs7Ozs/Pz8/Pz8/Pz8/Q0NDQ0NDQ0NDQ0dHR0dHR0dHR0dLS0tLS0tLS0tLT09PT09PT09PT1NTU1NTU1NTU1NXV1dXV1dXV1dXW1tbW1tbW1tbW19fX19fX19fX19jY2NjY2NjY2NjZ2dnZ2dnZ2dnZ2tra2tra2tra2tvb29vb29vb29vc3Nzc3Nzc3Nzc3d3d3d3d3d3d3d7e3t7e3t7e3t7f39/f39/f39/fwMDAwMDAwMDAwMHBwcHBwcHBwcHCwsLCwsLCwsLCw8PDw8PDw8PDw8TExMTExMTExMTFxcXFxcXFxcXFxsbGxsbGxsbGxsfHx8fHx8fHx8fIyMjIyMjIyMjIycnJycnJycnJycrKysrKysrKysrLy8vLy8vLy8vLzMzMzMzMzMzMzM3Nzc3Nzc3Nzc3Ozs7Ozs7Ozs7Oz8/Pz8/Pz8/Pz9DQ0NDQ0NDQ0NDR0dHR0dHR0dHR0tLS0tLS0tLS0tPT09PT09PT09PU1NTU1NTU1NTU1dXV1dXV1dXV1dbW1tbW1tbW1tbX19fX19fX19fX2NjY2NjY2NjY2NnZ2dnZ2dnZ2dna2tra2tra2tra29vb29vb29vb29zc3Nzc3Nzc3Nzd3d3d3d3d3d3d3t7e3t7e3t7e3t/f39/f39/f39/AwMDAwMDAwMDAwcHBwcHBwcHBwcLCwsLCwsLCwsLDw8PDw8PDw8PDxMTExMTExMTExMXFxcXFxcXFxcXGxsbGxsbGxsbGx8fHx8fHx8fHx8jIyMjIyMjIyMjJycnJycnJycnJysrKysrKysrKysvLy8vLy8vLy8vMzMzMzMzMzMzMzc3Nzc3Nzc3Nzc7Ozs7Ozs7Ozs7Pz8/Pz8/Pz8/P0NDQ0NDQ0NDQ0NHR0dHR0dHR0dHS0tLS0tLS0tLS09PT09PT09PT09TU1NTU1NTU1NTV1dXV1dXV1dXV1tbW1tbW1tbW1tfX19fX19fX19fY2NjY2NjY2NjY2dnZ2dnZ2dnZ2dra2tra2tra2trb29vb29vb29vb3Nzc3Nzc3Nzc3N3d3d3d3d3d3d3e3t7e3t7e3t7e39/f39/f39/f38DAwMDAwMDAwMDBwcHBwcHBwcHBwsLCwsLCwsLCwsPDw8PDw8PDw8PExMTExMTExMTExcXFxcXFxcXFxcbGxsbGxsbGxsbHx8fHx8fHx8fHyMjIyMjIyMjIyMnJycnJycnJycnKysrKysrKysrKy8vLy8vLy8vLy8zMzMzMzMzMzMzNzc3Nzc3Nzc3Nzs7Ozs7Ozs7Ozs/Pz8/Pz8/Pz8/Q0NDQ0NDQ0NDQ0dHR0dHR0dHR0dLS0tLS0tLS0tLT09PT09PT09PT1NTU1NTU1NTU1NXV1dXV1dXV1dXW1tbW1tbW1tbW19fX19fX19fX19jY2NjY2NjY2NjZ2dnZ2dnZ2dnZ2tra2tra2tra2tvb29vb29vb29vc3Nzc3Nzc3Nzc3d3d3d3d3d3d3d7e3t7e3t7e3t7f39/f39/f39/fwMDAwMDAwMDAwMHBwcHBwcHBwcHCwsLCwsLCwsLCw8PDw8PDw8PDw8TExMTExMTExMTFxcXFxcXFxcXFxsbGxsbGxsbGxsfHx8fHx8fHx8fIyMjIyMjIyMjIycnJycnJycnJycrKysrKysrKysrLy8vLy8vLy8vLzMzMzMzMzMzMzM3Nzc3Nzc3Nzc3Ozs7Ozs7Ozs7Oz8/Pz8/Pz8/Pz9DQ0NDQ0NDQ0NDR0dHR0dHR0dHR0tLS0tLS0tLS0tPT09PT09PT09PU1NTU1NTU1NTU1dXV1dXV1dXV1dbW1tbW1tbW1tbX19fX19fX19fX2NjY2NjY2NjY2NnZ2dnZ2dnZ2dna2tra2tra2tra29vb29vb29vb29zc3Nzc3Nzc3Nzd3d3d3d3d3d3d3t7e3t7e3t7e3t/f39/f39/f39+goKCgoKCgoKCgoaGhoaGhoaGhoaKioqKioqKioqKjo6Ojo6Ojo6OjpKSkpKSkpKSkpKWlpaWlpaWlpaWmpqampqampqamp6enp6enp6enp6ioqKioqKioqKipqampqampqampqqqqqqqqqqqqqqurq6urq6urq6usrKysrKysrKysra2tra2tra2tra6urq6urq6urq6vr6+vr6+vr6+vsLCwsLCwsLCwsLGxsbGxsbGxsbGysrKysrKysrKys7Ozs7Ozs7Ozs7S0tLS0tLS0tLS1tbW1tbW1tbW1tra2tra2tra2tre3t7e3t7e3t7e4uLi4uLi4uLi4ubm5ubm5ubm5ubq6urq6urq6urq7u7u7u7u7u7u7vLy8vLy8vLy8vL29vb29vb29vb2+vr6+vr6+vr6+v7+/v7+/v7+/v6CgoKCgoKCgoKChoaGhoaGhoaGhoqKioqKioqKioqOjo6Ojo6Ojo6OkpKSkpKSkpKSkpaWlpaWlpaWlpaampqampqampqanp6enp6enp6enqKioqKioqKioqKmpqampqampqamqqqqqqqqqqqqqq6urq6urq6urq6ysrKysrKysrKytra2tra2tra2trq6urq6urq6urq+vr6+vr6+vr6+wsLCwsLCwsLCwsbGxsbGxsbGxsbKysrKysrKysrKzs7Ozs7Ozs7OztLS0tLS0tLS0tLW1tbW1tbW1tbW2tra2tra2tra2t7e3t7e3t7e3t7i4uLi4uLi4uLi5ubm5ubm5ubm5urq6urq6urq6uru7u7u7u7u7u7u8vLy8vLy8vLy8vb29vb29vb29vb6+vr6+vr6+vr6/v7+/v7+/v7+/oKCgoKCgoKCgoKGhoaGhoaGhoaGioqKioqKioqKio6Ojo6Ojo6Ojo6SkpKSkpKSkpKSlpaWlpaWlpaWlpqampqampqampqenp6enp6enp6eoqKioqKioqKioqampqampqampqaqqqqqqqqqqqqqrq6urq6urq6urrKysrKysrKysrK2tra2tra2tra2urq6urq6urq6ur6+vr6+vr6+vr7CwsLCwsLCwsLCxsbGxsbGxsbGxsrKysrKysrKysrOzs7Ozs7Ozs7O0tLS0tLS0tLS0tbW1tbW1tbW1tba2tra2tra2tra3t7e3t7e3t7e3uLi4uLi4uLi4uLm5ubm5ubm5ubm6urq6urq6urq6u7u7u7u7u7u7u7y8vLy8vLy8vLy9vb29vb29vb29vr6+vr6+vr6+vr+/v7+/v7+/v7+goKCgoKCgoKCgoaGhoaGhoaGhoaKioqKioqKioqKjo6Ojo6Ojo6OjpKSkpKSkpKSkpKWlpaWlpaWlpaWmpqampqampqamp6enp6enp6enp6ioqKioqKioqKipqampqampqampqqqqqqqqqqqqqqurq6urq6urq6usrKysrKysrKysra2tra2tra2tra6urq6urq6urq6vr6+vr6+vr6+vsLCwsLCwsLCwsLGxsbGxsbGxsbGysrKysrKysrKys7Ozs7Ozs7Ozs7S0tLS0tLS0tLS1tbW1tbW1tbW1tra2tra2tra2tre3t7e3t7e3t7e4uLi4uLi4uLi4ubm5ubm5ubm5ubq6urq6urq6urq7u7u7u7u7u7u7vLy8vLy8vLy8vL29vb29vb29vb2+vr6+vr6+vr6+v7+/v7+/v7+/v6CgoKCgoKCgoKChoaGhoaGhoaGhoqKioqKioqKioqOjo6Ojo6Ojo6OkpKSkpKSkpKSkpaWlpaWlpaWlpaampqampqampqanp6enp6enp6enqKioqKioqKioqKmpqampqampqamqqqqqqqqqqqqqq6urq6urq6urq6ysrKysrKysrKytra2tra2tra2trq6urq6urq6urq+vr6+vr6+vr6+wsLCwsLCwsLCwsbGxsbGxsbGxsbKysrKysrKysrKzs7Ozs7Ozs7OztLS0tLS0tLS0tLW1tbW1tbW1tbW2tra2tra2tra2t7e3t7e3t7e3t7i4uLi4uLi4uLi5ubm5ubm5ubm5urq6urq6urq6uru7u7u7u7u7u7u8vLy8vLy8vLy8vb29vb29vb29vb6+vr6+vr6+vr6/v7+/v7+/v7+/oKCgoKCgoKCgoKGhoaGhoaGhoaGioqKioqKioqKio6Ojo6Ojo6Ojo6SkpKSkpKSkpKSlpaWlpaWlpaWlpqampqampqampqenp6enp6enp6eoqKioqKioqKioqampqampqampqaqqqqqqqqqqqqqrq6urq6urq6urrKysrKysrKysrK2tra2tra2tra2urq6urq6urq6ur6+vr6+vr6+vr7CwsLCwsLCwsLCxsbGxsbGxsbGxsrKysrKysrKysrOzs7Ozs7Ozs7O0tLS0tLS0tLS0tbW1tbW1tbW1tba2tra2tra2tra3t7e3t7e3t7e3uLi4uLi4uLi4uLm5ubm5ubm5ubm6urq6urq6urq6u7u7u7u7u7u7u7y8vLy8vLy8vLy9vb29vb29vb29vr6+vr6+vr6+vr+/v7+/v7+/v7+goKCgoKCgoKCgoaGhoaGhoaGhoaKioqKioqKioqKjo6Ojo6Ojo6OjpKSkpKSkpKSkpKWlpaWlpaWlpaWmpqampqampqamp6enp6enp6enp6ioqKioqKioqKipqampqampqampqqqqqqqqqqqqqqurq6urq6urq6usrKysrKysrKysra2tra2tra2tra6urq6urq6urq6vr6+vr6+vr6+vsLCwsLCwsLCwsLGxsbGxsbGxsbGysrKysrKysrKys7Ozs7Ozs7Ozs7S0tLS0tLS0tLS1tbW1tbW1tbW1tra2tra2tra2tre3t7e3t7e3t7e4uLi4uLi4uLi4ubm5ubm5ubm5ubq6urq6urq6urq7u7u7u7u7u7u7vLy8vLy8vLy8vL29vb29vb29vb2+vr6+vr6+vr6+v7+/v7+/v7+/v6CgoKCgoKCgoKChoaGhoaGhoaGhoqKioqKioqKioqOjo6Ojo6Ojo6OkpKSkpKSkpKSkpaWlpaWlpaWlpaampqampqampqanp6enp6enp6enqKioqKioqKioqKmpqampqampqamqqqqqqqqqqqqqq6urq6urq6urq6ysrKysrKysrKytra2tra2tra2trq6urq6urq6urq+vr6+vr6+vr6+wsLCwsLCwsLCwsbGxsbGxsbGxsbKysrKysrKysrKzs7Ozs7Ozs7OztLS0tLS0tLS0tLW1tbW1tbW1tbW2tra2tra2tra2t7e3t7e3t7e3t7i4uLi4uLi4uLi5ubm5ubm5ubm5urq6urq6urq6uru7u7u7u7u7u7u8vLy8vLy8vLy8vb29vb29vb29vb6+vr6+vr6+vr6/v7+/v7+/v7+/oKCgoKCgoKCgoKGhoaGhoaGhoaGioqKioqKioqKio6Ojo6Ojo6Ojo6SkpKSkpKSkpKSlpaWlpaWlpaWlpqampqampqampqenp6enp6enp6eoqKioqKioqKioqampqampqampqaqqqqqqqqqqqqqrq6urq6urq6urrKysrKysrKysrK2tra2tra2tra2urq6urq6urq6ur6+vr6+vr6+vr7CwsLCwsLCwsLCxsbGxsbGxsbGxsrKysrKysrKysrOzs7Ozs7Ozs7O0tLS0tLS0tLS0tbW1tbW1tbW1tba2tra2tra2tra3t7e3t7e3t7e3uLi4uLi4uLi4uLm5ubm5ubm5ubm6urq6urq6urq6u7u7u7u7u7u7u7y8vLy8vLy8vLy9vb29vb29vb29vr6+vr6+vr6+vr+/v7+/v7+/v7+goKCgoKCgoKCgoaGhoaGhoaGhoaKioqKioqKioqKjo6Ojo6Ojo6OjpKSkpKSkpKSkpKWlpaWlpaWlpaWmpqampqampqamp6enp6enp6enp6ioqKioqKioqKipqampqampqampqqqqqqqqqqqqqqurq6urq6urq6usrKysrKysrKysra2tra2tra2tra6urq6urq6urq6vr6+vr6+vr6+vsLCwsLCwsLCwsLGxsbGxsbGxsbGysrKysrKysrKys7Ozs7Ozs7Ozs7S0tLS0tLS0tLS1tbW1tbW1tbW1tra2tra2tra2tre3t7e3t7e3t7e4uLi4uLi4uLi4ubm5ubm5ubm5ubq6urq6urq6urq7u7u7u7u7u7u7vLy8vLy8vLy8vL29vb29vb29vb2+vr6+vr6+vr6+v7+/v7+/v7+/v4CAgICAgICAgICBgYGBgYGBgYGBgoKCgoKCgoKCgoODg4ODg4ODg4OEhISEhISEhISEhYWFhYWFhYWFhYaGhoaGhoaGhoaHh4eHh4eHh4eHiIiIiIiIiIiIiImJiYmJiYmJiYmKioqKioqKioqKi4uLi4uLi4uLi4yMjIyMjIyMjIyNjY2NjY2NjY2Njo6Ojo6Ojo6Ojo+Pj4+Pj4+Pj4+QkJCQkJCQkJCQkZGRkZGRkZGRkZKSkpKSkpKSkpKTk5OTk5OTk5OTlJSUlJSUlJSUlJWVlZWVlZWVlZWWlpaWlpaWlpaWl5eXl5eXl5eXl5iYmJiYmJiYmJiZmZmZmZmZmZmZmpqampqampqampubm5ubm5ubm5ucnJycnJycnJycnZ2dnZ2dnZ2dnZ6enp6enp6enp6fn5+fn5+fn5+fgICAgICAgICAgIGBgYGBgYGBgYGCgoKCgoKCgoKCg4ODg4ODg4ODg4SEhISEhISEhISFhYWFhYWFhYWFhoaGhoaGhoaGhoeHh4eHh4eHh4eIiIiIiIiIiIiIiYmJiYmJiYmJiYqKioqKioqKioqLi4uLi4uLi4uLjIyMjIyMjIyMjI2NjY2NjY2NjY2Ojo6Ojo6Ojo6Oj4+Pj4+Pj4+Pj5CQkJCQkJCQkJCRkZGRkZGRkZGRkpKSkpKSkpKSkpOTk5OTk5OTk5OUlJSUlJSUlJSUlZWVlZWVlZWVlZaWlpaWlpaWlpaXl5eXl5eXl5eXmJiYmJiYmJiYmJmZmZmZmZmZmZmampqampqampqam5ubm5ubm5ubm5ycnJycnJycnJydnZ2dnZ2dnZ2dnp6enp6enp6enp+fn5+fn5+fn5+AgICAgICAgICAgYGBgYGBgYGBgYKCgoKCgoKCgoKDg4ODg4ODg4ODhISEhISEhISEhIWFhYWFhYWFhYWGhoaGhoaGhoaGh4eHh4eHh4eHh4iIiIiIiIiIiIiJiYmJiYmJiYmJioqKioqKioqKiouLi4uLi4uLi4uMjIyMjIyMjIyMjY2NjY2NjY2NjY6Ojo6Ojo6Ojo6Pj4+Pj4+Pj4+PkJCQkJCQkJCQkJGRkZGRkZGRkZGSkpKSkpKSkpKSk5OTk5OTk5OTk5SUlJSUlJSUlJSVlZWVlZWVlZWVlpaWlpaWlpaWlpeXl5eXl5eXl5eYmJiYmJiYmJiYmZmZmZmZmZmZmZqampqampqampqbm5ubm5ubm5ubnJycnJycnJycnJ2dnZ2dnZ2dnZ2enp6enp6enp6en5+fn5+fn5+fn4CAgICAgICAgICBgYGBgYGBgYGBgoKCgoKCgoKCgoODg4ODg4ODg4OEhISEhISEhISEhYWFhYWFhYWFhYaGhoaGhoaGhoaHh4eHh4eHh4eHiIiIiIiIiIiIiImJiYmJiYmJiYmKioqKioqKioqKi4uLi4uLi4uLi4yMjIyMjIyMjIyNjY2NjY2NjY2Njo6Ojo6Ojo6Ojo+Pj4+Pj4+Pj4+QkJCQkJCQkJCQkZGRkZGRkZGRkZKSkpKSkpKSkpKTk5OTk5OTk5OTlJSUlJSUlJSUlJWVlZWVlZWVlZWWlpaWlpaWlpaWl5eXl5eXl5eXl5iYmJiYmJiYmJiZmZmZmZmZmZmZmpqampqampqampubm5ubm5ubm5ucnJycnJycnJycnZ2dnZ2dnZ2dnZ6enp6enp6enp6fn5+fn5+fn5+fgICAgICAgICAgIGBgYGBgYGBgYGCgoKCgoKCgoKCg4ODg4ODg4ODg4SE"
	Static 5 = "hISEhISEhISFhYWFhYWFhYWFhoaGhoaGhoaGhoeHh4eHh4eHh4eIiIiIiIiIiIiIiYmJiYmJiYmJiYqKioqKioqKioqLi4uLi4uLi4uLjIyMjIyMjIyMjI2NjY2NjY2NjY2Ojo6Ojo6Ojo6Oj4+Pj4+Pj4+Pj5CQkJCQkJCQkJCRkZGRkZGRkZGRkpKSkpKSkpKSkpOTk5OTk5OTk5OUlJSUlJSUlJSUlZWVlZWVlZWVlZaWlpaWlpaWlpaXl5eXl5eXl5eXmJiYmJiYmJiYmJmZmZmZmZmZmZmampqampqampqam5ubm5ubm5ubm5ycnJycnJycnJydnZ2dnZ2dnZ2dnp6enp6enp6enp+fn5+fn5+fn5+AgICAgICAgICAgYGBgYGBgYGBgYKCgoKCgoKCgoKDg4ODg4ODg4ODhISEhISEhISEhIWFhYWFhYWFhYWGhoaGhoaGhoaGh4eHh4eHh4eHh4iIiIiIiIiIiIiJiYmJiYmJiYmJioqKioqKioqKiouLi4uLi4uLi4uMjIyMjIyMjIyMjY2NjY2NjY2NjY6Ojo6Ojo6Ojo6Pj4+Pj4+Pj4+PkJCQkJCQkJCQkJGRkZGRkZGRkZGSkpKSkpKSkpKSk5OTk5OTk5OTk5SUlJSUlJSUlJSVlZWVlZWVlZWVlpaWlpaWlpaWlpeXl5eXl5eXl5eYmJiYmJiYmJiYmZmZmZmZmZmZmZqampqampqampqbm5ubm5ubm5ubnJycnJycnJycnJ2dnZ2dnZ2dnZ2enp6enp6enp6en5+fn5+fn5+fn4CAgICAgICAgICBgYGBgYGBgYGBgoKCgoKCgoKCgoODg4ODg4ODg4OEhISEhISEhISEhYWFhYWFhYWFhYaGhoaGhoaGhoaHh4eHh4eHh4eHiIiIiIiIiIiIiImJiYmJiYmJiYmKioqKioqKioqKi4uLi4uLi4uLi4yMjIyMjIyMjIyNjY2NjY2NjY2Njo6Ojo6Ojo6Ojo+Pj4+Pj4+Pj4+QkJCQkJCQkJCQkZGRkZGRkZGRkZKSkpKSkpKSkpKTk5OTk5OTk5OTlJSUlJSUlJSUlJWVlZWVlZWVlZWWlpaWlpaWlpaWl5eXl5eXl5eXl5iYmJiYmJiYmJiZmZmZmZmZmZmZmpqampqampqampubm5ubm5ubm5ucnJycnJycnJycnZ2dnZ2dnZ2dnZ6enp6enp6enp6fn5+fn5+fn5+fgICAgICAgICAgIGBgYGBgYGBgYGCgoKCgoKCgoKCg4ODg4ODg4ODg4SEhISEhISEhISFhYWFhYWFhYWFhoaGhoaGhoaGhoeHh4eHh4eHh4eIiIiIiIiIiIiIiYmJiYmJiYmJiYqKioqKioqKioqLi4uLi4uLi4uLjIyMjIyMjIyMjI2NjY2NjY2NjY2Ojo6Ojo6Ojo6Oj4+Pj4+Pj4+Pj5CQkJCQkJCQkJCRkZGRkZGRkZGRkpKSkpKSkpKSkpOTk5OTk5OTk5OUlJSUlJSUlJSUlZWVlZWVlZWVlZaWlpaWlpaWlpaXl5eXl5eXl5eXmJiYmJiYmJiYmJmZmZmZmZmZmZmampqampqampqam5ubm5ubm5ubm5ycnJycnJycnJydnZ2dnZ2dnZ2dnp6enp6enp6enp+fn5+fn5+fn5+AgICAgICAgICAgYGBgYGBgYGBgYKCgoKCgoKCgoKDg4ODg4ODg4ODhISEhISEhISEhIWFhYWFhYWFhYWGhoaGhoaGhoaGh4eHh4eHh4eHh4iIiIiIiIiIiIiJiYmJiYmJiYmJioqKioqKioqKiouLi4uLi4uLi4uMjIyMjIyMjIyMjY2NjY2NjY2NjY6Ojo6Ojo6Ojo6Pj4+Pj4+Pj4+PkJCQkJCQkJCQkJGRkZGRkZGRkZGSkpKSkpKSkpKSk5OTk5OTk5OTk5SUlJSUlJSUlJSVlZWVlZWVlZWVlpaWlpaWlpaWlpeXl5eXl5eXl5eYmJiYmJiYmJiYmZmZmZmZmZmZmZqampqampqampqbm5ubm5ubm5ubnJycnJycnJycnJ2dnZ2dnZ2dnZ2enp6enp6enp6en5+fn5+fn5+fn4CAgICAgICAgICBgYGBgYGBgYGBgoKCgoKCgoKCgoODg4ODg4ODg4OEhISEhISEhISEhYWFhYWFhYWFhYaGhoaGhoaGhoaHh4eHh4eHh4eHiIiIiIiIiIiIiImJiYmJiYmJiYmKioqKioqKioqKi4uLi4uLi4uLi4yMjIyMjIyMjIyNjY2NjY2NjY2Njo6Ojo6Ojo6Ojo+Pj4+Pj4+Pj4+QkJCQkJCQkJCQkZGRkZGRkZGRkZKSkpKSkpKSkpKTk5OTk5OTk5OTlJSUlJSUlJSUlJWVlZWVlZWVlZWWlpaWlpaWlpaWl5eXl5eXl5eXl5iYmJiYmJiYmJiZmZmZmZmZmZmZmpqampqampqampubm5ubm5ubm5ucnJycnJycnJycnZ2dnZ2dnZ2dnZ6enp6enp6enp6fn5+fn5+fn5+fYGBgYGBgYGBgYGFhYWFhYWFhYWFiYmJiYmJiYmJiY2NjY2NjY2NjY2RkZGRkZGRkZGRlZWVlZWVlZWVlZmZmZmZmZmZmZmdnZ2dnZ2dnZ2doaGhoaGhoaGhoaWlpaWlpaWlpaWpqampqampqampra2tra2tra2trbGxsbGxsbGxsbG1tbW1tbW1tbW1ubm5ubm5ubm5ub29vb29vb29vb3BwcHBwcHBwcHBxcXFxcXFxcXFxcnJycnJycnJycnNzc3Nzc3Nzc3N0dHR0dHR0dHR0dXV1dXV1dXV1dXZ2dnZ2dnZ2dnZ3d3d3d3d3d3d3eHh4eHh4eHh4eHl5eXl5eXl5eXl6enp6enp6enp6e3t7e3t7e3t7e3x8fHx8fHx8fHx9fX19fX19fX19fn5+fn5+fn5+fn9/f39/f39/f39gYGBgYGBgYGBgYWFhYWFhYWFhYWJiYmJiYmJiYmJjY2NjY2NjY2NjZGRkZGRkZGRkZGVlZWVlZWVlZWVmZmZmZmZmZmZmZ2dnZ2dnZ2dnZ2hoaGhoaGhoaGhpaWlpaWlpaWlpampqampqampqamtra2tra2tra2tsbGxsbGxsbGxsbW1tbW1tbW1tbW5ubm5ubm5ubm5vb29vb29vb29vcHBwcHBwcHBwcHFxcXFxcXFxcXFycnJycnJycnJyc3Nzc3Nzc3Nzc3R0dHR0dHR0dHR1dXV1dXV1dXV1dnZ2dnZ2dnZ2dnd3d3d3d3d3d3d4eHh4eHh4eHh4eXl5eXl5eXl5eXp6enp6enp6enp7e3t7e3t7e3t7fHx8fHx8fHx8fH19fX19fX19fX1+fn5+fn5+fn5+f39/f39/f39/f2BgYGBgYGBgYGBhYWFhYWFhYWFhYmJiYmJiYmJiYmNjY2NjY2NjY2NkZGRkZGRkZGRkZWVlZWVlZWVlZWZmZmZmZmZmZmZnZ2dnZ2dnZ2dnaGhoaGhoaGhoaGlpaWlpaWlpaWlqampqampqampqa2tra2tra2tra2xsbGxsbGxsbGxtbW1tbW1tbW1tbm5ubm5ubm5ubm9vb29vb29vb29wcHBwcHBwcHBwcXFxcXFxcXFxcXJycnJycnJycnJzc3Nzc3Nzc3NzdHR0dHR0dHR0dHV1dXV1dXV1dXV2dnZ2dnZ2dnZ2d3d3d3d3d3d3d3h4eHh4eHh4eHh5eXl5eXl5eXl5enp6enp6enp6ent7e3t7e3t7e3t8fHx8fHx8fHx8fX19fX19fX19fX5+fn5+fn5+fn5/f39/f39/f39/YGBgYGBgYGBgYGFhYWFhYWFhYWFiYmJiYmJiYmJiY2NjY2NjY2NjY2RkZGRkZGRkZGRlZWVlZWVlZWVlZmZmZmZmZmZmZmdnZ2dnZ2dnZ2doaGhoaGhoaGhoaWlpaWlpaWlpaWpqampqampqampra2tra2tra2trbGxsbGxsbGxsbG1tbW1tbW1tbW1ubm5ubm5ubm5ub29vb29vb29vb3BwcHBwcHBwcHBxcXFxcXFxcXFxcnJycnJycnJycnNzc3Nzc3Nzc3N0dHR0dHR0dHR0dXV1dXV1dXV1dXZ2dnZ2dnZ2dnZ3d3d3d3d3d3d3eHh4eHh4eHh4eHl5eXl5eXl5eXl6enp6enp6enp6e3t7e3t7e3t7e3x8fHx8fHx8fHx9fX19fX19fX19fn5+fn5+fn5+fn9/f39/f39/f39gYGBgYGBgYGBgYWFhYWFhYWFhYWJiYmJiYmJiYmJjY2NjY2NjY2NjZGRkZGRkZGRkZGVlZWVlZWVlZWVmZmZmZmZmZmZmZ2dnZ2dnZ2dnZ2hoaGhoaGhoaGhpaWlpaWlpaWlpampqampqampqamtra2tra2tra2tsbGxsbGxsbGxsbW1tbW1tbW1tbW5ubm5ubm5ubm5vb29vb29vb29vcHBwcHBwcHBwcHFxcXFxcXFxcXFycnJycnJycnJyc3Nzc3Nzc3Nzc3R0dHR0dHR0dHR1dXV1dXV1dXV1dnZ2dnZ2dnZ2dnd3d3d3d3d3d3d4eHh4eHh4eHh4eXl5eXl5eXl5eXp6enp6enp6enp7e3t7e3t7e3t7fHx8fHx8fHx8fH19fX19fX19fX1+fn5+fn5+fn5+f39/f39/f39/f2BgYGBgYGBgYGBhYWFhYWFhYWFhYmJiYmJiYmJiYmNjY2NjY2NjY2NkZGRkZGRkZGRkZWVlZWVlZWVlZWZmZmZmZmZmZmZnZ2dnZ2dnZ2dnaGhoaGhoaGhoaGlpaWlpaWlpaWlqampqampqampqa2tra2tra2tra2xsbGxsbGxsbGxtbW1tbW1tbW1tbm5ubm5ubm5ubm9vb29vb29vb29wcHBwcHBwcHBwcXFxcXFxcXFxcXJycnJycnJycnJzc3Nzc3Nzc3NzdHR0dHR0dHR0dHV1dXV1dXV1dXV2dnZ2dnZ2dnZ2d3d3d3d3d3d3d3h4eHh4eHh4eHh5eXl5eXl5eXl5enp6enp6enp6ent7e3t7e3t7e3t8fHx8fHx8fHx8fX19fX19fX19fX5+fn5+fn5+fn5/f39/f39/f39/YGBgYGBgYGBgYGFhYWFhYWFhYWFiYmJiYmJiYmJiY2NjY2NjY2NjY2RkZGRkZGRkZGRlZWVlZWVlZWVlZmZmZmZmZmZmZmdnZ2dnZ2dnZ2doaGhoaGhoaGhoaWlpaWlpaWlpaWpqampqampqampra2tra2tra2trbGxsbGxsbGxsbG1tbW1tbW1tbW1ubm5ubm5ubm5ub29vb29vb29vb3BwcHBwcHBwcHBxcXFxcXFxcXFxcnJycnJycnJycnNzc3Nzc3Nzc3N0dHR0dHR0dHR0dXV1dXV1dXV1dXZ2dnZ2dnZ2dnZ3d3d3d3d3d3d3eHh4eHh4eHh4eHl5eXl5eXl5eXl6enp6enp6enp6e3t7e3t7e3t7e3x8fHx8fHx8fHx9fX19fX19fX19fn5+fn5+fn5+fn9/f39/f39/f39gYGBgYGBgYGBgYWFhYWFhYWFhYWJiYmJiYmJiYmJjY2NjY2NjY2NjZGRkZGRkZGRkZGVlZWVlZWVlZWVmZmZmZmZmZmZmZ2dnZ2dnZ2dnZ2hoaGhoaGhoaGhpaWlpaWlpaWlpampqampqampqamtra2tra2tra2tsbGxsbGxsbGxsbW1tbW1tbW1tbW5ubm5ubm5ubm5vb29vb29vb29vcHBwcHBwcHBwcHFxcXFxcXFxcXFycnJycnJycnJyc3Nzc3Nzc3Nzc3R0dHR0dHR0dHR1dXV1dXV1dXV1dnZ2dnZ2dnZ2dnd3d3d3d3d3d3d4eHh4eHh4eHh4eXl5eXl5eXl5eXp6enp6enp6enp7e3t7e3t7e3t7fHx8fHx8fHx8fH19fX19fX19fX1+fn5+fn5+fn5+f39/f39/f39/f2BgYGBgYGBgYGBhYWFhYWFhYWFhYmJiYmJiYmJiYmNjY2NjY2NjY2NkZGRkZGRkZGRkZWVlZWVlZWVlZWZmZmZmZmZmZmZnZ2dnZ2dnZ2dnaGhoaGhoaGhoaGlpaWlpaWlpaWlqampqampqampqa2tra2tra2tra2xsbGxsbGxsbGxtbW1tbW1tbW1tbm5ubm5ubm5ubm9vb29vb29vb29wcHBwcHBwcHBwcXFxcXFxcXFxcXJycnJycnJycnJzc3Nzc3Nzc3NzdHR0dHR0dHR0dHV1dXV1dXV1dXV2dnZ2dnZ2dnZ2d3d3d3d3d3d3d3h4eHh4eHh4eHh5eXl5eXl5eXl5enp6enp6enp6ent7e3t7e3t7e3t8fHx8fHx8fHx8fX19fX19fX19fX5+fn5+fn5+fn5/f39/f39/f39/YGBgYGBgYGBgYGFhYWFhYWFhYWFiYmJiYmJiYmJiY2NjY2NjY2NjY2RkZGRkZGRkZGRlZWVlZWVlZWVlZmZmZmZmZmZmZmdnZ2dnZ2dnZ2doaGhoaGhoaGhoaWlpaWlpaWlpaWpqampqampqampra2tra2tra2trbGxsbGxsbGxsbG1tbW1tbW1tbW1ubm5ubm5ubm5ub29vb29vb29vb3BwcHBwcHBwcHBxcXFxcXFxcXFxcnJycnJycnJycnNzc3Nzc3Nzc3N0dHR0dHR0dHR0dXV1dXV1dXV1dXZ2dnZ2dnZ2dnZ3d3d3d3d3d3d3eHh4eHh4eHh4eHl5eXl5eXl5eXl6enp6enp6enp6e3t7e3t7e3t7e3x8fHx8fHx8fHx9fX19fX19fX19fn5+fn5+fn5+fn9/f39/f39/f39AQEBAQEBAQEBAQUFBQUFBQUFBQUJCQkJCQkJCQkJDQ0NDQ0NDQ0NDREREREREREREREVFRUVFRUVFRUVGRkZGRkZGRkZGR0dHR0dHR0dHR0hISEhISEhISEhJSUlJSUlJSUlJSkpKSkpKSkpKSktLS0tLS0tLS0tMTExMTExMTExMTU1NTU1NTU1NTU5OTk5OTk5OTk5PT09PT09PT09PUFBQUFBQUFBQUFFRUVFRUVFRUVFSUlJSUlJSUlJSU1NTU1NTU1NTU1RUVFRUVFRUVFRVVVVVVVVVVVVVVlZWVlZWVlZWVldXV1dXV1dXV1dYWFhYWFhYWFhYWVlZWVlZWVlZWVpaWlpaWlpaWlpbW1tbW1tbW1tbXFxcXFxcXFxcXF1dXV1dXV1dXV1eXl5eXl5eXl5eX19fX19fX19fX0BAQEBAQEBAQEBBQUFBQUFBQUFBQkJCQkJCQkJCQkNDQ0NDQ0NDQ0NERERERERERERERUVFRUVFRUVFRUZGRkZGRkZGRkZHR0dHR0dHR0dHSEhISEhISEhISElJSUlJSUlJSUlKSkpKSkpKSkpKS0tLS0tLS0tLS0xMTExMTExMTExNTU1NTU1NTU1NTk5OTk5OTk5OTk9PT09PT09PT09QUFBQUFBQUFBQUVFRUVFRUVFRUVJSUlJSUlJSUlJTU1NTU1NTU1NTVFRUVFRUVFRUVFVVVVVVVVVVVVVWVlZWVlZWVlZWV1dXV1dXV1dXV1hYWFhYWFhYWFhZWVlZWVlZWVlZWlpaWlpaWlpaWltbW1tbW1tbW1tcXFxcXFxcXFxcXV1dXV1dXV1dXV5eXl5eXl5eXl5fX19fX19fX19fQEBAQEBAQEBAQEFBQUFBQUFBQUFCQkJCQkJCQkJCQ0NDQ0NDQ0NDQ0RERERERERERERFRUVFRUVFRUVFRkZGRkZGRkZGRkdHR0dHR0dHR0dISEhISEhISEhISUlJSUlJSUlJSUpKSkpKSkpKSkpLS0tLS0tLS0tLTExMTExMTExMTE1NTU1NTU1NTU1OTk5OTk5OTk5OT09PT09PT09PT1BQUFBQUFBQUFBRUVFRUVFRUVFRUlJSUlJSUlJSUlNTU1NTU1NTU1NUVFRUVFRUVFRUVVVVVVVVVVVVVVZWVlZWVlZWVlZXV1dXV1dXV1dXWFhYWFhYWFhYWFlZWVlZWVlZWVlaWlpaWlpaWlpaW1tbW1tbW1tbW1xcXFxcXFxcXFxdXV1dXV1dXV1dXl5eXl5eXl5eXl9fX19fX19fX19AQEBAQEBAQEBAQUFBQUFBQUFBQUJCQkJCQkJCQkJDQ0NDQ0NDQ0NDREREREREREREREVFRUVFRUVFRUVGRkZGRkZGRkZGR0dHR0dHR0dHR0hISEhISEhISEhJSUlJSUlJSUlJSkpKSkpKSkpKSktLS0tLS0tLS0tMTExMTExMTExMTU1NTU1NTU1NTU5OTk5OTk5OTk5PT09PT09PT09PUFBQUFBQUFBQUFFRUVFRUVFRUVFSUlJSUlJSUlJSU1NTU1NTU1NTU1RUVFRUVFRUVFRVVVVVVVVVVVVVVlZWVlZWVlZWVldXV1dXV1dXV1dYWFhYWFhYWFhYWVlZWVlZWVlZWVpaWlpaWlpaWlpbW1tbW1tbW1tbXFxcXFxcXFxcXF1dXV1dXV1dXV1eXl5eXl5eXl5eX19fX19fX19fX0BAQEBAQEBAQEBBQUFBQUFBQUFBQkJCQkJCQkJCQkNDQ0NDQ0NDQ0NERERERERERERERUVFRUVFRUVFRUZGRkZGRkZGRkZHR0dHR0dHR0dHSEhISEhISEhISElJSUlJSUlJSUlKSkpKSkpKSkpKS0tLS0tLS0tLS0xMTExMTExMTExNTU1NTU1NTU1NTk5OTk5OTk5OTk9PT09PT09PT09QUFBQUFBQUFBQUVFRUVFRUVFRUVJSUlJSUlJSUlJTU1NTU1NTU1NTVFRUVFRUVFRUVFVVVVVVVVVVVVVWVlZWVlZWVlZWV1dXV1dXV1dXV1hYWFhYWFhYWFhZWVlZWVlZWVlZWlpaWlpaWlpaWltbW1tbW1tbW1tcXFxcXFxcXFxcXV1dXV1dXV1dXV5eXl5eXl5eXl5fX19fX19fX19fQEBAQEBAQEBAQEFBQUFBQUFBQUFCQkJCQkJCQkJCQ0NDQ0NDQ0NDQ0RERERERERERERFRUVFRUVFRUVFRkZGRkZGRkZGRkdHR0dHR0dHR0dISEhISEhISEhISUlJSUlJSUlJSUpKSkpKSkpKSkpLS0tLS0tLS0tLTExMTExMTExMTE1NTU1NTU1NTU1OTk5OTk5OTk5OT09PT09PT09PT1BQUFBQUFBQUFBRUVFRUVFRUVFRUlJSUlJSUlJSUlNTU1NTU1NTU1NUVFRUVFRUVFRUVVVVVVVVVVVVVVZWVlZWVlZWVlZXV1dXV1dXV1dXWFhYWFhYWFhYWFlZWVlZWVlZWVlaWlpaWlpaWlpaW1tbW1tbW1tbW1xcXFxcXFxcXFxdXV1dXV1dXV1dXl5eXl5eXl5eXl9fX19fX19fX19AQEBAQEBAQEBAQUFBQUFBQUFBQUJCQkJCQkJCQkJDQ0NDQ0NDQ0NDREREREREREREREVFRUVFRUVFRUVGRkZGRkZGRkZGR0dHR0dHR0dHR0hISEhISEhISEhJSUlJSUlJSUlJSkpKSkpKSkpKSktLS0tLS0tLS0tMTExMTExMTExMTU1NTU1NTU1NTU5OTk5OTk5OTk5PT09PT09PT09PUFBQUFBQUFBQUFFRUVFRUVFRUVFSUlJSUlJSUlJSU1NTU1NTU1NTU1RUVFRUVFRUVFRVVVVVVVVVVVVVVlZWVlZWVlZWVldXV1dXV1dXV1dYWFhYWFhYWFhYWVlZWVlZWVlZWVpaWlpaWlpaWlpbW1tbW1tbW1tbXFxcXFxcXFxcXF1dXV1dXV1dXV1eXl5eXl5eXl5eX19fX19fX19fX0BAQEBAQEBAQEBBQUFBQUFBQUFBQkJCQkJCQkJCQkNDQ0NDQ0NDQ0NERERERERERERERUVFRUVFRUVFRUZGRkZGRkZGRkZHR0dHR0dHR0dHSEhISEhISEhISElJSUlJSUlJSUlKSkpKSkpKSkpKS0tLS0tLS0tLS0xMTExMTExMTExNTU1NTU1NTU1NTk5OTk5OTk5OTk9PT09PT09PT09QUFBQUFBQUFBQUVFRUVFRUVFRUVJSUlJSUlJSUlJTU1NTU1NTU1NTVFRUVFRUVFRUVFVVVVVVVVVVVVVWVlZWVlZWVlZWV1dXV1dXV1dXV1hYWFhYWFhYWFhZWVlZWVlZWVlZWlpaWlpaWlpaWltbW1tbW1tbW1tcXFxcXFxcXFxcXV1dXV1dXV1dXV5eXl5eXl5eXl5fX19fX19fX19fQEBAQEBAQEBAQEFBQUFBQUFBQUFCQkJCQkJCQkJCQ0NDQ0NDQ0NDQ0RERERERERERERFRUVFRUVFRUVFRkZGRkZGRkZGRkdHR0dHR0dHR0dISEhISEhISEhISUlJSUlJSUlJSUpKSkpKSkpKSkpLS0tLS0tLS0tLTExMTExMTExMTE1NTU1NTU1NTU1OTk5OTk5OTk5OT09PT09PT09PT1BQUFBQUFBQUFBRUVFRUVFRUVFRUlJSUlJSUlJSUlNTU1NTU1NTU1NUVFRUVFRUVFRUVVVVVVVVVVVVVVZWVlZWVlZWVlZXV1dXV1dXV1dXWFhYWFhYWFhYWFlZWVlZWVlZWVlaWlpaWlpaWlpaW1tbW1tbW1tbW1xcXFxcXFxcXFxdXV1dXV1dXV1dXl5eXl5eXl5eXl9fX19fX19fX19AQEBAQEBAQEBAQUFBQUFBQUFBQUJCQkJCQkJCQkJDQ0NDQ0NDQ0NDREREREREREREREVFRUVFRUVFRUVGRkZGRkZGRkZGR0dHR0dHR0dHR0hISEhISEhISEhJSUlJSUlJSUlJSkpKSkpKSkpKSktLS0tLS0tLS0tMTExMTExMTExMTU1NTU1NTU1NTU5OTk5OTk5OTk5PT09PT09PT09PUFBQUFBQUFBQUFFRUVFRUVFRUVFSUlJSUlJSUlJSU1NTU1NTU1NTU1RUVFRUVFRUVFRVVVVVVVVVVVVVVlZWVlZWVlZWVldXV1dXV1dXV1dYWFhYWFhYWFhYWVlZWVlZWVlZWVpaWlpaWlpaWlpbW1tbW1tbW1tbXFxcXFxcXFxcXF1dXV1dXV1dXV1eXl5eXl5eXl5eX19fX19fX19fXyAgICAgICAgICAhISEhISEhISEhIiIiIiIiIiIiIiMjIyMjIyMjIyMkJCQkJCQkJCQkJSUlJSUlJSUlJSYmJiYmJiYmJiYnJycnJycnJycnKCgoKCgoKCgoKCkpKSkpKSkpKSkqKioqKioqKioqKysrKysrKysrKywsLCwsLCwsLCwtLS0tLS0tLS0tLi4uLi4uLi4uLi8vLy8vLy8vLy8wMDAwMDAwMDAwMTExMTExMTExMTIyMjIyMjIyMjIzMzMzMzMzMzMzNDQ0NDQ0NDQ0NDU1NTU1NTU1NTU2NjY2NjY2NjY2Nzc3Nzc3Nzc3Nzg4ODg4ODg4ODg5OTk5OTk5OTk5Ojo6Ojo6Ojo6Ojs7Ozs7Ozs7Ozs8PDw8PDw8PDw8PT09PT09PT09PT4+Pj4+Pj4+Pj4/Pz8/Pz8/Pz8/ICAgICAgICAgICEhISEhISEhISEiIiIiIiIiIiIiIyMjIyMjIyMjIyQkJCQkJCQkJCQlJSUlJSUlJSUlJiYmJiYmJiYmJicnJycnJycnJycoKCgoKCgoKCgoKSkpKSkpKSkpKSoqKioqKioqKiorKysrKysrKysrLCwsLCwsLCwsLC0tLS0tLS0tLS0uLi4uLi4uLi4uLy8vLy8vLy8vLzAwMDAwMDAwMDAxMTExMTExMTExMjIyMjIyMjIyMjMzMzMzMzMzMzM0NDQ0NDQ0NDQ0NTU1NTU1NTU1NTY2NjY2NjY2NjY3Nzc3Nzc3Nzc3ODg4ODg4ODg4ODk5OTk5OTk5OTk6Ojo6Ojo6Ojo6Ozs7Ozs7Ozs7Ozw8PDw8PDw8PDw9PT09PT09PT09Pj4+Pj4+Pj4+Pj8/Pz8/Pz8/Pz8gICAgICAgICAgISEhISEhISEhISIiIiIiIiIiIiIjIyMjIyMjIyMjJCQkJCQkJCQkJCUlJSUlJSUlJSUmJiYmJiYmJiYmJycnJycnJycnJygoKCgoKCgoKCgpKSkpKSkpKSkpKioqKioqKioqKisrKysrKysrKyssLCwsLCwsLCwsLS0tLS0tLS0tLS4uLi4uLi4uLi4vLy8vLy8vLy8vMDAwMDAwMDAwMDExMTExMTExMTEyMjIyMjIyMjIyMzMzMzMzMzMzMzQ0NDQ0NDQ0NDQ1NTU1NTU1NTU1NjY2NjY2NjY2Njc3Nzc3Nzc3Nzc4ODg4ODg4ODg4OTk5OTk5OTk5OTo6Ojo6Ojo6Ojo7Ozs7Ozs7Ozs7PDw8PDw8PDw8PD09PT09PT09PT0+Pj4+Pj4+Pj4+Pz8/Pz8/Pz8/PyAgICAgICAgICAhISEhISEhISEhIiIiIiIiIiIiIiMjIyMjIyMjIyMkJCQkJCQkJCQkJSUlJSUlJSUlJSYmJiYmJiYmJiYnJycnJycnJycnKCgoKCgoKCgoKCkpKSkpKSkpKSkqKioqKioqKioqKysrKysrKysrKywsLCwsLCwsLCwtLS0tLS0tLS0tLi4uLi4uLi4uLi8vLy8vLy8vLy8wMDAwMDAwMDAwMTExMTExMTExMTIyMjIyMjIyMjIzMzMzMzMzMzMzNDQ0NDQ0NDQ0NDU1NTU1NTU1NTU2NjY2NjY2NjY2Nzc3Nzc3Nzc3Nzg4ODg4ODg4ODg5OTk5OTk5OTk5Ojo6Ojo6Ojo6Ojs7Ozs7Ozs7Ozs8PDw8PDw8PDw8PT09PT09PT09PT4+Pj4+Pj4+Pj4/Pz8/Pz8/Pz8/ICAgICAgICAgICEhISEhISEhISEiIiIiIiIiIiIiIyMjIyMjIyMjIyQkJCQkJCQkJCQlJSUlJSUlJSUlJiYmJiYmJiYmJicnJycnJycnJycoKCgoKCgoKCgoKSkpKSkpKSkpKSoqKioqKioqKiorKysrKysrKysrLCwsLCwsLCwsLC0tLS0tLS0tLS0uLi4uLi4uLi4uLy8vLy8vLy8vLzAwMDAwMDAwMDAxMTExMTExMTExMjIyMjIyMjIyMjMzMzMzMzMzMzM0NDQ0NDQ0NDQ0NTU1NTU1NTU1NTY2NjY2NjY2NjY3Nzc3Nzc3Nzc3ODg4ODg4ODg4ODk5OTk5OTk5OTk6Ojo6Ojo6Ojo6Ozs7Ozs7Ozs7Ozw8PDw8PDw8PDw9PT09PT09PT09Pj4+Pj4+Pj4+Pj8/Pz8/Pz8/Pz8gICAgICAgICAgISEhISEhISEhISIiIiIiIiIiIiIjIyMjIyMjIyMjJCQkJCQkJCQkJCUlJSUlJSUlJSUmJiYmJiYmJiYmJycnJycnJycnJygoKCgoKCgoKCgpKSkpKSkpKSkpKioqKioqKioqKisrKysrKysrKyssLCwsLCwsLCwsLS0tLS0tLS0tLS4uLi4uLi4uLi4vLy8vLy8vLy8vMDAwMDAwMDAwMDExMTExMTExMTEyMjIyMjIyMjIyMzMzMzMzMzMzMzQ0NDQ0NDQ0NDQ1NTU1NTU1NTU1NjY2NjY2NjY2Njc3Nzc3Nzc3Nzc4ODg4ODg4ODg4OTk5OTk5OTk5OTo6Ojo6Ojo6Ojo7Ozs7Ozs7Ozs7PDw8PDw8PDw8PD09PT09PT09PT0+Pj4+Pj4+Pj4+Pz8/Pz8/Pz8/PyAgICAgICAgICAhISEhISEhISEhIiIiIiIiIiIiIiMjIyMjIyMjIyMkJCQkJCQkJCQkJSUlJSUlJSUlJSYmJiYmJiYmJiYnJycnJycnJycnKCgoKCgoKCgoKCkpKSkpKSkpKSkqKioqKioqKioqKysrKysrKysrKywsLCwsLCwsLCwtLS0tLS0tLS0tLi4uLi4uLi4uLi8vLy8vLy8vLy8wMDAwMDAwMDAwMTExMTExMTExMTIyMjIyMjIyMjIzMzMzMzMzMzMzNDQ0NDQ0NDQ0NDU1NTU1NTU1NTU2NjY2NjY2NjY2Nzc3Nzc3Nzc3Nzg4ODg4ODg4ODg5OTk5OTk5OTk5Ojo6Ojo6Ojo6Ojs7Ozs7Ozs7Ozs8PDw8PDw8PDw8PT09PT09PT09PT4+Pj4+Pj4+Pj4/Pz8/Pz8/Pz8/ICAgICAgICAgICEhISEhISEhISEiIiIiIiIiIiIiIyMjIyMjIyMjIyQkJCQkJCQkJCQlJSUlJSUlJSUlJiYmJiYmJiYmJicnJycnJycnJycoKCgoKCgoKCgoKSkpKSkpKSkpKSoqKioqKioqKiorKysrKysrKysrLCwsLCwsLCwsLC0tLS0tLS0tLS0uLi4uLi4uLi4uLy8vLy8vLy8vLzAwMDAwMDAwMDAxMTExMTExMTExMjIyMjIyMjIyMjMzMzMzMzMzMzM0NDQ0NDQ0NDQ0NTU1NTU1NTU1NTY2NjY2NjY2NjY3Nzc3Nzc3Nzc3ODg4ODg4ODg4ODk5OTk5OTk5OTk6Ojo6Ojo6Ojo6Ozs7Ozs7Ozs7Ozw8PDw8PDw8PDw9PT09PT09PT09Pj4+Pj4+Pj4+Pj8/Pz8/Pz8/Pz8gICAgICAgICAgISEhISEhISEhISIiIiIiIiIiIiIjIyMjIyMjIyMjJCQkJCQkJCQkJCUlJSUlJSUlJSUmJiYmJiYmJiYmJycnJycnJycnJygoKCgoKCgoKCgpKSkpKSkpKSkpKioqKioqKioqKisrKysrKysrKyssLCwsLCwsLCwsLS0tLS0tLS0tLS4uLi4uLi4uLi4vLy8vLy8vLy8vMDAwMDAwMDAwMDExMTExMTExMTEyMjIyMjIyMjIyMzMzMzMzMzMzMzQ0NDQ0NDQ0NDQ1NTU1NTU1NTU1NjY2NjY2NjY2Njc3Nzc3Nzc3Nzc4ODg4ODg4ODg4OTk5OTk5OTk5OTo6Ojo6Ojo6Ojo7Ozs7Ozs7Ozs7PDw8PDw8PDw8PD09PT09PT09PT0+Pj4+Pj4+Pj4+Pz8/Pz8/Pz8/PyAgICAgICAgICAhISEhISEhISEhIiIiIiIiIiIiIiMjIyMjIyMjIyMkJCQkJCQkJCQkJSUlJSUlJSUlJSYmJiYmJiYmJiYnJycnJycnJycnKCgoKCgoKCgoKCkpKSkpKSkpKSkqKioqKioqKioqKysrKysrKysrKywsLCwsLCwsLCwtLS0tLS0tLS0tLi4uLi4uLi4uLi8vLy8vLy8vLy8wMDAwMDAwMDAwMTExMTExMTExMTIyMjIyMjIyMjIzMzMzMzMzMzMzNDQ0NDQ0NDQ0NDU1NTU1NTU1NTU2NjY2NjY2NjY2Nzc3Nzc3Nzc3Nzg4ODg4ODg4ODg5OTk5OTk5OTk5Ojo6Ojo6Ojo6Ojs7Ozs7Ozs7Ozs8PDw8PDw8PDw8PT09PT09PT09PT4+Pj4+Pj4+Pj4/Pz8/Pz8/Pz8/AAAAAAAAAAAAAAEBAQEBAQEBAQECAgICAgICAgICAwMDAwMDAwMDAwQEBAQEBAQEBAQFBQUFBQUFBQUFBgYGBgYGBgYGBgcHBwcHBwcHBwcICAgICAgICAgICQkJCQkJCQkJCQoKCgoKCgoKCgoLCwsLCwsLCwsLDAwMDAwMDAwMDA0NDQ0NDQ0NDQ0ODg4ODg4ODg4ODw8PDw8PDw8PDxAQEBAQEBAQEBAREREREREREREREhISEhISEhISEhMTExMTExMTExMUFBQUFBQUFBQUFRUVFRUVFRUVFRYWFhYWFhYWFhYXFxcXFxcXFxcXGBgYGBgYGBgYGBkZGRkZGRkZGRkaGhoaGhoaGhoaGxsbGxsbGxsbGxwcHBwcHBwcHBwdHR0dHR0dHR0dHh4eHh4eHh4eHh8fHx8fHx8fHx8AAAAAAAAAAAAAAQEBAQEBAQEBAQICAgICAgICAgIDAwMDAwMDAwMDBAQEBAQEBAQEBAUFBQUFBQUFBQUGBgYGBgYGBgYGBwcHBwcHBwcHBwgICAgICAgICAgJCQkJCQkJCQkJCgoKCgoKCgoKCgsLCwsLCwsLCwsMDAwMDAwMDAwMDQ0NDQ0NDQ0NDQ4ODg4ODg4ODg4PDw8PDw8PDw8PEBAQEBAQEBAQEBERERERERERERESEhISEhISEhISExMTExMTExMTExQU"
	Static 6 = "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"
	Loop, 3
		{
		Index:=A_Index+3
		TD.=%Index%
		}
	VarSetCapacity(Out_Data,Bytes:=26678,0)
	ErrorLevel:=DllCall("Crypt32.dll\CryptStringToBinary","Ptr",&TD,"UInt",0,"UInt",1,"Ptr",&Out_Data,"UIntP",Bytes,"Int",0,"Int",0,"CDECL Int")
	If !(ErrorLevel)
		throw { what: (IsFunc(A_ThisFunc)?"function: " A_ThisFunc "()":"") A_Tab (IsLabel(A_ThisLabel)?"label: " A_ThisLabel:""), file: A_LineFile, line: A_LineNumber, message: "ErrorLevel=" ErrorLevel A_Tab "A_LastError=" A_LastError, extra: "CryptStringToBinary Error"}
	TD:=""
	PaletteBIN:=New MemoryFileIO(Out_Data,Bytes)
	PaletteBIN.Seek(54,0)
	Loop, % (Palette.MaxIndex()-Palette.MinIndex()+1)
		{
		Index:=A_Index
		PaletteBIN.WriteUChar(Palette[Index,"BB"])
		PaletteBIN.WriteUChar(Palette[Index,"GG"])
		PaletteBIN.WriteUChar(Palette[Index,"RR"])
		PaletteBIN.WriteUChar(Palette[Index,"AA"])
		}
	Offset:=PaletteBIN.Tell()
	While Offset<1078
		{
		PaletteBIN.WriteUChar(0)
		Offset++
		}
	PaletteImage[1]:=GDIPlus_hBitmapFromBuffer(Out_Data,Bytes)
	PaletteBIN:=""
}

ExportPalette(Type,OutPath){
	If (Type="BMPV") OR (Type="ALL") ; http://www.fileformat.info/format/bmp/egff.htm
		{
		TD:=""
		Static 1 = "Qk02aAAAAAAAADYEAAAoAAAAQAEAAFAAAAABAAgAAAAAAABkAAAAAAAAAAAAAAABAAAAAQAAAAAAAAEBAQACAgIAAwMDAAQEBAAFBQUABgYGAAcHBwAICAgACQkJAAoKCgALCwsADAwMAA0NDQAODg4ADw8PABAQEAAREREAEhISABMTEwAUFBQAFRUVABYWFgAXFxcAGBgYABkZGQAaGhoAGxsbABwcHAAdHR0AHh4eAB8fHwAgICAAISEhACIiIgAjIyMAJCQkACUlJQAmJiYAJycnACgoKAApKSkAKioqACsrKwAsLCwALS0tAC4uLgAvLy8AMDAwADExMQAyMjIAMzMzADQ0NAA1NTUANjY2ADc3NwA4ODgAOTk5ADo6OgA7OzsAPDw8AD09PQA+Pj4APz8/AEBAQABBQUEAQkJCAENDQwBEREQARUVFAEZGRgBHR0cASEhIAElJSQBKSkoAS0tLAExMTABNTU0ATk5OAE9PTwBQUFAAUVFRAFJSUgBTU1MAVFRUAFVVVQBWVlYAV1dXAFhYWABZWVkAWlpaAFtbWwBcXFwAXV1dAF5eXgBfX18AYGBgAGFhYQBiYmIAY2NjAGRkZABlZWUAZmZmAGdnZwBoaGgAaWlpAGpqagBra2sAbGxsAG1tbQBubm4Ab29vAHBwcABxcXEAcnJyAHNzcwB0dHQAdXV1AHZ2dgB3d3cAeHh4AHl5eQB6enoAe3t7AHx8fAB9fX0Afn5+AH9/fwCAgIAAgYGBAIKCggCDg4MAhISEAIWFhQCGhoYAh4eHAIiIiACJiYkAioqKAIuLiwCMjIwAjY2NAI6OjgCPj48AkJCQAJGRkQCSkpIAk5OTAJSUlACVlZUAlpaWAJeXlwCYmJgAmZmZAJqamgCbm5sAnJycAJ2dnQCenp4An5+fAKCgoAChoaEAoqKiAKOjowCkpKQApaWlAKampgCnp6cAqKioAKmpqQCqqqoAq6urAKysrACtra0Arq6uAK+vrwCwsLAAsbGxALKysgCzs7MAtLS0ALW1tQC2trYAt7e3ALi4uAC5ubkAurq6ALu7uwC8vLwAvb29AL6+vgC/v78AwMDAAMHBwQDCwsIAw8PDAMTExADFxcUAxsbGAMfHxwDIyMgAycnJAMrKygDLy8sAzMzMAM3NzQDOzs4Az8/PANDQ0ADR0dEA0tLSANPT0wDU1NQA1dXVANbW1gDX19cA2NjYANnZ2QDa2toA29vbANzc3ADd3d0A3t7eAN/f3wDg4OAA4eHhAOLi4gDj4+MA5OTkAOXl5QDm5uYA5+fnAOjo6ADp6ekA6urqAOvr6wDs7OwA7e3tAO7u7gDv7+8A8PDwAPHx8QDy8vIA8/PzAPT09AD19fUA9vb2APf39wD4+PgA+fn5APr6+gD7+/sA/Pz8AP39/QD+/v4A////AODg4ODg4ODg4ODh4eHh4eHh4eHh4uLi4uLi4uLi4uPj4+Pj4+Pj4+Pk5OTk5OTk5OTk5eXl5eXl5eXl5ebm5ubm5ubm5ubn5+fn5+fn5+fn6Ojo6Ojo6Ojo6Onp6enp6enp6enq6urq6urq6urq6+vr6+vr6+vr6+zs7Ozs7Ozs7Ozt7e3t7e3t7e3t7u7u7u7u7u7u7u/v7+/v7+/v7+/w8PDw8PDw8PDw8fHx8fHx8fHx8fLy8vLy8vLy8vLz8/Pz8/Pz8/Pz9PT09PT09PT09PX19fX19fX19fX29vb29vb29vb29/f39/f39/f39/j4+Pj4+Pj4+Pj5+fn5+fn5+fn5+vr6+vr6+vr6+vv7+/v7+/v7+/v8/Pz8/Pz8/Pz8/f39/f39/f39/f7+/v7+/v7+/v7/////////////4ODg4ODg4ODg4OHh4eHh4eHh4eHi4uLi4uLi4uLi4+Pj4+Pj4+Pj4+Tk5OTk5OTk5OTl5eXl5eXl5eXl5ubm5ubm5ubm5ufn5+fn5+fn5+fo6Ojo6Ojo6Ojo6enp6enp6enp6erq6urq6urq6urr6+vr6+vr6+vr7Ozs7Ozs7Ozs7O3t7e3t7e3t7e3u7u7u7u7u7u7u7+/v7+/v7+/v7/Dw8PDw8PDw8PDx8fHx8fHx8fHx8vLy8vLy8vLy8vPz8/Pz8/Pz8/P09PT09PT09PT09fX19fX19fX19fb29vb29vb29vb39/f39/f39/f3+Pj4+Pj4+Pj4+Pn5+fn5+fn5+fn6+vr6+vr6+vr6+/v7+/v7+/v7+/z8/Pz8/Pz8/Pz9/f39/f39/f39/v7+/v7+/v7+/v/////////////g4ODg4ODg4ODg4eHh4eHh4eHh4eLi4uLi4uLi4uLj4+Pj4+Pj4+Pj5OTk5OTk5OTk5OXl5eXl5eXl5eXm5ubm5ubm5ubm5+fn5+fn5+fn5+jo6Ojo6Ojo6Ojp6enp6enp6enp6urq6urq6urq6uvr6+vr6+vr6+vs7Ozs7Ozs7Ozs7e3t7e3t7e3t7e7u7u7u7u7u7u7v7+/v7+/v7+/v8PDw8PDw8PDw8PHx8fHx8fHx8fHy8vLy8vLy8vLy8/Pz8/Pz8/Pz8/T09PT09PT09PT19fX19fX19fX19vb29vb29vb29vf39/f39/f39/f4+Pj4+Pj4+Pj4+fn5+fn5+fn5+fr6+vr6+vr6+vr7+/v7+/v7+/v7/Pz8/Pz8/Pz8/P39/f39/f39/f3+/v7+/v7+/v7+/////////////+Dg4ODg4ODg4ODh4eHh4eHh4eHh4uLi4uLi4uLi4uPj4+Pj4+Pj4+Pk5OTk5OTk5OTk5eXl5eXl5eXl5ebm5ubm5ubm5ubn5+fn5+fn5+fn6Ojo6Ojo6Ojo6Onp6enp6enp6enq6urq6urq6urq6+vr6+vr6+vr6+zs7Ozs7Ozs7Ozt7e3t7e3t7e3t7u7u7u7u7u7u7u/v7+/v7+/v7+/w8PDw8PDw8PDw8fHx8fHx8fHx8fLy8vLy8vLy8vLz8/Pz8/Pz8/Pz9PT09PT09PT09PX19fX19fX19fX29vb29vb29vb29/f39/f39/f39/j4+Pj4+Pj4+Pj5+fn5+fn5+fn5+vr6+vr6+vr6+vv7+/v7+/v7+/v8/Pz8/Pz8/Pz8/f39/f39/f39/f7+/v7+/v7+/v7/////////////4ODg4ODg4ODg4OHh4eHh4eHh4eHi4uLi4uLi4uLi4+Pj4+Pj4+Pj4+Tk5OTk5OTk5OTl5eXl5eXl5eXl5ubm5ubm5ubm5ufn5+fn5+fn5+fo6Ojo6Ojo6Ojo6enp6enp6enp6erq6urq6urq6urr6+vr6+vr6+vr7Ozs7Ozs7Ozs7O3t7e3t7e3t7e3u7u7u7u7u7u7u7+/v7+/v7+/v7/Dw8PDw8PDw8PDx8fHx8fHx8fHx8vLy8vLy8vLy8vPz8/Pz8/Pz8/P09PT09PT09PT09fX19fX19fX19fb29vb29vb29vb39/f39/f39/f3+Pj4+Pj4+Pj4+Pn5+fn5+fn5+fn6+vr6+vr6+vr6+/v7+/v7+/v7+/z8/Pz8/Pz8/Pz9/f39/f39/f39/v7+/v7+/v7+/v/////////////g4ODg4ODg4ODg4eHh4eHh4eHh4eLi4uLi4uLi4uLj4+Pj4+Pj4+Pj5OTk5OTk5OTk5OXl5eXl5eXl5eXm5ubm5ubm5ubm5+fn5+fn5+fn5+jo6Ojo6Ojo6Ojp6enp6enp6enp6urq6urq6urq6uvr6+vr6+vr6+vs7Ozs7Ozs7Ozs7e3t7e3t7e3t7e7u7u7u7u7u7u7v7+/v7+/v7+/v8PDw8PDw8PDw8PHx8fHx8fHx8fHy8vLy8vLy8vLy8/Pz8/Pz8/Pz8/T09PT09PT09PT19fX19fX19fX19vb29vb29vb29vf39/f39/f39/f4+Pj4+Pj4+Pj4+fn5+fn5+fn5+fr6+vr6+vr6+vr7+/v7+/v7+/v7/Pz8/Pz8/Pz8/P39/f39/f39/f3+/v7+/v7+/v7+/////////////+Dg4ODg4ODg4ODh4eHh4eHh4eHh4uLi4uLi4uLi4uPj4+Pj4+Pj4+Pk5OTk5OTk5OTk5eXl5eXl5eXl5ebm5ubm5ubm5ubn5+fn5+fn5+fn6Ojo6Ojo6Ojo6Onp6enp6enp6enq6urq6urq6urq6+vr6+vr6+vr6+zs7Ozs7Ozs7Ozt7e3t7e3t7e3t7u7u7u7u7u7u7u/v7+/v7+/v7+/w8PDw8PDw8PDw8fHx8fHx8fHx8fLy8vLy8vLy8vLz8/Pz8/Pz8/Pz9PT09PT09PT09PX19fX19fX19fX29vb29vb29vb29/f39/f39/f39/j4+Pj4+Pj4+Pj5+fn5+fn5+fn5+vr6+vr6+vr6+vv7+/v7+/v7+/v8/Pz8/Pz8/Pz8/f39/f39/f39/f7+/v7+/v7+/v7/////////////4ODg4ODg4ODg4OHh4eHh4eHh4eHi4uLi4uLi4uLi4+Pj4+Pj4+Pj4+Tk5OTk5OTk5OTl5eXl5eXl5eXl5ubm5ubm5ubm5ufn5+fn5+fn5+fo6Ojo6Ojo6Ojo6enp6enp6enp6erq6urq6urq6urr6+vr6+vr6+vr7Ozs7Ozs7Ozs7O3t7e3t7e3t7e3u7u7u7u7u7u7u7+/v7+/v7+/v7/Dw8PDw8PDw8PDx8fHx8fHx8fHx8vLy8vLy8vLy8vPz8/Pz8/Pz8/P09PT09PT09PT09fX19fX19fX19fb29vb29vb29vb39/f39/f39/f3+Pj4+Pj4+Pj4+Pn5+fn5+fn5+fn6+vr6+vr6+vr6+/v7+/v7+/v7+/z8/Pz8/Pz8/Pz9/f39/f39/f39/v7+/v7+/v7+/v/////////////g4ODg4ODg4ODg4eHh4eHh4eHh4eLi4uLi4uLi4uLj4+Pj4+Pj4+Pj5OTk5OTk5OTk5OXl5eXl5eXl5eXm5ubm5ubm5ubm5+fn5+fn5+fn5+jo6Ojo6Ojo6Ojp6enp6enp6enp6urq6urq6urq6uvr6+vr6+vr6+vs7Ozs7Ozs7Ozs7e3t7e3t7e3t7e7u7u7u7u7u7u7v7+/v7+/v7+/v8PDw8PDw8PDw8PHx8fHx8fHx8fHy8vLy8vLy8vLy8/Pz8/Pz8/Pz8/T09PT09PT09PT19fX19fX19fX19vb29vb29vb29vf39/f39/f39/f4+Pj4+Pj4+Pj4+fn5+fn5+fn5+fr6+vr6+vr6+vr7+/v7+/v7+/v7/Pz8/Pz8/Pz8/P39/f39/f39/f3+/v7+/v7+/v7+/////////////+Dg4ODg4ODg4ODh4eHh4eHh4eHh4uLi4uLi4uLi4uPj4+Pj4+Pj4+Pk5OTk5OTk5OTk5eXl5eXl5eXl5ebm5ubm5ubm5ubn5+fn5+fn5+fn6Ojo6Ojo6Ojo6Onp6enp6enp6enq6urq6urq6urq6+vr6+vr6+vr6+zs7Ozs7Ozs7Ozt7e3t7e3t7e3t7u7u7u7u7u7u7u/v7+/v7+/v7+/w8PDw8PDw8PDw8fHx8fHx8fHx8fLy8vLy8vLy8vLz8/Pz8/Pz8/Pz9PT09PT09PT09PX19fX19fX19fX29vb29vb29vb29/f39/f39/f39/j4+Pj4+Pj4+Pj5+fn5+fn5+fn5+vr6+vr6+vr6+vv7+/v7+/v7+/v8/Pz8/Pz8/Pz8/f39/f39/f39/f7+/v7+/v7+/v7/////////////wMDAwMDAwMDAwMHBwcHBwcHBwcHCwsLCwsLCwsLCw8PDw8PDw8PDw8TExMTExMTExMTFxcXFxcXFxcXFxsbGxsbGxsbGxsfHx8fHx8fHx8fIyMjIyMjIyMjIycnJycnJycnJycrKysrKysrKysrLy8vLy8vLy8vLzMzMzMzMzMzMzM3Nzc3Nzc3Nzc3Ozs7Ozs7Ozs7Oz8/Pz8/Pz8/Pz9DQ0NDQ0NDQ0NDR0dHR0dHR0dHR0tLS0tLS0tLS0tPT09PT09PT09PU1NTU1NTU1NTU1dXV1dXV1dXV1dbW1tbW1tbW1tbX19fX19fX19fX2NjY2NjY2NjY2NnZ2dnZ2dnZ2dna2tra2tra2tra29vb29vb29vb29zc3Nzc3Nzc3Nzd3d3d3d3d3d3d3t7e3t7e3t7e3t/f39/f39/f39/AwMDAwMDAwMDAwcHBwcHBwcHBwcLCwsLCwsLCwsLDw8PDw8PDw8PDxMTExMTExMTExMXFxcXFxcXFxcXGxsbGxsbGxsbGx8fHx8fHx8fHx8jIyMjIyMjIyMjJycnJycnJycnJysrKysrKysrKysvLy8vLy8vLy8vMzMzMzMzMzMzMzc3Nzc3Nzc3Nzc7Ozs7Ozs7Ozs7Pz8/Pz8/Pz8/P0NDQ0NDQ0NDQ0NHR0dHR0dHR0dHS0tLS0tLS0tLS09PT09PT09PT09TU1NTU1NTU1NTV1dXV1dXV1dXV1tbW1tbW1tbW1tfX19fX19fX19fY2NjY2NjY2NjY2dnZ2dnZ2dnZ2dra2tra2tra2trb29vb29vb29vb3Nzc3Nzc3Nzc3N3d3d3d3d3d3d3e3t7e3t7e3t7e39/f39/f39/f38DAwMDAwMDAwMDBwcHBwcHBwcHBwsLCwsLCwsLCwsPDw8PDw8PDw8PExMTExMTExMTExcXFxcXFxcXFxcbGxsbGxsbGxsbHx8fHx8fHx8fHyMjIyMjIyMjIyMnJycnJycnJycnKysrKysrKysrKy8vLy8vLy8vLy8zMzMzMzMzMzMzNzc3Nzc3Nzc3Nzs7Ozs7Ozs7Ozs/Pz8/Pz8/Pz8/Q0NDQ0NDQ0NDQ0dHR0dHR0dHR0dLS0tLS0tLS0tLT09PT09PT09PT1NTU1NTU1NTU1NXV1dXV1dXV1dXW1tbW1tbW1tbW19fX19fX19fX19jY2NjY2NjY2NjZ2dnZ2dnZ2dnZ2tra2tra2tra2tvb29vb29vb29vc3Nzc3Nzc3Nzc3d3d3d3d3d3d3d7e3t7e3t7e3t7f39/f39/f39/fwMDAwMDAwMDAwMHBwcHBwcHBwcHCwsLCwsLCwsLCw8PDw8PDw8PDw8TExMTExMTExMTFxcXFxcXFxcXFxsbGxsbGxsbGxsfHx8fHx8fHx8fIyMjIyMjIyMjIycnJycnJycnJycrKysrKysrKysrLy8vLy8vLy8vLzMzMzMzMzMzMzM3Nzc3Nzc3Nzc3Ozs7Ozs7Ozs7Oz8/Pz8/Pz8/Pz9DQ0NDQ0NDQ0NDR0dHR0dHR0dHR0tLS0tLS0tLS0tPT09PT09PT09PU1NTU1NTU1NTU1dXV1dXV1dXV1dbW1tbW1tbW1tbX19fX19fX19fX2NjY2NjY2NjY2NnZ2dnZ2dnZ2dna2tra2tra2tra29vb29vb29vb29zc3Nzc3Nzc3Nzd3d3d3d3d3d3d3t7e3t7e3t7e3t/f39/f39/f39/AwMDAwMDAwMDAwcHBwcHBwcHBwcLCwsLCwsLCwsLDw8PDw8PDw8PDxMTExMTExMTExMXFxcXFxcXFxcXGxsbGxsbGxsbGx8fHx8fHx8fHx8jIyMjIyMjIyMjJycnJycnJycnJysrKysrKysrKysvLy8vLy8vLy8vMzMzMzMzMzMzMzc3Nzc3Nzc3Nzc7Ozs7Ozs7Ozs7Pz8/Pz8/Pz8/P0NDQ0NDQ0NDQ0NHR0dHR0dHR0dHS0tLS0tLS0tLS09PT09PT09PT09TU1NTU1NTU1NTV1dXV1dXV1dXV1tbW1tbW1tbW1tfX19fX19fX19fY2NjY2NjY2NjY2dnZ2dnZ2dnZ2dra2tra2tra2trb29vb29vb29vb3Nzc3Nzc3Nzc3N3d3d3d3d3d3d3e3t7e3t7e3t7e39/f39/f39/f38DAwMDAwMDAwMDBwcHBwcHBwcHBwsLCwsLCwsLCwsPDw8PDw8PDw8PExMTExMTExMTExcXFxcXFxcXFxcbGxsbGxsbGxsbHx8fHx8fHx8fHyMjIyMjIyMjIyMnJycnJycnJycnKysrKysrKysrKy8vLy8vLy8vLy8zMzMzMzMzMzMzNzc3Nzc3Nzc3Nzs7Ozs7Ozs7Ozs/Pz8/Pz8/Pz8/Q0NDQ0NDQ0NDQ0dHR0dHR0dHR0dLS0tLS0tLS0tLT09PT09PT09PT1NTU1NTU1NTU1NXV1dXV1dXV1dXW1tbW1tbW1tbW19fX19fX19fX19jY2NjY2NjY2NjZ2dnZ2dnZ2dnZ2tra2tra2tra2tvb29vb29vb29vc3Nzc3Nzc3Nzc3d3d3d3d3d3d3d7e3t7e3t7e3t7f39/f39/f39/fwMDAwMDAwMDAwMHBwcHBwcHBwcHCwsLCwsLCwsLCw8PDw8PDw8PDw8TExMTExMTExMTFxcXFxcXFxcXFxsbGxsbGxsbGxsfHx8fHx8fHx8fIyMjIyMjIyMjIycnJycnJycnJycrKysrKysrKysrLy8vLy8vLy8vLzMzMzMzMzMzMzM3Nzc3Nzc3Nzc3Ozs7Ozs7Ozs7Oz8/Pz8/Pz8/Pz9DQ0NDQ0NDQ0NDR0dHR0dHR0dHR0tLS0tLS0tLS0tPT09PT09PT09PU1NTU1NTU1NTU1dXV1dXV1dXV1dbW1tbW1tbW1tbX19fX19fX19fX2NjY2NjY2NjY2NnZ2dnZ2dnZ2dna2tra2tra2tra29vb29vb29vb29zc3Nzc3Nzc3Nzd3d3d3d3d3d3d3t7e3t7e3t7e3t/f39/f39/f39/AwMDAwMDAwMDAwcHBwcHBwcHBwcLCwsLCwsLCwsLDw8PDw8PDw8PDxMTExMTExMTExMXFxcXFxcXFxcXGxsbGxsbGxsbGx8fHx8fHx8fHx8jIyMjIyMjIyMjJycnJycnJycnJysrKysrKysrKysvLy8vLy8vLy8vMzMzMzMzMzMzMzc3Nzc3Nzc3Nzc7Ozs7Ozs7Ozs7Pz8/Pz8/Pz8/P0NDQ0NDQ0NDQ0NHR0dHR0dHR0dHS0tLS0tLS0tLS09PT09PT09PT09TU1NTU1NTU1NTV1dXV1dXV1dXV1tbW1tbW1tbW1tfX19fX19fX19fY2NjY2NjY2NjY2dnZ2dnZ2dnZ2dra2tra2tra2trb29vb29vb29vb3Nzc3Nzc3Nzc3N3d3d3d3d3d3d3e3t7e3t7e3t7e39/f39/f39/f38DAwMDAwMDAwMDBwcHBwcHBwcHBwsLCwsLCwsLCwsPDw8PDw8PDw8PExMTExMTExMTExcXFxcXFxcXFxcbGxsbGxsbGxsbHx8fHx8fHx8fHyMjIyMjIyMjIyMnJycnJycnJycnKysrKysrKysrKy8vLy8vLy8vLy8zMzMzMzMzMzMzNzc3Nzc3Nzc3Nzs7Ozs7Ozs7Ozs/Pz8/Pz8/Pz8/Q0NDQ0NDQ0NDQ0dHR0dHR0dHR0dLS0tLS0tLS0tLT09PT09PT09PT1NTU1NTU1NTU1NXV1dXV1dXV1dXW1tbW1tbW1tbW19fX19fX19fX19jY2NjY2NjY2NjZ2dnZ2dnZ2dnZ2tra2tra2tra2tvb29vb29vb29vc3Nzc3Nzc3Nzc3d3d3d3d3d3d3d7e3t7e3t7e3t7f39/f39/f39/fwMDAwMDAwMDAwMHBwcHBwcHBwcHCwsLCwsLCwsLCw8PDw8PDw8PDw8TExMTExMTExMTFxcXFxcXFxcXFxsbGxsbGxsbGxsfHx8fHx8fHx8fIyMjIyMjIyMjIycnJycnJycnJycrKysrKysrKysrLy8vLy8vLy8vLzMzMzMzMzMzMzM3Nzc3Nzc3Nzc3Ozs7Ozs7Ozs7Oz8/Pz8/Pz8/Pz9DQ0NDQ0NDQ0NDR0dHR0dHR0dHR0tLS0tLS0tLS0tPT09PT09PT09PU1NTU1NTU1NTU1dXV1dXV1dXV1dbW1tbW1tbW1tbX19fX19fX19fX2NjY2NjY2NjY2NnZ2dnZ2dnZ2dna2tra2tra2tra29vb29vb29vb29zc3Nzc3Nzc3Nzd3d3d3d3d3d3d3t7e3t7e3t7e3t/f39/f39/f39+goKCgoKCgoKCgoaGhoaGhoaGhoaKioqKioqKioqKjo6Ojo6Ojo6OjpKSkpKSkpKSkpKWlpaWlpaWlpaWmpqampqampqamp6enp6enp6enp6ioqKioqKioqKipqampqampqampqqqqqqqqqqqqqqurq6urq6urq6usrKysrKysrKysra2tra2tra2tra6urq6urq6urq6vr6+vr6+vr6+vsLCwsLCwsLCwsLGxsbGxsbGxsbGysrKysrKysrKys7Ozs7Ozs7Ozs7S0tLS0tLS0tLS1tbW1tbW1tbW1tra2tra2tra2tre3t7e3t7e3t7e4uLi4uLi4uLi4ubm5ubm5ubm5ubq6urq6urq6urq7u7u7u7u7u7u7vLy8vLy8vLy8vL29vb29vb29vb2+vr6+vr6+vr6+v7+/v7+/v7+/v6CgoKCgoKCgoKChoaGhoaGhoaGhoqKioqKioqKioqOjo6Ojo6Ojo6OkpKSkpKSkpKSkpaWlpaWlpaWlpaampqampqampqanp6enp6enp6enqKioqKioqKioqKmpqampqampqamqqqqqqqqqqqqqq6urq6urq6urq6ysrKysrKysrKytra2tra2tra2trq6urq6urq6urq+vr6+vr6+vr6+wsLCwsLCwsLCwsbGxsbGxsbGxsbKysrKysrKysrKzs7Ozs7Ozs7OztLS0tLS0tLS0tLW1tbW1tbW1tbW2tra2tra2tra2t7e3t7e3t7e3t7i4uLi4uLi4uLi5ubm5ubm5ubm5urq6urq6urq6uru7u7u7u7u7u7u8vLy8vLy8vLy8vb29vb29vb29vb6+vr6+vr6+vr6/v7+/v7+/v7+/oKCgoKCgoKCgoKGhoaGhoaGhoaGioqKioqKioqKio6Ojo6Ojo6Ojo6SkpKSkpKSkpKSlpaWlpaWlpaWlpqampqampqampqenp6enp6enp6eoqKioqKioqKioqampqampqampqaqqqqqqqqqqqqqrq6urq6urq6urrKysrKysrKysrK2tra2tra2tra2urq6urq6urq6ur6+vr6+vr6+vr7CwsLCwsLCwsLCxsbGxsbGxsbGxsrKysrKysrKysrOzs7Ozs7Ozs7O0tLS0tLS0tLS0tbW1tbW1tbW1tba2tra2tra2tra3t7e3t7e3t7e3uLi4uLi4uLi4uLm5ubm5ubm5ubm6urq6urq6urq6u7u7u7u7u7u7u7y8vLy8vLy8vLy9vb29vb29vb29vr6+vr6+vr6+vr+/v7+/v7+/v7+goKCgoKCgoKCgoaGhoaGhoaGhoaKioqKioqKioqKjo6Ojo6Ojo6OjpKSkpKSkpKSkpKWlpaWlpaWlpaWmpqampqampqamp6enp6enp6enp6ioqKioqKioqKipqampqampqampqqqqqqqqqqqqqqurq6urq6urq6usrKysrKysrKysra2tra2tra2tra6urq6urq6urq6vr6+vr6+vr6+vsLCwsLCwsLCwsLGxsbGxsbGxsbGysrKysrKysrKys7Ozs7Ozs7Ozs7S0tLS0tLS0tLS1tbW1tbW1tbW1tra2tra2tra2tre3t7e3t7e3t7e4uLi4uLi4uLi4ubm5ubm5ubm5ubq6urq6urq6urq7u7u7u7u7u7u7vLy8vLy8vLy8vL29vb29vb29vb2+vr6+vr6+vr6+v7+/v7+/v7+/v6CgoKCgoKCgoKChoaGhoaGhoaGhoqKioqKioqKioqOjo6Ojo6Ojo6OkpKSkpKSkpKSkpaWlpaWlpaWlpaampqampqampqanp6enp6enp6enqKioqKioqKioqKmpqampqampqamqqqqqqqqqqqqqq6urq6urq6urq6ysrKysrKysrKytra2tra2tra2trq6urq6urq6urq+vr6+vr6+vr6+wsLCwsLCwsLCwsbGxsbGxsbGxsbKysrKysrKysrKzs7Ozs7Ozs7OztLS0tLS0tLS0tLW1tbW1tbW1tbW2tra2tra2tra2t7e3t7e3t7e3t7i4uLi4uLi4uLi5ubm5ubm5ubm5urq6urq6urq6uru7u7u7u7u7u7u8vLy8vLy8vLy8vb29vb29vb29vb6+vr6+vr6+vr6/v7+/v7+/v7+/oKCgoKCgoKCgoKGhoaGhoaGhoaGioqKioqKioqKio6Ojo6Ojo6Ojo6SkpKSkpKSkpKSlpaWlpaWlpaWlpqampqampqampqenp6enp6enp6eoqKioqKioqKioqampqampqampqaqqqqqqqqqqqqqrq6urq6urq6urrKysrKysrKysrK2tra2tra2tra2urq6urq6urq6ur6+vr6+vr6+vr7CwsLCwsLCwsLCxsbGxsbGxsbGxsrKysrKysrKysrOzs7Ozs7Ozs7O0tLS0tLS0tLS0tbW1tbW1tbW1tba2tra2tra2tra3t7e3t7e3t7e3uLi4uLi4uLi4uLm5ubm5ubm5ubm6urq6urq6urq6u7u7u7u7u7u7u7y8vLy8vLy8vLy9vb29vb29vb29vr6+vr6+vr6+vr+/v7+/v7+/v7+goKCgoKCgoKCgoaGhoaGhoaGhoaKioqKioqKioqKjo6Ojo6Ojo6OjpKSkpKSkpKSkpKWlpaWlpaWlpaWmpqampqampqamp6enp6enp6enp6ioqKioqKioqKipqampqampqampqqqqqqqqqqqqqqurq6urq6urq6usrKysrKysrKysra2tra2tra2tra6urq6urq6urq6vr6+vr6+vr6+vsLCwsLCwsLCwsLGxsbGxsbGxsbGysrKysrKysrKys7Ozs7Ozs7Ozs7S0tLS0tLS0tLS1tbW1tbW1tbW1tra2tra2tra2tre3t7e3t7e3t7e4uLi4uLi4uLi4ubm5ubm5ubm5ubq6urq6urq6urq7u7u7u7u7u7u7vLy8vLy8vLy8vL29vb29vb29vb2+vr6+vr6+vr6+v7+/v7+/v7+/v6CgoKCgoKCgoKChoaGhoaGhoaGhoqKioqKioqKioqOjo6Ojo6Ojo6OkpKSkpKSkpKSkpaWlpaWlpaWlpaampqampqampqanp6enp6enp6enqKioqKioqKioqKmpqampqampqamqqqqqqqqqqqqqq6urq6urq6urq6ysrKysrKysrKytra2tra2tra2trq6urq6urq6urq+vr6+vr6+vr6+wsLCwsLCwsLCwsbGxsbGxsbGxsbKysrKysrKysrKzs7Ozs7Ozs7OztLS0tLS0tLS0tLW1tbW1tbW1tbW2tra2tra2tra2t7e3t7e3t7e3t7i4uLi4uLi4uLi5ubm5ubm5ubm5urq6urq6urq6uru7u7u7u7u7u7u8vLy8vLy8vLy8vb29vb29vb29vb6+vr6+vr6+vr6/v7+/v7+/v7+/oKCgoKCgoKCgoKGhoaGhoaGhoaGioqKioqKioqKio6Ojo6Ojo6Ojo6SkpKSkpKSkpKSlpaWlpaWlpaWlpqampqampqampqenp6enp6enp6eoqKioqKioqKioqampqampqampqaqqqqqqqqqqqqqrq6urq6urq6urrKysrKysrKysrK2tra2tra2tra2urq6urq6urq6ur6+vr6+vr6+vr7CwsLCwsLCwsLCxsbGxsbGxsbGxsrKysrKysrKysrOzs7Ozs7Ozs7O0tLS0tLS0tLS0tbW1tbW1tbW1tba2tra2tra2tra3t7e3t7e3t7e3uLi4uLi4uLi4uLm5ubm5ubm5ubm6urq6urq6urq6u7u7u7u7u7u7u7y8vLy8vLy8vLy9vb29vb29vb29vr6+vr6+vr6+vr+/v7+/v7+/v7+goKCgoKCgoKCgoaGhoaGhoaGhoaKioqKioqKioqKjo6Ojo6Ojo6OjpKSkpKSkpKSkpKWlpaWlpaWlpaWmpqampqampqamp6enp6enp6enp6ioqKioqKioqKipqampqampqampqqqqqqqqqqqqqqurq6urq6urq6usrKysrKysrKysra2tra2tra2tra6urq6urq6urq6vr6+vr6+vr6+vsLCwsLCwsLCwsLGxsbGxsbGxsbGysrKysrKysrKys7Ozs7Ozs7Ozs7S0tLS0tLS0tLS1tbW1tbW1tbW1tra2tra2tra2tre3t7e3t7e3t7e4uLi4uLi4uLi4ubm5ubm5ubm5ubq6urq6urq6urq7u7u7u7u7u7u7vLy8vLy8vLy8vL29vb29vb29vb2+vr6+vr6+vr6+v7+/v7+/v7+/v4CAgICAgICAgICBgYGBgYGBgYGBgoKCgoKCgoKCgoODg4ODg4ODg4OEhISEhISEhISEhYWFhYWFhYWFhYaGhoaGhoaGhoaHh4eHh4eHh4eHiIiIiIiIiIiIiImJiYmJiYmJiYmKioqKioqKioqKi4uLi4uLi4uLi4yMjIyMjIyMjIyNjY2NjY2NjY2Njo6Ojo6Ojo6Ojo+Pj4+Pj4+Pj4+QkJCQkJCQkJCQkZGRkZGRkZGRkZKSkpKSkpKSkpKTk5OTk5OTk5OTlJSUlJSUlJSUlJWVlZWVlZWVlZWWlpaWlpaWlpaWl5eXl5eXl5eXl5iYmJiYmJiYmJiZmZmZmZmZmZmZmpqampqampqampubm5ubm5ubm5ucnJycnJycnJycnZ2dnZ2dnZ2dnZ6enp6enp6enp6fn5+fn5+fn5+fgICAgICAgICAgIGBgYGBgYGBgYGCgoKCgoKCgoKCg4ODg4ODg4ODg4SEhISEhISEhISFhYWFhYWFhYWFhoaGhoaGhoaGhoeHh4eHh4eHh4eIiIiIiIiIiIiIiYmJiYmJiYmJiYqKioqKioqKioqLi4uLi4uLi4uLjIyMjIyMjIyMjI2NjY2NjY2NjY2Ojo6Ojo6Ojo6Oj4+Pj4+Pj4+Pj5CQkJCQkJCQkJCRkZGRkZGRkZGRkpKSkpKSkpKSkpOTk5OTk5OTk5OUlJSUlJSUlJSUlZWVlZWVlZWVlZaWlpaWlpaWlpaXl5eXl5eXl5eXmJiYmJiYmJiYmJmZmZmZmZmZmZmampqampqampqam5ubm5ubm5ubm5ycnJycnJycnJydnZ2dnZ2dnZ2dnp6enp6enp6enp+fn5+fn5+fn5+AgICAgICAgICAgYGBgYGBgYGBgYKCgoKCgoKCgoKDg4ODg4ODg4ODhISEhISEhISEhIWFhYWFhYWFhYWGhoaGhoaGhoaGh4eHh4eHh4eHh4iIiIiIiIiIiIiJiYmJiYmJiYmJioqKioqKioqKiouLi4uLi4uLi4uMjIyMjIyMjIyMjY2NjY2NjY2NjY6Ojo6Ojo6Ojo6Pj4+Pj4+Pj4+PkJCQkJCQkJCQkJGRkZGRkZGRkZGSkpKSkpKSkpKSk5OTk5OTk5OTk5SUlJSUlJSUlJSVlZWVlZWVlZWVlpaWlpaWlpaWlpeXl5eXl5eXl5eYmJiYmJiYmJiYmZmZmZmZmZmZmZqampqampqampqbm5ubm5ubm5ubnJycnJycnJycnJ2dnZ2dnZ2dnZ2enp6enp6enp6en5+fn5+fn5+fn4CAgICAgICAgICBgYGBgYGBgYGBgoKCgoKCgoKCgoODg4ODg4ODg4OEhISEhISEhISEhYWFhYWFhYWFhYaGhoaGhoaGhoaHh4eHh4eHh4eHiIiIiIiIiIiIiImJiYmJiYmJiYmKioqKioqKioqKi4uLi4uLi4uLi4yMjIyMjIyMjIyNjY2NjY2NjY2Njo6Ojo6Ojo6Ojo+Pj4+Pj4+Pj4+QkJCQkJCQkJCQkZGRkZGRkZGRkZKSkpKSkpKSkpKTk5OTk5OTk5OTlJSUlJSUlJSUlJWVlZWVlZWVlZWWlpaWlpaWlpaWl5eXl5eXl5eXl5iYmJiYmJiYmJiZmZmZmZmZmZmZmpqampqampqampubm5ubm5ubm5ucnJycnJycnJycnZ2dnZ2dnZ2dnZ6enp6enp6enp6fn5+fn5+fn5+fgICAgICAgICAgIGBgYGBgYGBgYGCgoKCgoKCgoKCg4ODg4ODg4ODg4SE"
		Static 2 = "hISEhISEhISFhYWFhYWFhYWFhoaGhoaGhoaGhoeHh4eHh4eHh4eIiIiIiIiIiIiIiYmJiYmJiYmJiYqKioqKioqKioqLi4uLi4uLi4uLjIyMjIyMjIyMjI2NjY2NjY2NjY2Ojo6Ojo6Ojo6Oj4+Pj4+Pj4+Pj5CQkJCQkJCQkJCRkZGRkZGRkZGRkpKSkpKSkpKSkpOTk5OTk5OTk5OUlJSUlJSUlJSUlZWVlZWVlZWVlZaWlpaWlpaWlpaXl5eXl5eXl5eXmJiYmJiYmJiYmJmZmZmZmZmZmZmampqampqampqam5ubm5ubm5ubm5ycnJycnJycnJydnZ2dnZ2dnZ2dnp6enp6enp6enp+fn5+fn5+fn5+AgICAgICAgICAgYGBgYGBgYGBgYKCgoKCgoKCgoKDg4ODg4ODg4ODhISEhISEhISEhIWFhYWFhYWFhYWGhoaGhoaGhoaGh4eHh4eHh4eHh4iIiIiIiIiIiIiJiYmJiYmJiYmJioqKioqKioqKiouLi4uLi4uLi4uMjIyMjIyMjIyMjY2NjY2NjY2NjY6Ojo6Ojo6Ojo6Pj4+Pj4+Pj4+PkJCQkJCQkJCQkJGRkZGRkZGRkZGSkpKSkpKSkpKSk5OTk5OTk5OTk5SUlJSUlJSUlJSVlZWVlZWVlZWVlpaWlpaWlpaWlpeXl5eXl5eXl5eYmJiYmJiYmJiYmZmZmZmZmZmZmZqampqampqampqbm5ubm5ubm5ubnJycnJycnJycnJ2dnZ2dnZ2dnZ2enp6enp6enp6en5+fn5+fn5+fn4CAgICAgICAgICBgYGBgYGBgYGBgoKCgoKCgoKCgoODg4ODg4ODg4OEhISEhISEhISEhYWFhYWFhYWFhYaGhoaGhoaGhoaHh4eHh4eHh4eHiIiIiIiIiIiIiImJiYmJiYmJiYmKioqKioqKioqKi4uLi4uLi4uLi4yMjIyMjIyMjIyNjY2NjY2NjY2Njo6Ojo6Ojo6Ojo+Pj4+Pj4+Pj4+QkJCQkJCQkJCQkZGRkZGRkZGRkZKSkpKSkpKSkpKTk5OTk5OTk5OTlJSUlJSUlJSUlJWVlZWVlZWVlZWWlpaWlpaWlpaWl5eXl5eXl5eXl5iYmJiYmJiYmJiZmZmZmZmZmZmZmpqampqampqampubm5ubm5ubm5ucnJycnJycnJycnZ2dnZ2dnZ2dnZ6enp6enp6enp6fn5+fn5+fn5+fgICAgICAgICAgIGBgYGBgYGBgYGCgoKCgoKCgoKCg4ODg4ODg4ODg4SEhISEhISEhISFhYWFhYWFhYWFhoaGhoaGhoaGhoeHh4eHh4eHh4eIiIiIiIiIiIiIiYmJiYmJiYmJiYqKioqKioqKioqLi4uLi4uLi4uLjIyMjIyMjIyMjI2NjY2NjY2NjY2Ojo6Ojo6Ojo6Oj4+Pj4+Pj4+Pj5CQkJCQkJCQkJCRkZGRkZGRkZGRkpKSkpKSkpKSkpOTk5OTk5OTk5OUlJSUlJSUlJSUlZWVlZWVlZWVlZaWlpaWlpaWlpaXl5eXl5eXl5eXmJiYmJiYmJiYmJmZmZmZmZmZmZmampqampqampqam5ubm5ubm5ubm5ycnJycnJycnJydnZ2dnZ2dnZ2dnp6enp6enp6enp+fn5+fn5+fn5+AgICAgICAgICAgYGBgYGBgYGBgYKCgoKCgoKCgoKDg4ODg4ODg4ODhISEhISEhISEhIWFhYWFhYWFhYWGhoaGhoaGhoaGh4eHh4eHh4eHh4iIiIiIiIiIiIiJiYmJiYmJiYmJioqKioqKioqKiouLi4uLi4uLi4uMjIyMjIyMjIyMjY2NjY2NjY2NjY6Ojo6Ojo6Ojo6Pj4+Pj4+Pj4+PkJCQkJCQkJCQkJGRkZGRkZGRkZGSkpKSkpKSkpKSk5OTk5OTk5OTk5SUlJSUlJSUlJSVlZWVlZWVlZWVlpaWlpaWlpaWlpeXl5eXl5eXl5eYmJiYmJiYmJiYmZmZmZmZmZmZmZqampqampqampqbm5ubm5ubm5ubnJycnJycnJycnJ2dnZ2dnZ2dnZ2enp6enp6enp6en5+fn5+fn5+fn4CAgICAgICAgICBgYGBgYGBgYGBgoKCgoKCgoKCgoODg4ODg4ODg4OEhISEhISEhISEhYWFhYWFhYWFhYaGhoaGhoaGhoaHh4eHh4eHh4eHiIiIiIiIiIiIiImJiYmJiYmJiYmKioqKioqKioqKi4uLi4uLi4uLi4yMjIyMjIyMjIyNjY2NjY2NjY2Njo6Ojo6Ojo6Ojo+Pj4+Pj4+Pj4+QkJCQkJCQkJCQkZGRkZGRkZGRkZKSkpKSkpKSkpKTk5OTk5OTk5OTlJSUlJSUlJSUlJWVlZWVlZWVlZWWlpaWlpaWlpaWl5eXl5eXl5eXl5iYmJiYmJiYmJiZmZmZmZmZmZmZmpqampqampqampubm5ubm5ubm5ucnJycnJycnJycnZ2dnZ2dnZ2dnZ6enp6enp6enp6fn5+fn5+fn5+fYGBgYGBgYGBgYGFhYWFhYWFhYWFiYmJiYmJiYmJiY2NjY2NjY2NjY2RkZGRkZGRkZGRlZWVlZWVlZWVlZmZmZmZmZmZmZmdnZ2dnZ2dnZ2doaGhoaGhoaGhoaWlpaWlpaWlpaWpqampqampqampra2tra2tra2trbGxsbGxsbGxsbG1tbW1tbW1tbW1ubm5ubm5ubm5ub29vb29vb29vb3BwcHBwcHBwcHBxcXFxcXFxcXFxcnJycnJycnJycnNzc3Nzc3Nzc3N0dHR0dHR0dHR0dXV1dXV1dXV1dXZ2dnZ2dnZ2dnZ3d3d3d3d3d3d3eHh4eHh4eHh4eHl5eXl5eXl5eXl6enp6enp6enp6e3t7e3t7e3t7e3x8fHx8fHx8fHx9fX19fX19fX19fn5+fn5+fn5+fn9/f39/f39/f39gYGBgYGBgYGBgYWFhYWFhYWFhYWJiYmJiYmJiYmJjY2NjY2NjY2NjZGRkZGRkZGRkZGVlZWVlZWVlZWVmZmZmZmZmZmZmZ2dnZ2dnZ2dnZ2hoaGhoaGhoaGhpaWlpaWlpaWlpampqampqampqamtra2tra2tra2tsbGxsbGxsbGxsbW1tbW1tbW1tbW5ubm5ubm5ubm5vb29vb29vb29vcHBwcHBwcHBwcHFxcXFxcXFxcXFycnJycnJycnJyc3Nzc3Nzc3Nzc3R0dHR0dHR0dHR1dXV1dXV1dXV1dnZ2dnZ2dnZ2dnd3d3d3d3d3d3d4eHh4eHh4eHh4eXl5eXl5eXl5eXp6enp6enp6enp7e3t7e3t7e3t7fHx8fHx8fHx8fH19fX19fX19fX1+fn5+fn5+fn5+f39/f39/f39/f2BgYGBgYGBgYGBhYWFhYWFhYWFhYmJiYmJiYmJiYmNjY2NjY2NjY2NkZGRkZGRkZGRkZWVlZWVlZWVlZWZmZmZmZmZmZmZnZ2dnZ2dnZ2dnaGhoaGhoaGhoaGlpaWlpaWlpaWlqampqampqampqa2tra2tra2tra2xsbGxsbGxsbGxtbW1tbW1tbW1tbm5ubm5ubm5ubm9vb29vb29vb29wcHBwcHBwcHBwcXFxcXFxcXFxcXJycnJycnJycnJzc3Nzc3Nzc3NzdHR0dHR0dHR0dHV1dXV1dXV1dXV2dnZ2dnZ2dnZ2d3d3d3d3d3d3d3h4eHh4eHh4eHh5eXl5eXl5eXl5enp6enp6enp6ent7e3t7e3t7e3t8fHx8fHx8fHx8fX19fX19fX19fX5+fn5+fn5+fn5/f39/f39/f39/YGBgYGBgYGBgYGFhYWFhYWFhYWFiYmJiYmJiYmJiY2NjY2NjY2NjY2RkZGRkZGRkZGRlZWVlZWVlZWVlZmZmZmZmZmZmZmdnZ2dnZ2dnZ2doaGhoaGhoaGhoaWlpaWlpaWlpaWpqampqampqampra2tra2tra2trbGxsbGxsbGxsbG1tbW1tbW1tbW1ubm5ubm5ubm5ub29vb29vb29vb3BwcHBwcHBwcHBxcXFxcXFxcXFxcnJycnJycnJycnNzc3Nzc3Nzc3N0dHR0dHR0dHR0dXV1dXV1dXV1dXZ2dnZ2dnZ2dnZ3d3d3d3d3d3d3eHh4eHh4eHh4eHl5eXl5eXl5eXl6enp6enp6enp6e3t7e3t7e3t7e3x8fHx8fHx8fHx9fX19fX19fX19fn5+fn5+fn5+fn9/f39/f39/f39gYGBgYGBgYGBgYWFhYWFhYWFhYWJiYmJiYmJiYmJjY2NjY2NjY2NjZGRkZGRkZGRkZGVlZWVlZWVlZWVmZmZmZmZmZmZmZ2dnZ2dnZ2dnZ2hoaGhoaGhoaGhpaWlpaWlpaWlpampqampqampqamtra2tra2tra2tsbGxsbGxsbGxsbW1tbW1tbW1tbW5ubm5ubm5ubm5vb29vb29vb29vcHBwcHBwcHBwcHFxcXFxcXFxcXFycnJycnJycnJyc3Nzc3Nzc3Nzc3R0dHR0dHR0dHR1dXV1dXV1dXV1dnZ2dnZ2dnZ2dnd3d3d3d3d3d3d4eHh4eHh4eHh4eXl5eXl5eXl5eXp6enp6enp6enp7e3t7e3t7e3t7fHx8fHx8fHx8fH19fX19fX19fX1+fn5+fn5+fn5+f39/f39/f39/f2BgYGBgYGBgYGBhYWFhYWFhYWFhYmJiYmJiYmJiYmNjY2NjY2NjY2NkZGRkZGRkZGRkZWVlZWVlZWVlZWZmZmZmZmZmZmZnZ2dnZ2dnZ2dnaGhoaGhoaGhoaGlpaWlpaWlpaWlqampqampqampqa2tra2tra2tra2xsbGxsbGxsbGxtbW1tbW1tbW1tbm5ubm5ubm5ubm9vb29vb29vb29wcHBwcHBwcHBwcXFxcXFxcXFxcXJycnJycnJycnJzc3Nzc3Nzc3NzdHR0dHR0dHR0dHV1dXV1dXV1dXV2dnZ2dnZ2dnZ2d3d3d3d3d3d3d3h4eHh4eHh4eHh5eXl5eXl5eXl5enp6enp6enp6ent7e3t7e3t7e3t8fHx8fHx8fHx8fX19fX19fX19fX5+fn5+fn5+fn5/f39/f39/f39/YGBgYGBgYGBgYGFhYWFhYWFhYWFiYmJiYmJiYmJiY2NjY2NjY2NjY2RkZGRkZGRkZGRlZWVlZWVlZWVlZmZmZmZmZmZmZmdnZ2dnZ2dnZ2doaGhoaGhoaGhoaWlpaWlpaWlpaWpqampqampqampra2tra2tra2trbGxsbGxsbGxsbG1tbW1tbW1tbW1ubm5ubm5ubm5ub29vb29vb29vb3BwcHBwcHBwcHBxcXFxcXFxcXFxcnJycnJycnJycnNzc3Nzc3Nzc3N0dHR0dHR0dHR0dXV1dXV1dXV1dXZ2dnZ2dnZ2dnZ3d3d3d3d3d3d3eHh4eHh4eHh4eHl5eXl5eXl5eXl6enp6enp6enp6e3t7e3t7e3t7e3x8fHx8fHx8fHx9fX19fX19fX19fn5+fn5+fn5+fn9/f39/f39/f39gYGBgYGBgYGBgYWFhYWFhYWFhYWJiYmJiYmJiYmJjY2NjY2NjY2NjZGRkZGRkZGRkZGVlZWVlZWVlZWVmZmZmZmZmZmZmZ2dnZ2dnZ2dnZ2hoaGhoaGhoaGhpaWlpaWlpaWlpampqampqampqamtra2tra2tra2tsbGxsbGxsbGxsbW1tbW1tbW1tbW5ubm5ubm5ubm5vb29vb29vb29vcHBwcHBwcHBwcHFxcXFxcXFxcXFycnJycnJycnJyc3Nzc3Nzc3Nzc3R0dHR0dHR0dHR1dXV1dXV1dXV1dnZ2dnZ2dnZ2dnd3d3d3d3d3d3d4eHh4eHh4eHh4eXl5eXl5eXl5eXp6enp6enp6enp7e3t7e3t7e3t7fHx8fHx8fHx8fH19fX19fX19fX1+fn5+fn5+fn5+f39/f39/f39/f2BgYGBgYGBgYGBhYWFhYWFhYWFhYmJiYmJiYmJiYmNjY2NjY2NjY2NkZGRkZGRkZGRkZWVlZWVlZWVlZWZmZmZmZmZmZmZnZ2dnZ2dnZ2dnaGhoaGhoaGhoaGlpaWlpaWlpaWlqampqampqampqa2tra2tra2tra2xsbGxsbGxsbGxtbW1tbW1tbW1tbm5ubm5ubm5ubm9vb29vb29vb29wcHBwcHBwcHBwcXFxcXFxcXFxcXJycnJycnJycnJzc3Nzc3Nzc3NzdHR0dHR0dHR0dHV1dXV1dXV1dXV2dnZ2dnZ2dnZ2d3d3d3d3d3d3d3h4eHh4eHh4eHh5eXl5eXl5eXl5enp6enp6enp6ent7e3t7e3t7e3t8fHx8fHx8fHx8fX19fX19fX19fX5+fn5+fn5+fn5/f39/f39/f39/YGBgYGBgYGBgYGFhYWFhYWFhYWFiYmJiYmJiYmJiY2NjY2NjY2NjY2RkZGRkZGRkZGRlZWVlZWVlZWVlZmZmZmZmZmZmZmdnZ2dnZ2dnZ2doaGhoaGhoaGhoaWlpaWlpaWlpaWpqampqampqampra2tra2tra2trbGxsbGxsbGxsbG1tbW1tbW1tbW1ubm5ubm5ubm5ub29vb29vb29vb3BwcHBwcHBwcHBxcXFxcXFxcXFxcnJycnJycnJycnNzc3Nzc3Nzc3N0dHR0dHR0dHR0dXV1dXV1dXV1dXZ2dnZ2dnZ2dnZ3d3d3d3d3d3d3eHh4eHh4eHh4eHl5eXl5eXl5eXl6enp6enp6enp6e3t7e3t7e3t7e3x8fHx8fHx8fHx9fX19fX19fX19fn5+fn5+fn5+fn9/f39/f39/f39AQEBAQEBAQEBAQUFBQUFBQUFBQUJCQkJCQkJCQkJDQ0NDQ0NDQ0NDREREREREREREREVFRUVFRUVFRUVGRkZGRkZGRkZGR0dHR0dHR0dHR0hISEhISEhISEhJSUlJSUlJSUlJSkpKSkpKSkpKSktLS0tLS0tLS0tMTExMTExMTExMTU1NTU1NTU1NTU5OTk5OTk5OTk5PT09PT09PT09PUFBQUFBQUFBQUFFRUVFRUVFRUVFSUlJSUlJSUlJSU1NTU1NTU1NTU1RUVFRUVFRUVFRVVVVVVVVVVVVVVlZWVlZWVlZWVldXV1dXV1dXV1dYWFhYWFhYWFhYWVlZWVlZWVlZWVpaWlpaWlpaWlpbW1tbW1tbW1tbXFxcXFxcXFxcXF1dXV1dXV1dXV1eXl5eXl5eXl5eX19fX19fX19fX0BAQEBAQEBAQEBBQUFBQUFBQUFBQkJCQkJCQkJCQkNDQ0NDQ0NDQ0NERERERERERERERUVFRUVFRUVFRUZGRkZGRkZGRkZHR0dHR0dHR0dHSEhISEhISEhISElJSUlJSUlJSUlKSkpKSkpKSkpKS0tLS0tLS0tLS0xMTExMTExMTExNTU1NTU1NTU1NTk5OTk5OTk5OTk9PT09PT09PT09QUFBQUFBQUFBQUVFRUVFRUVFRUVJSUlJSUlJSUlJTU1NTU1NTU1NTVFRUVFRUVFRUVFVVVVVVVVVVVVVWVlZWVlZWVlZWV1dXV1dXV1dXV1hYWFhYWFhYWFhZWVlZWVlZWVlZWlpaWlpaWlpaWltbW1tbW1tbW1tcXFxcXFxcXFxcXV1dXV1dXV1dXV5eXl5eXl5eXl5fX19fX19fX19fQEBAQEBAQEBAQEFBQUFBQUFBQUFCQkJCQkJCQkJCQ0NDQ0NDQ0NDQ0RERERERERERERFRUVFRUVFRUVFRkZGRkZGRkZGRkdHR0dHR0dHR0dISEhISEhISEhISUlJSUlJSUlJSUpKSkpKSkpKSkpLS0tLS0tLS0tLTExMTExMTExMTE1NTU1NTU1NTU1OTk5OTk5OTk5OT09PT09PT09PT1BQUFBQUFBQUFBRUVFRUVFRUVFRUlJSUlJSUlJSUlNTU1NTU1NTU1NUVFRUVFRUVFRUVVVVVVVVVVVVVVZWVlZWVlZWVlZXV1dXV1dXV1dXWFhYWFhYWFhYWFlZWVlZWVlZWVlaWlpaWlpaWlpaW1tbW1tbW1tbW1xcXFxcXFxcXFxdXV1dXV1dXV1dXl5eXl5eXl5eXl9fX19fX19fX19AQEBAQEBAQEBAQUFBQUFBQUFBQUJCQkJCQkJCQkJDQ0NDQ0NDQ0NDREREREREREREREVFRUVFRUVFRUVGRkZGRkZGRkZGR0dHR0dHR0dHR0hISEhISEhISEhJSUlJSUlJSUlJSkpKSkpKSkpKSktLS0tLS0tLS0tMTExMTExMTExMTU1NTU1NTU1NTU5OTk5OTk5OTk5PT09PT09PT09PUFBQUFBQUFBQUFFRUVFRUVFRUVFSUlJSUlJSUlJSU1NTU1NTU1NTU1RUVFRUVFRUVFRVVVVVVVVVVVVVVlZWVlZWVlZWVldXV1dXV1dXV1dYWFhYWFhYWFhYWVlZWVlZWVlZWVpaWlpaWlpaWlpbW1tbW1tbW1tbXFxcXFxcXFxcXF1dXV1dXV1dXV1eXl5eXl5eXl5eX19fX19fX19fX0BAQEBAQEBAQEBBQUFBQUFBQUFBQkJCQkJCQkJCQkNDQ0NDQ0NDQ0NERERERERERERERUVFRUVFRUVFRUZGRkZGRkZGRkZHR0dHR0dHR0dHSEhISEhISEhISElJSUlJSUlJSUlKSkpKSkpKSkpKS0tLS0tLS0tLS0xMTExMTExMTExNTU1NTU1NTU1NTk5OTk5OTk5OTk9PT09PT09PT09QUFBQUFBQUFBQUVFRUVFRUVFRUVJSUlJSUlJSUlJTU1NTU1NTU1NTVFRUVFRUVFRUVFVVVVVVVVVVVVVWVlZWVlZWVlZWV1dXV1dXV1dXV1hYWFhYWFhYWFhZWVlZWVlZWVlZWlpaWlpaWlpaWltbW1tbW1tbW1tcXFxcXFxcXFxcXV1dXV1dXV1dXV5eXl5eXl5eXl5fX19fX19fX19fQEBAQEBAQEBAQEFBQUFBQUFBQUFCQkJCQkJCQkJCQ0NDQ0NDQ0NDQ0RERERERERERERFRUVFRUVFRUVFRkZGRkZGRkZGRkdHR0dHR0dHR0dISEhISEhISEhISUlJSUlJSUlJSUpKSkpKSkpKSkpLS0tLS0tLS0tLTExMTExMTExMTE1NTU1NTU1NTU1OTk5OTk5OTk5OT09PT09PT09PT1BQUFBQUFBQUFBRUVFRUVFRUVFRUlJSUlJSUlJSUlNTU1NTU1NTU1NUVFRUVFRUVFRUVVVVVVVVVVVVVVZWVlZWVlZWVlZXV1dXV1dXV1dXWFhYWFhYWFhYWFlZWVlZWVlZWVlaWlpaWlpaWlpaW1tbW1tbW1tbW1xcXFxcXFxcXFxdXV1dXV1dXV1dXl5eXl5eXl5eXl9fX19fX19fX19AQEBAQEBAQEBAQUFBQUFBQUFBQUJCQkJCQkJCQkJDQ0NDQ0NDQ0NDREREREREREREREVFRUVFRUVFRUVGRkZGRkZGRkZGR0dHR0dHR0dHR0hISEhISEhISEhJSUlJSUlJSUlJSkpKSkpKSkpKSktLS0tLS0tLS0tMTExMTExMTExMTU1NTU1NTU1NTU5OTk5OTk5OTk5PT09PT09PT09PUFBQUFBQUFBQUFFRUVFRUVFRUVFSUlJSUlJSUlJSU1NTU1NTU1NTU1RUVFRUVFRUVFRVVVVVVVVVVVVVVlZWVlZWVlZWVldXV1dXV1dXV1dYWFhYWFhYWFhYWVlZWVlZWVlZWVpaWlpaWlpaWlpbW1tbW1tbW1tbXFxcXFxcXFxcXF1dXV1dXV1dXV1eXl5eXl5eXl5eX19fX19fX19fX0BAQEBAQEBAQEBBQUFBQUFBQUFBQkJCQkJCQkJCQkNDQ0NDQ0NDQ0NERERERERERERERUVFRUVFRUVFRUZGRkZGRkZGRkZHR0dHR0dHR0dHSEhISEhISEhISElJSUlJSUlJSUlKSkpKSkpKSkpKS0tLS0tLS0tLS0xMTExMTExMTExNTU1NTU1NTU1NTk5OTk5OTk5OTk9PT09PT09PT09QUFBQUFBQUFBQUVFRUVFRUVFRUVJSUlJSUlJSUlJTU1NTU1NTU1NTVFRUVFRUVFRUVFVVVVVVVVVVVVVWVlZWVlZWVlZWV1dXV1dXV1dXV1hYWFhYWFhYWFhZWVlZWVlZWVlZWlpaWlpaWlpaWltbW1tbW1tbW1tcXFxcXFxcXFxcXV1dXV1dXV1dXV5eXl5eXl5eXl5fX19fX19fX19fQEBAQEBAQEBAQEFBQUFBQUFBQUFCQkJCQkJCQkJCQ0NDQ0NDQ0NDQ0RERERERERERERFRUVFRUVFRUVFRkZGRkZGRkZGRkdHR0dHR0dHR0dISEhISEhISEhISUlJSUlJSUlJSUpKSkpKSkpKSkpLS0tLS0tLS0tLTExMTExMTExMTE1NTU1NTU1NTU1OTk5OTk5OTk5OT09PT09PT09PT1BQUFBQUFBQUFBRUVFRUVFRUVFRUlJSUlJSUlJSUlNTU1NTU1NTU1NUVFRUVFRUVFRUVVVVVVVVVVVVVVZWVlZWVlZWVlZXV1dXV1dXV1dXWFhYWFhYWFhYWFlZWVlZWVlZWVlaWlpaWlpaWlpaW1tbW1tbW1tbW1xcXFxcXFxcXFxdXV1dXV1dXV1dXl5eXl5eXl5eXl9fX19fX19fX19AQEBAQEBAQEBAQUFBQUFBQUFBQUJCQkJCQkJCQkJDQ0NDQ0NDQ0NDREREREREREREREVFRUVFRUVFRUVGRkZGRkZGRkZGR0dHR0dHR0dHR0hISEhISEhISEhJSUlJSUlJSUlJSkpKSkpKSkpKSktLS0tLS0tLS0tMTExMTExMTExMTU1NTU1NTU1NTU5OTk5OTk5OTk5PT09PT09PT09PUFBQUFBQUFBQUFFRUVFRUVFRUVFSUlJSUlJSUlJSU1NTU1NTU1NTU1RUVFRUVFRUVFRVVVVVVVVVVVVVVlZWVlZWVlZWVldXV1dXV1dXV1dYWFhYWFhYWFhYWVlZWVlZWVlZWVpaWlpaWlpaWlpbW1tbW1tbW1tbXFxcXFxcXFxcXF1dXV1dXV1dXV1eXl5eXl5eXl5eX19fX19fX19fXyAgICAgICAgICAhISEhISEhISEhIiIiIiIiIiIiIiMjIyMjIyMjIyMkJCQkJCQkJCQkJSUlJSUlJSUlJSYmJiYmJiYmJiYnJycnJycnJycnKCgoKCgoKCgoKCkpKSkpKSkpKSkqKioqKioqKioqKysrKysrKysrKywsLCwsLCwsLCwtLS0tLS0tLS0tLi4uLi4uLi4uLi8vLy8vLy8vLy8wMDAwMDAwMDAwMTExMTExMTExMTIyMjIyMjIyMjIzMzMzMzMzMzMzNDQ0NDQ0NDQ0NDU1NTU1NTU1NTU2NjY2NjY2NjY2Nzc3Nzc3Nzc3Nzg4ODg4ODg4ODg5OTk5OTk5OTk5Ojo6Ojo6Ojo6Ojs7Ozs7Ozs7Ozs8PDw8PDw8PDw8PT09PT09PT09PT4+Pj4+Pj4+Pj4/Pz8/Pz8/Pz8/ICAgICAgICAgICEhISEhISEhISEiIiIiIiIiIiIiIyMjIyMjIyMjIyQkJCQkJCQkJCQlJSUlJSUlJSUlJiYmJiYmJiYmJicnJycnJycnJycoKCgoKCgoKCgoKSkpKSkpKSkpKSoqKioqKioqKiorKysrKysrKysrLCwsLCwsLCwsLC0tLS0tLS0tLS0uLi4uLi4uLi4uLy8vLy8vLy8vLzAwMDAwMDAwMDAxMTExMTExMTExMjIyMjIyMjIyMjMzMzMzMzMzMzM0NDQ0NDQ0NDQ0NTU1NTU1NTU1NTY2NjY2NjY2NjY3Nzc3Nzc3Nzc3ODg4ODg4ODg4ODk5OTk5OTk5OTk6Ojo6Ojo6Ojo6Ozs7Ozs7Ozs7Ozw8PDw8PDw8PDw9PT09PT09PT09Pj4+Pj4+Pj4+Pj8/Pz8/Pz8/Pz8gICAgICAgICAgISEhISEhISEhISIiIiIiIiIiIiIjIyMjIyMjIyMjJCQkJCQkJCQkJCUlJSUlJSUlJSUmJiYmJiYmJiYmJycnJycnJycnJygoKCgoKCgoKCgpKSkpKSkpKSkpKioqKioqKioqKisrKysrKysrKyssLCwsLCwsLCwsLS0tLS0tLS0tLS4uLi4uLi4uLi4vLy8vLy8vLy8vMDAwMDAwMDAwMDExMTExMTExMTEyMjIyMjIyMjIyMzMzMzMzMzMzMzQ0NDQ0NDQ0NDQ1NTU1NTU1NTU1NjY2NjY2NjY2Njc3Nzc3Nzc3Nzc4ODg4ODg4ODg4OTk5OTk5OTk5OTo6Ojo6Ojo6Ojo7Ozs7Ozs7Ozs7PDw8PDw8PDw8PD09PT09PT09PT0+Pj4+Pj4+Pj4+Pz8/Pz8/Pz8/PyAgICAgICAgICAhISEhISEhISEhIiIiIiIiIiIiIiMjIyMjIyMjIyMkJCQkJCQkJCQkJSUlJSUlJSUlJSYmJiYmJiYmJiYnJycnJycnJycnKCgoKCgoKCgoKCkpKSkpKSkpKSkqKioqKioqKioqKysrKysrKysrKywsLCwsLCwsLCwtLS0tLS0tLS0tLi4uLi4uLi4uLi8vLy8vLy8vLy8wMDAwMDAwMDAwMTExMTExMTExMTIyMjIyMjIyMjIzMzMzMzMzMzMzNDQ0NDQ0NDQ0NDU1NTU1NTU1NTU2NjY2NjY2NjY2Nzc3Nzc3Nzc3Nzg4ODg4ODg4ODg5OTk5OTk5OTk5Ojo6Ojo6Ojo6Ojs7Ozs7Ozs7Ozs8PDw8PDw8PDw8PT09PT09PT09PT4+Pj4+Pj4+Pj4/Pz8/Pz8/Pz8/ICAgICAgICAgICEhISEhISEhISEiIiIiIiIiIiIiIyMjIyMjIyMjIyQkJCQkJCQkJCQlJSUlJSUlJSUlJiYmJiYmJiYmJicnJycnJycnJycoKCgoKCgoKCgoKSkpKSkpKSkpKSoqKioqKioqKiorKysrKysrKysrLCwsLCwsLCwsLC0tLS0tLS0tLS0uLi4uLi4uLi4uLy8vLy8vLy8vLzAwMDAwMDAwMDAxMTExMTExMTExMjIyMjIyMjIyMjMzMzMzMzMzMzM0NDQ0NDQ0NDQ0NTU1NTU1NTU1NTY2NjY2NjY2NjY3Nzc3Nzc3Nzc3ODg4ODg4ODg4ODk5OTk5OTk5OTk6Ojo6Ojo6Ojo6Ozs7Ozs7Ozs7Ozw8PDw8PDw8PDw9PT09PT09PT09Pj4+Pj4+Pj4+Pj8/Pz8/Pz8/Pz8gICAgICAgICAgISEhISEhISEhISIiIiIiIiIiIiIjIyMjIyMjIyMjJCQkJCQkJCQkJCUlJSUlJSUlJSUmJiYmJiYmJiYmJycnJycnJycnJygoKCgoKCgoKCgpKSkpKSkpKSkpKioqKioqKioqKisrKysrKysrKyssLCwsLCwsLCwsLS0tLS0tLS0tLS4uLi4uLi4uLi4vLy8vLy8vLy8vMDAwMDAwMDAwMDExMTExMTExMTEyMjIyMjIyMjIyMzMzMzMzMzMzMzQ0NDQ0NDQ0NDQ1NTU1NTU1NTU1NjY2NjY2NjY2Njc3Nzc3Nzc3Nzc4ODg4ODg4ODg4OTk5OTk5OTk5OTo6Ojo6Ojo6Ojo7Ozs7Ozs7Ozs7PDw8PDw8PDw8PD09PT09PT09PT0+Pj4+Pj4+Pj4+Pz8/Pz8/Pz8/PyAgICAgICAgICAhISEhISEhISEhIiIiIiIiIiIiIiMjIyMjIyMjIyMkJCQkJCQkJCQkJSUlJSUlJSUlJSYmJiYmJiYmJiYnJycnJycnJycnKCgoKCgoKCgoKCkpKSkpKSkpKSkqKioqKioqKioqKysrKysrKysrKywsLCwsLCwsLCwtLS0tLS0tLS0tLi4uLi4uLi4uLi8vLy8vLy8vLy8wMDAwMDAwMDAwMTExMTExMTExMTIyMjIyMjIyMjIzMzMzMzMzMzMzNDQ0NDQ0NDQ0NDU1NTU1NTU1NTU2NjY2NjY2NjY2Nzc3Nzc3Nzc3Nzg4ODg4ODg4ODg5OTk5OTk5OTk5Ojo6Ojo6Ojo6Ojs7Ozs7Ozs7Ozs8PDw8PDw8PDw8PT09PT09PT09PT4+Pj4+Pj4+Pj4/Pz8/Pz8/Pz8/ICAgICAgICAgICEhISEhISEhISEiIiIiIiIiIiIiIyMjIyMjIyMjIyQkJCQkJCQkJCQlJSUlJSUlJSUlJiYmJiYmJiYmJicnJycnJycnJycoKCgoKCgoKCgoKSkpKSkpKSkpKSoqKioqKioqKiorKysrKysrKysrLCwsLCwsLCwsLC0tLS0tLS0tLS0uLi4uLi4uLi4uLy8vLy8vLy8vLzAwMDAwMDAwMDAxMTExMTExMTExMjIyMjIyMjIyMjMzMzMzMzMzMzM0NDQ0NDQ0NDQ0NTU1NTU1NTU1NTY2NjY2NjY2NjY3Nzc3Nzc3Nzc3ODg4ODg4ODg4ODk5OTk5OTk5OTk6Ojo6Ojo6Ojo6Ozs7Ozs7Ozs7Ozw8PDw8PDw8PDw9PT09PT09PT09Pj4+Pj4+Pj4+Pj8/Pz8/Pz8/Pz8gICAgICAgICAgISEhISEhISEhISIiIiIiIiIiIiIjIyMjIyMjIyMjJCQkJCQkJCQkJCUlJSUlJSUlJSUmJiYmJiYmJiYmJycnJycnJycnJygoKCgoKCgoKCgpKSkpKSkpKSkpKioqKioqKioqKisrKysrKysrKyssLCwsLCwsLCwsLS0tLS0tLS0tLS4uLi4uLi4uLi4vLy8vLy8vLy8vMDAwMDAwMDAwMDExMTExMTExMTEyMjIyMjIyMjIyMzMzMzMzMzMzMzQ0NDQ0NDQ0NDQ1NTU1NTU1NTU1NjY2NjY2NjY2Njc3Nzc3Nzc3Nzc4ODg4ODg4ODg4OTk5OTk5OTk5OTo6Ojo6Ojo6Ojo7Ozs7Ozs7Ozs7PDw8PDw8PDw8PD09PT09PT09PT0+Pj4+Pj4+Pj4+Pz8/Pz8/Pz8/PyAgICAgICAgICAhISEhISEhISEhIiIiIiIiIiIiIiMjIyMjIyMjIyMkJCQkJCQkJCQkJSUlJSUlJSUlJSYmJiYmJiYmJiYnJycnJycnJycnKCgoKCgoKCgoKCkpKSkpKSkpKSkqKioqKioqKioqKysrKysrKysrKywsLCwsLCwsLCwtLS0tLS0tLS0tLi4uLi4uLi4uLi8vLy8vLy8vLy8wMDAwMDAwMDAwMTExMTExMTExMTIyMjIyMjIyMjIzMzMzMzMzMzMzNDQ0NDQ0NDQ0NDU1NTU1NTU1NTU2NjY2NjY2NjY2Nzc3Nzc3Nzc3Nzg4ODg4ODg4ODg5OTk5OTk5OTk5Ojo6Ojo6Ojo6Ojs7Ozs7Ozs7Ozs8PDw8PDw8PDw8PT09PT09PT09PT4+Pj4+Pj4+Pj4/Pz8/Pz8/Pz8/AAAAAAAAAAAAAAEBAQEBAQEBAQECAgICAgICAgICAwMDAwMDAwMDAwQEBAQEBAQEBAQFBQUFBQUFBQUFBgYGBgYGBgYGBgcHBwcHBwcHBwcICAgICAgICAgICQkJCQkJCQkJCQoKCgoKCgoKCgoLCwsLCwsLCwsLDAwMDAwMDAwMDA0NDQ0NDQ0NDQ0ODg4ODg4ODg4ODw8PDw8PDw8PDxAQEBAQEBAQEBAREREREREREREREhISEhISEhISEhMTExMTExMTExMUFBQUFBQUFBQUFRUVFRUVFRUVFRYWFhYWFhYWFhYXFxcXFxcXFxcXGBgYGBgYGBgYGBkZGRkZGRkZGRkaGhoaGhoaGhoaGxsbGxsbGxsbGxwcHBwcHBwcHBwdHR0dHR0dHR0dHh4eHh4eHh4eHh8fHx8fHx8fHx8AAAAAAAAAAAAAAQEBAQEBAQEBAQICAgICAgICAgIDAwMDAwMDAwMDBAQEBAQEBAQEBAUFBQUFBQUFBQUGBgYGBgYGBgYGBwcHBwcHBwcHBwgICAgICAgICAgJCQkJCQkJCQkJCgoKCgoKCgoKCgsLCwsLCwsLCwsMDAwMDAwMDAwMDQ0NDQ0NDQ0NDQ4ODg4ODg4ODg4PDw8PDw8PDw8PEBAQEBAQEBAQEBERERERERERERESEhISEhISEhISExMTExMTExMTExQU"
		Static 3 = "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"
		Loop, 3
			TD.=%A_Index%
		VarSetCapacity(Out_Data,Bytes:=26678,0)
		ErrorLevel:=DllCall("Crypt32.dll\CryptStringToBinary","Ptr",&TD,"UInt",0,"UInt",1,"Ptr",&Out_Data,"UIntP",Bytes,"Int",0,"Int",0,"CDECL Int")
		If !(ErrorLevel)
			throw { what: (IsFunc(A_ThisFunc)?"function: " A_ThisFunc "()":"") A_Tab (IsLabel(A_ThisLabel)?"label: " A_ThisLabel:""), file: A_LineFile, line: A_LineNumber, message: "ErrorLevel=" ErrorLevel A_Tab "A_LastError=" A_LastError, extra: "CryptStringToBinary Error"}
		TD:=""
		PaletteBIN:=New MemoryFileIO(Out_Data,Bytes)
		PaletteBIN.Seek(54,0)
		Loop, % (Palette.MaxIndex()-Palette.MinIndex()+1)
			{
			Index:=A_Index
			PaletteBIN.WriteUChar(Palette[Index,"BB"])
			PaletteBIN.WriteUChar(Palette[Index,"GG"])
			PaletteBIN.WriteUChar(Palette[Index,"RR"])
			PaletteBIN.WriteUChar(Palette[Index,"AA"])
			}
		Offset:=PaletteBIN.Tell()
		While Offset<1078
			{
			PaletteBIN.WriteUChar(0)
			Offset++
			}
		file:=FileOpen(OutPath "_Palette.bmp","w-d")
			file.RawWrite(Out_Data,Bytes)
		file.Close()
		PaletteBIN:=""
		}
	If (Type="BMP") OR (Type="ALL") ; http://www.fileformat.info/format/bmp/egff.htm
		{
		TD:="Qk06BAAAAAAAADYEAAAoAAAAAQAAAAEAAAABAAgAAAAAAAQAAAAAAAAAAAAAAAABAAAAAQAAAAAAAAEBAQACAgIAAwMDAAQEBAAFBQUABgYGAAcHBwAICAgACQkJAAoKCgALCwsADAwMAA0NDQAODg4ADw8PABAQEAAREREAEhISABMTEwAUFBQAFRUVABYWFgAXFxcAGBgYABkZGQAaGhoAGxsbABwcHAAdHR0AHh4eAB8fHwAgICAAISEhACIiIgAjIyMAJCQkACUlJQAmJiYAJycnACgoKAApKSkAKioqACsrKwAsLCwALS0tAC4uLgAvLy8AMDAwADExMQAyMjIAMzMzADQ0NAA1NTUANjY2ADc3NwA4ODgAOTk5ADo6OgA7OzsAPDw8AD09PQA+Pj4APz8/AEBAQABBQUEAQkJCAENDQwBEREQARUVFAEZGRgBHR0cASEhIAElJSQBKSkoAS0tLAExMTABNTU0ATk5OAE9PTwBQUFAAUVFRAFJSUgBTU1MAVFRUAFVVVQBWVlYAV1dXAFhYWABZWVkAWlpaAFtbWwBcXFwAXV1dAF5eXgBfX18AYGBgAGFhYQBiYmIAY2NjAGRkZABlZWUAZmZmAGdnZwBoaGgAaWlpAGpqagBra2sAbGxsAG1tbQBubm4Ab29vAHBwcABxcXEAcnJyAHNzcwB0dHQAdXV1AHZ2dgB3d3cAeHh4AHl5eQB6enoAe3t7AHx8fAB9fX0Afn5+AH9/fwCAgIAAgYGBAIKCggCDg4MAhISEAIWFhQCGhoYAh4eHAIiIiACJiYkAioqKAIuLiwCMjIwAjY2NAI6OjgCPj48AkJCQAJGRkQCSkpIAk5OTAJSUlACVlZUAlpaWAJeXlwCYmJgAmZmZAJqamgCbm5sAnJycAJ2dnQCenp4An5+fAKCgoAChoaEAoqKiAKOjowCkpKQApaWlAKampgCnp6cAqKioAKmpqQCqqqoAq6urAKysrACtra0Arq6uAK+vrwCwsLAAsbGxALKysgCzs7MAtLS0ALW1tQC2trYAt7e3ALi4uAC5ubkAurq6ALu7uwC8vLwAvb29AL6+vgC/v78AwMDAAMHBwQDCwsIAw8PDAMTExADFxcUAxsbGAMfHxwDIyMgAycnJAMrKygDLy8sAzMzMAM3NzQDOzs4Az8/PANDQ0ADR0dEA0tLSANPT0wDU1NQA1dXVANbW1gDX19cA2NjYANnZ2QDa2toA29vbANzc3ADd3d0A3t7eAN/f3wDg4OAA4eHhAOLi4gDj4+MA5OTkAOXl5QDm5uYA5+fnAOjo6ADp6ekA6urqAOvr6wDs7OwA7e3tAO7u7gDv7+8A8PDwAPHx8QDy8vIA8/PzAPT09AD19fUA9vb2APf39wD4+PgA+fn5APr6+gD7+/sA/Pz8AP39/QD+/v4A////AAAAAAA="
		VarSetCapacity(Out_Data,Bytes:=1082,0)
		ErrorLevel:=DllCall("Crypt32.dll\CryptStringToBinary","Ptr",&TD,"UInt",0,"UInt",1,"Ptr",&Out_Data,"UIntP",Bytes,"Int",0,"Int",0,"CDECL Int")
		If !(ErrorLevel)
			throw { what: (IsFunc(A_ThisFunc)?"function: " A_ThisFunc "()":"") A_Tab (IsLabel(A_ThisLabel)?"label: " A_ThisLabel:""), file: A_LineFile, line: A_LineNumber, message: "ErrorLevel=" ErrorLevel A_Tab "A_LastError=" A_LastError, extra: "CryptStringToBinary Error"}
		TD:=""
		PaletteBIN:=New MemoryFileIO(Out_Data,Bytes)
		PaletteBIN.Seek(54,0)
		Loop, % (Palette.MaxIndex()-Palette.MinIndex()+1)
			{
			Index:=A_Index
			PaletteBIN.WriteUChar(Palette[Index,"BB"])
			PaletteBIN.WriteUChar(Palette[Index,"GG"])
			PaletteBIN.WriteUChar(Palette[Index,"RR"])
			PaletteBIN.WriteUChar(Palette[Index,"AA"])
			}
		Offset:=PaletteBIN.Tell()
		While Offset<1078
			{
			PaletteBIN.WriteUChar(0)
			Offset++
			}
		file:=FileOpen(OutPath "_Palette" (Type="ALL"?"2":"") ".bmp","w-d")
			file.RawWrite(Out_Data,Bytes)
		file.Close()
		PaletteBIN:=""
		}
	If (Type="Raw") OR (Type="Bin") OR (Type="ALL")
		{
		VarSetCapacity(Out_Data,Bytes:=(Palette.MaxIndex()-Palette.MinIndex()+1)*4,0)
		PaletteBIN:=New MemoryFileIO(Out_Data,Bytes)
		PaletteBIN.Seek(0,0)
		Loop, % (Palette.MaxIndex()-Palette.MinIndex()+1)
			{
			Index:=A_Index
			PaletteBIN.WriteUChar(Palette[Index,"RR"])
			PaletteBIN.WriteUChar(Palette[Index,"GG"])
			PaletteBIN.WriteUChar(Palette[Index,"BB"])
			PaletteBIN.WriteUChar(Palette[Index,"AA"])
			}
		file:=FileOpen(OutPath "_Palette.bin","w-d")
			file.RawWrite(Out_Data,Bytes)
		file.Close()
		PaletteBIN:=""
		}
	If (Type="PAL") OR (Type="ALL") ; http://www.tactilemedia.com/info/MCI_Control_Info.html | http://www.johnloomis.org/cpe102/asgn/asgn1/riff.html
		{
		VarSetCapacity(Out_Data,Bytes:=1048,0)
		PaletteBIN:=New MemoryFileIO(Out_Data,Bytes)
		PaletteBIN.Seek(0,0)
		PaletteBIN.Write("RIFF",4)
		PaletteBIN.WriteDWORD(1040)
		PaletteBIN.Write("PAL ",4)
		PaletteBIN.Write("data",4)
		PaletteBIN.WriteDWORD(1028)
		PaletteBIN.WriteWORD(768)
		PaletteBIN.WriteWORD(256)
		Loop, % (Palette.MaxIndex()-Palette.MinIndex()+1)
			{
			Index:=A_Index
			PaletteBIN.WriteUChar(Palette[Index,"RR"])
			PaletteBIN.WriteUChar(Palette[Index,"GG"])
			PaletteBIN.WriteUChar(Palette[Index,"BB"])
			PaletteBIN.WriteUChar(Palette[Index,"AA"])
			}
		file:=FileOpen(OutPath "_Palette.pal","w-d")
			file.RawWrite(Out_Data,Bytes)
		file.Close()
		PaletteBIN:=""
		}
	If (Type="ACT") OR (Type="ALL") ; http://www.adobe.com/devnet-apps/photoshop/fileformatashtml/#50577411_pgfId-1070626
		{
		VarSetCapacity(Out_Data,Bytes:=772,0)
		PaletteBIN:=New MemoryFileIO(Out_Data,Bytes)
		PaletteBIN.Seek(0,0)
		Loop, % (Palette.MaxIndex()-Palette.MinIndex()+1)
			{
			Index:=A_Index
			PaletteBIN.WriteUChar(Palette[Index,"RR"])
			PaletteBIN.WriteUChar(Palette[Index,"GG"])
			PaletteBIN.WriteUChar(Palette[Index,"BB"])
			}
		PaletteBIN.WriteWORD((Palette.MaxIndex()-Palette.MinIndex()+1))
		PaletteBIN.WriteWORD(0) ; TransColorIndex
		file:=FileOpen(OutPath "_Palette.act","w-d")
			file.RawWrite(Out_Data,Bytes)
		file.Close()
		PaletteBIN:=""
		}
}

ImportPalette(path:=""){
	; Adobe ACT|All|Bitmap|Raw/BIN|Visual Bitmap|Windows Palette
	; ACT|BMP|BIN|PAL
	
	IfNotExist, %path%
		{
		Gui +OwnDialogs
			FileSelectFile, Path, 3, , Select the path and filename of the palette to load.
		}
	If FileExist(Path)
		{
		file0:=FileOpen(Path,"r-d")
			file0.RawRead(FileBin,FileSize:=file0.Length)
		file0.Close()
		SplitPath, Path, , , FileType
		PaletteBIN:=New MemoryFileIO(FileBin,FileSize)
		PaletteBIN.Seek(0,0)
		If (FileType="ACT")
			{
			Entry:=1
			Loop, % (FileSize//3>256?256:FileSize//3)
				{
				;~ Gradient:=0
				Palette[Entry,"RR"]:=PaletteBIN.ReadUChar()
				Palette[Entry,"GG"]:=PaletteBIN.ReadUChar()
				Palette[Entry,"BB"]:=PaletteBIN.ReadUChar()
				Palette[Entry,"AA"]:=0
				Entry+=1
				}
			If (Entry<=256)
				{
				Palette[Entry,"RR"]:=0
				Palette[Entry,"GG"]:=0
				Palette[Entry,"BB"]:=0
				Palette[Entry,"AA"]:=0
				Entry+=1
				}
			}
		Else If (FileType="BMP")
			{
			FileType:=PaletteBIN.Read(2)
			PaletteBIN.Seek(10,0)
			BitmapOffset:=PaletteBIN.ReadUInt()
			Size:=PaletteBIN.ReadUInt()
			PaletteBIN.Seek(28,0)
			BitsPerPixel:=PaletteBIN.ReadShort()
			PaletteBIN.Seek(30,0)
			Compression:=PaletteBIN.ReadUInt()
			If (FileType="BM") AND (BitsPerPixel=8) AND (Compression=0)
				{
				PaletteBIN.Seek(Size+14,0)
				PaletteEntries:=(BitmapOffset-Size-14)//4
				Loop, % PaletteEntries
					{
					Index:=A_Index
					Palette[Index,"BB"]:=PaletteBIN.ReadUChar()
					Palette[Index,"GG"]:=PaletteBIN.ReadUChar()
					Palette[Index,"RR"]:=PaletteBIN.ReadUChar()
					Palette[Index,"AA"]:=PaletteBIN.ReadUChar()
					}
				If (Index<256)
					{
					Palette[Index,"BB"]:=0
					Palette[Index,"GG"]:=0
					Palette[Index,"RR"]:=0
					Palette[Index,"AA"]:=0
					Index++
					}
				}
			Else
				throw { what: (IsFunc(A_ThisFunc)?"function: " A_ThisFunc "()":"") A_Tab (IsLabel(A_ThisLabel)?"label: " A_ThisLabel:""), file: A_LineFile, line: A_LineNumber, message: "ErrorLevel=" ErrorLevel A_Tab "A_LastError=" A_LastError, extra: Path " is not a valid 8-bit uncompressed Microsoft Windows 3.x Bitmap."}
			}
		Else If (FileType="BIN")
			{
			Loop, % (FileSize//4>256?256:FileSize//4)
				{
				Index:=A_Index
				Palette[Index,"RR"]:=PaletteBIN.ReadUChar()
				Palette[Index,"GG"]:=PaletteBIN.ReadUChar()
				Palette[Index,"BB"]:=PaletteBIN.ReadUChar()
				Palette[Index,"AA"]:=PaletteBIN.ReadUChar()
				}
			If (Index<256)
				{
				Palette[Index,"BB"]:=0
				Palette[Index,"GG"]:=0
				Palette[Index,"RR"]:=0
				Palette[Index,"AA"]:=0
				Index++
				}
			}
		Else If (FileType="PAL")
			{
			ID0:=PaletteBIN.Read(4)				; "RIFF"
			Size0:=PaletteBIN.ReadDWORD()		; 1040
			FormType:=PaletteBIN.Read(4)		; "PAL"
			ID1:=PaletteBIN.Read(4)				; "data"
			Size1:=PaletteBIN.ReadDWORD()		; 1028
			palVersion:=PaletteBIN.ReadWORD()	; 768
			palPalEntry:=PaletteBIN.ReadWORD()	; 256
			If (ID0="RIFF") AND (FormType="PAL ") AND (ID1="data")
				{
				Loop, % (palPalEntry>256?256:palPalEntry)
					{
					Index:=A_Index
					Palette[Index,"RR"]:=PaletteBIN.ReadUChar()
					Palette[Index,"GG"]:=PaletteBIN.ReadUChar()
					Palette[Index,"BB"]:=PaletteBIN.ReadUChar()
					Palette[Index,"AA"]:=PaletteBIN.ReadUChar()
					}
				If (Index<256)
					{
					Palette[Index,"RR"]:=0
					Palette[Index,"GG"]:=0
					Palette[Index,"BB"]:=0
					Palette[Index,"AA"]:=0
					Index++
					}
				}
			Else
				throw { what: (IsFunc(A_ThisFunc)?"function: " A_ThisFunc "()":"") A_Tab (IsLabel(A_ThisLabel)?"label: " A_ThisLabel:""), file: A_LineFile, line: A_LineNumber, message: "ErrorLevel=" ErrorLevel A_Tab "A_LastError=" A_LastError, extra: Path " is not a valid Windows PAL file."}
			}
		}
	;~ GeneratePaletteImage()
	;~ GuiControl,,Pic8, % "hBitmap:" PaletteImage[1]	; take these two lines out before release
	GuessNewPaletteGradients()
}

GuessNewPaletteGradients(){
	PaletteEntry:=5 ; Major index into Palette - 0th Gradient spans the first 4 palette entries which are for reserved colors
	Loop, 7 ; Next 7 Gradients are not mixed and span 12 palette entries each
		{
		GradientIdx:=A_Index ; Current graphical color gradient (1-7)
		BestEuclideanDist:=1000000000000
		Loop, % (PaletteLookUp.MaxIndex()-PaletteLookUp.MinIndex()+1) ; For each gradient in PaletteLookUp
			{
			PaleteLookUpIdx:=PaletteLookUp.MinIndex()+A_Index-1 ; Major index into PaletteLookUp
			EuclideanDist:=0
			Loop, 12
				{
				CurrPaletteEntry:=PaletteEntry+A_Index-1
				EuclideanDist+=Sqrt((Palette[CurrPaletteEntry,"RR"]-PaletteLookUp[PaleteLookUpIdx,A_Index,"RR"])**2+(Palette[CurrPaletteEntry,"GG"]-PaletteLookUp[PaleteLookUpIdx,A_Index,"GG"])**2+(Palette[CurrPaletteEntry,"BB"]-PaletteLookUp[PaleteLookUpIdx,A_Index,"BB"])**2+(Palette[CurrPaletteEntry,"AA"]-PaletteLookUp[PaleteLookUpIdx,A_Index,"AA"])**2)
				}
			If (EuclideanDist<BestEuclideanDist)
				{
				BestEuclideanDist:=EuclideanDist
				Grad%GradientIdx%:=PaleteLookUpIdx
				}
			}
		PaletteEntry+=12
		}
	;MsgBox % Grad1 "`n" Grad2 "`n" Grad3 "`n" Grad4 "`n" Grad5 "`n" Grad6 "`n" Grad7
	Loop, 7
		{
		PaleteLookUpIdx:=Grad%A_Index%
		GuiControl, Choose, Gradient%A_Index%, % PaleteLookUpIdx + 1
		}
	UpdateGUIMain()
}

LocalGDIPlus_StartUp(){
	; https://autohotkey.com/boards/viewtopic.php?p=178626#p178626
	if !DllCall("kernel32\GetModuleHandle", Str,"gdiplus", Ptr)
		DllCall("kernel32\LoadLibrary", Str,"gdiplus", Ptr)
	VarSetCapacity(GdiplusStartupInput, 16, 0), GdiplusStartupInput := Chr(1), _pToken:=""
	DllCall("gdiplus\GdiplusStartup", UPtrP,_pToken, Ptr,&GdiplusStartupInput, Ptr,0)
	Return _pToken
}

LocalGDIPlus_ShutDown(_pToken){
	; https://autohotkey.com/boards/viewtopic.php?p=178626#p178626
	DllCall("gdiplus\GdiplusShutdown", UPtr,_pToken)
	if hModule := DllCall("kernel32\GetModuleHandle", Str,"gdiplus", Ptr)
		DllCall("kernel32\FreeLibrary", Ptr,hModule)
}

GDIPlus_hBitmapFromBuffer( ByRef Buffer, nSize ) { ;  Last Modifed : 21-Jun-2011
	; https://autohotkey.com/boards/viewtopic.php?p=178626#p178626
; Adapted version by SKAN www.autohotkey.com/forum/viewtopic.php?p=383863#383863
; Original code   by Sean www.autohotkey.com/forum/viewtopic.php?p=147029#147029
 pStream:=pBitmap:=_hBitmap:=""
 hData := DllCall("GlobalAlloc", UInt,2, UInt,nSize )
 pData := DllCall("GlobalLock",  UInt,hData )
 DllCall( "RtlMoveMemory", UInt,pData, UInt,&Buffer, UInt,nSize )
 DllCall( "GlobalUnlock" , UInt,hData )
 DllCall( "ole32\CreateStreamOnHGlobal", UInt,hData, Int,True, UIntP,pStream )
 DllCall( "gdiplus\GdipCreateBitmapFromStream",  UInt,pStream, UIntP,pBitmap )
 DllCall( "gdiplus\GdipCreateHBITMAPFromBitmap", UInt,pBitmap, UIntP,_hBitmap, UInt,RtlUlongByteSwap64(DllCall( "GetSysColor", Int,15 )<<8) | 0xFF000000 )
 DllCall( "gdiplus\GdipDisposeImage", UInt,pBitmap )
 DllCall( NumGet( NumGet(1*pStream)+8 ), UInt,pStream ) ; IStream::Release
Return _hBitmap
; Also See:
;   GdiPlus_SaveImageToBuffer() - Scripts and Functions - AutoHotkey Community
;   https://autohotkey.com/board/topic/85523-gdiplus-saveimagetobuffer/
}

RtlUlongByteSwap64(num){
	; Url: https://autohotkey.com/boards/viewtopic.php?p=181437&sid=ed1119d85377e323927b569b0281d9cd#p181437
	;	- https://msdn.microsoft.com/en-us/library/windows/hardware/ff562886(v=vs.85).aspx (RtlUlongByteSwap routine)
	;	- https://msdn.microsoft.com/en-us/library/e8cxb8tk.aspx (_swab function)
	; For example, if the Source parameter value is 0x12345678, the routine returns 0x78563412.
	; works on both 32 and 64 bit.
	; v1 version
	static dest, src
	static i := varsetcapacity(dest,4) + varsetcapacity(src,4)
	numput(num,src,"uint")
	,DllCall("MSVCRT.dll\_swab", "ptr", &src, "ptr", &dest+2, "int", 2, "cdecl")
	,DllCall("MSVCRT.dll\_swab", "ptr", &src+2, "ptr", &dest, "int", 2, "cdecl")
	return numget(dest,"uint")
}

#Include res\MemoryFileIO_v2.ahk

;;;;; Core Background Functions ;;;;;

ThrowMsg(Options="",Title="",Text="",Timeout=""){
	If (Title="") AND (Text="") AND (Timeout=""){
		Gui +OwnDialogs
		MsgBox % Options
		}
	Else{
		Gui +OwnDialogs
		MsgBox, % Options , % Title , % Text , % Timeout
		}
}