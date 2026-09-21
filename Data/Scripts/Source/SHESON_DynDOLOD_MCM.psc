Scriptname SHESON_DynDOLOD_MCM extends SKI_ConfigBase

Int MyActiveID
Int MyLargeRefID
Int flags
Int GlowMultiple_S
Int fSkyCellRefFadeDistance_S
Int NearGrid_M
Int FarGrid_M
Int DragonDistance_S
Int fBlockLevel0Distance_S
Int fBlockLevel1Distance_S
Int fBlockMaximumDistance_S
Int fSplitDistanceMult_S
Int fTreeLoadDistance_S
String[] GridList

Int Function GetVersion()
	return 147
EndFunction

Event OnConfigInit()
	Pages = new String[3]
	Pages[0] = "Main"
	Pages[1] = "You Are Here"
	Pages[2] = "Settings"
endEvent

Event OnVersionUpdate(int NewVersion)
	if NewVersion >= 147 && CurrentVersion < 147
		Pages = new String[4]
		Pages[0] = "Main"
		Pages[1] = "You Are Here"
		Pages[2] = "Settings"
		Pages[3] = "Information"
	endIf
endEvent

event OnGameReload()
	Utility.Wait(1)
	parent.OnGameReload()
endEvent

Int Function PositionToCell(Float pos)
	Int num1 = (Pos / 4096) As Int
	If pos < 0
		num1 -= 1
	endIf
	return num1
EndFunction

Int Function PositionToSubBlock(Float pos)
	Int num1 = PositionToCell(pos) / 8
	If pos < 0 && PositionToCell(pos) % 8 != 0
		num1 -= 1
	endIf
	return num1
EndFunction

Int Function PositionToBlock(Float pos)
	Int num1 = PositionToSubBlock(pos) / 4
	if pos < 0 && PositionToSubBlock(pos) % 4 != 0
		num1 -= 1
	endIf
	return num1
EndFunction

Int Function CellQuad(Float pos, Int Level, Int Origin)
	Float offset = pos - ((Origin % 4) * 4096)
	Int num1 = (offset / (Level * 16384)) As Int
	if offset < 0
		num1 -= 1
	endIf
	return num1 * Level * 4 + Origin % 4
EndFunction

String Function IntToHex (Int dec)
	String hex = ""
	Int rest = dec
	while (rest > 0)
		Int m16 = rest % 16
		rest = rest / 16
		String temp = ""
		if m16 == 1
			temp = "1"
		elseif m16 == 2
			temp = "2"
		elseif m16 == 3
			temp = "3"
		elseif m16 == 4
			temp = "4"
		elseif m16 == 5
			temp = "5"
		elseif m16 == 6
			temp = "6"
		elseif m16 == 7
			temp = "7"
		elseif m16 == 8
			temp = "8"
		elseif m16 == 9
			temp = "9"
		elseif m16 == 10
			temp = "A"
		elseif m16 == 11
			temp = "B"
		elseif m16 == 12
			temp = "C"
		elseif m16 == 13
			temp = "D"
		elseif m16 == 14
			temp = "E"
		elseif m16 == 15
			temp = "F"
		else
			temp = "0"
		endif
		hex = temp + hex
	endWhile
	return hex
endFunction

String Function Format(Float pos, Int Level = 2)
	return Math.Floor(pos) + StringUtil.Substring(pos, StringUtil.Find(pos, ".", 0), Level + 1)
endFunction

event OnOptionSliderOpen(int option)
	If option == GlowMultiple_S
		SetSliderDialogStartValue(SHESON_DynDOLOD_Plugin.GetGlowMultiple())
		SetSliderDialogDefaultValue(SHESON_DynDOLOD_Plugin.GetGlowMultiple())
		SetSliderDialogRange(0.0, 10.0)
		SetSliderDialogInterval(0.01)
	elseIf option == DragonDistance_S
		SetSliderDialogStartValue(SHESON_DynDOLOD_Plugin.GetDragonDistance())
		SetSliderDialogDefaultValue(SHESON_DynDOLOD_Plugin.GetDragonDistance())
		SetSliderDialogRange(0, 128)
		SetSliderDialogInterval(1)
	elseIf option == fSkyCellRefFadeDistance_S
		SetSliderDialogStartValue(Utility.GetINIfloat("fSkyCellRefFadeDistance"))
		SetSliderDialogDefaultValue(Utility.GetINIfloat("fSkyCellRefFadeDistance"))
		SetSliderDialogRange(0.0, 500000.0)
		SetSliderDialogInterval(1)
	elseIf option == fBlockLevel0Distance_S
		SetSliderDialogStartValue(Utility.GetINIfloat("fBlockLevel0Distance:TerrainManager"))
		SetSliderDialogDefaultValue(Utility.GetINIfloat("fBlockLevel0Distance:TerrainManager"))
		SetSliderDialogRange(0.0, 500000.0)
		SetSliderDialogInterval(1)
	elseIf option == fBlockLevel1Distance_S
		SetSliderDialogStartValue(Utility.GetINIfloat("fBlockLevel1Distance:TerrainManager"))
		SetSliderDialogDefaultValue(Utility.GetINIfloat("fBlockLevel1Distance:TerrainManager"))
		SetSliderDialogRange(0.0, 500000.0)
		SetSliderDialogInterval(1)
	elseIf option == fBlockMaximumDistance_S
		SetSliderDialogStartValue(Utility.GetINIfloat("fBlockMaximumDistance:TerrainManager"))
		SetSliderDialogDefaultValue(Utility.GetINIfloat("fBlockMaximumDistance:TerrainManager"))
		SetSliderDialogRange(0.0, 500000.0)
		SetSliderDialogInterval(1)
	elseIf option == fTreeLoadDistance_S
		SetSliderDialogStartValue(Utility.GetINIfloat("fTreeLoadDistance:TerrainManager"))
		SetSliderDialogDefaultValue(Utility.GetINIfloat("fTreeLoadDistance:TerrainManager"))
		SetSliderDialogRange(0.0, 500000.0)
		SetSliderDialogInterval(1)
	elseIf option == fSplitDistanceMult_S
		SetSliderDialogStartValue(Utility.GetINIfloat("fSplitDistanceMult:TerrainManager"))
		SetSliderDialogDefaultValue(Utility.GetINIfloat("fSplitDistanceMult:TerrainManager"))
		SetSliderDialogRange(0.0, 10.0)
		SetSliderDialogInterval(0.01)
	endIf
endEvent

event OnOptionSliderAccept(int option, float value)
	If option == GlowMultiple_S
		SHESON_DynDOLOD_Plugin.SetGlowMultiple(value)
		SetSliderOptionValue(GlowMultiple_S, SHESON_DynDOLOD_Plugin.GetGlowMultiple(), "{2}")
	elseIf option == fSkyCellRefFadeDistance_S
		Utility.SetINIfloat("fSkyCellRefFadeDistance", value)
		SetSliderOptionValue(fSkyCellRefFadeDistance_S, Utility.GetINIfloat("fSkyCellRefFadeDistance"))
	elseIf option == DragonDistance_S
		SHESON_DynDOLOD_Plugin.SetDragonDistance(value)
		SetSliderOptionValue(DragonDistance_S, SHESON_DynDOLOD_Plugin.GetDragonDistance())
	elseIf option == fBlockLevel0Distance_S
		Utility.SetINIfloat("fBlockLevel0Distance:TerrainManager", value)
		SetSliderOptionValue(fBlockLevel0Distance_S, Utility.GetINIfloat("fBlockLevel0Distance:TerrainManager"))
	elseIf option == fBlockLevel1Distance_S
		Utility.SetINIfloat("fBlockLevel1Distance:TerrainManager", value)
		SetSliderOptionValue(fBlockLevel1Distance_S, Utility.GetINIfloat("fBlockLevel1Distance:TerrainManager"))
	elseIf option == fBlockMaximumDistance_S
		Utility.SetINIfloat("fBlockMaximumDistance:TerrainManager", value)
		SetSliderOptionValue(fBlockMaximumDistance_S, Utility.GetINIfloat("fBlockMaximumDistance:TerrainManager"))
	elseIf option == fSplitDistanceMult_S
		Utility.SetINIfloat("fSplitDistanceMult:TerrainManager", value)
		SetSliderOptionValue(fSplitDistanceMult_S, Utility.GetINIfloat("fSplitDistanceMult:TerrainManager"), "{2}")
	elseIf option == fTreeLoadDistance_S
		Utility.SetINIfloat("fTreeLoadDistance:TerrainManager", value)
		SetSliderOptionValue(fTreeLoadDistance_S, Utility.GetINIfloat("fTreeLoadDistance:TerrainManager"))
	endIf
endEvent

event OnOptionMenuOpen(int option)
	if (option == NearGrid_M)
		Int i = (SHESON_DynDOLOD_Plugin.GetINIUnsigned("NearGrid") - SHESON_DynDOLOD_Plugin.GetINIUnsigned("uGridsToLoad:General") - 2) / 2
		SetMenuDialogStartIndex(i)
		SetMenuDialogDefaultIndex(i)
		SetMenuDialogOptions(GridList)
	elseIf (option == FarGrid_M)
		Int i = (SHESON_DynDOLOD_Plugin.GetINIUnsigned("FarGrid") - SHESON_DynDOLOD_Plugin.GetINIUnsigned("uGridsToLoad:General") - 2) / 2
		SetMenuDialogStartIndex(i)
		SetMenuDialogDefaultIndex(i)
		SetMenuDialogOptions(GridList)
	endIf
endEvent

event OnOptionMenuAccept(int option, int index)
	if (option == NearGrid_M)
		SHESON_DynDOLOD_Plugin.SetINIUnsigned("NearGrid", GridList[index] As Int)
		SetMenuOptionValue(option, SHESON_DynDOLOD_Plugin.GetINIUnsigned("NearGrid") As String)
	elseIf (option == FarGrid_M)
		SHESON_DynDOLOD_Plugin.SetINIUnsigned("FarGrid", GridList[index] As Int)
		SetMenuOptionValue(option, SHESON_DynDOLOD_Plugin.GetINIUnsigned("FarGrid") As String)
	endIf
endEvent

Event OnPageReset(String Page)
	if SKSE.GetVersionRelease() == SKSE.GetScriptVersionRelease() && SKSE.GetScriptVersionRelease() >= SHESON_DynDOLOD_Plugin.GetSKSEVersion()
		if SHESON_DynDOLOD_Plugin.GetVersion() >= 307 && SHESON_DynDOLOD_Plugin.GetScriptVersion() == 307
			SetCursorFillMode(LEFT_TO_RIGHT)
			if Page == ""
				LoadCustomContent("DynDOLOD\\DynDOLOD.dds", 120, 159)
			elseIf Page == "Information"
				UnloadCustomContent()
				SetCursorPosition(0)
				AddHeaderOption("Grid Diameters")
				SetCursorPosition(2)
				AddTextOption("Grid: " + SHESON_DynDOLOD_Plugin.GetINIUnsigned("uGridsToLoad:General"), "")
				SetCursorPosition(4)
				AddTextOption("Large Grid: " + SHESON_DynDOLOD_Plugin.GetINIUnsigned("uLargeRefLODGridSize:General"), "")
				SetCursorPosition(6)
				AddTextOption("Near Grid: " + SHESON_DynDOLOD_Plugin.GetINIUnsigned("NearGrid"), "")
				SetCursorPosition(8)
				AddTextOption("Far Grid: " + SHESON_DynDOLOD_Plugin.GetINIUnsigned("FarGrid"), "")
				SetCursorPosition(1)
				AddHeaderOption("DynDOLOD Plugins")
				SetCursorPosition(3)
				AddTextOption("ESM Version: " + Format(SHESON_DynDOLOD_Plugin.GetESMVersion() As Float / 100) + ", ESP Version: " + Format(SHESON_DynDOLOD_Plugin.GetESPVersion() As Float / 100), "")
				SetCursorPosition(5)
				AddTextOption("ESM: " + (Game.GetFormFromFile(0x00000910, "DynDOLOD.esm") As Keyword).GetString(), "")
				SetCursorPosition(7)
				AddTextOption("ESP: " + (Game.GetFormFromFile(0x00000910, "DynDOLOD.esp") As Keyword).GetString(), "")
				SetCursorPosition(9)
				AddHeaderOption("DynDOLOD.DLL")
				SetCursorPosition(11)
				AddTextOption("DLL Version: " + Format(SHESON_DynDOLOD_Plugin.GetVersion() As Float / 100) + ", Scripts Version: " + Format(SHESON_DynDOLOD_Plugin.GetScriptVersion() As Float / 100), "")
				SetCursorPosition(13)
				AddHeaderOption("DynDOLOD_NG_Worlds.txt")
				SetCursorPosition(15)
				AddTextOption(SHESON_DynDOLOD_Plugin.GetBoNData(), "")
				SetCursorPosition(17)
				AddHeaderOption("DynDOLOD_NG_" + SHESON_DynDOLOD_Plugin.GetMyLODWorld() + ".txt")
				SetCursorPosition(19)
				AddTextOption(SHESON_DynDOLOD_Plugin.GetBoNWorlds(), "")
			elseIf Page == "Settings"
				Int i = 0
				Int g = SHESON_DynDOLOD_Plugin.GetINIUnsigned("uGridsToLoad:General")
				Int m = ((63 - g) / 2) As Int
				GridList = Utility.CreateStringArray(m)
				while i < m
					g += 2
					GridList[i] = g As String
					i += 1
				endWhile
				UnloadCustomContent()
				SetCursorPosition(0)
				AddHeaderOption("Dynamic LOD")
				SetCursorPosition(2)
				NearGrid_M = AddMenuOption("NearGrid", SHESON_DynDOLOD_Plugin.GetINIUnsigned("NearGrid") As String)
				SetCursorPosition(4)
				FarGrid_M = AddMenuOption("FarGrid", SHESON_DynDOLOD_Plugin.GetINIUnsigned("FarGrid") As String)
				SetCursorPosition(8)
				AddHeaderOption("Neverfade Maximum")
				SetCursorPosition(10)
				fSkyCellRefFadeDistance_S = AddSliderOption("fSkyCellRefFadeDistance", Utility.GetINIfloat("fSkyCellRefFadeDistance"))
				SetCursorPosition(14)
				AddHeaderOption("Window Glow Multiplier")
				SetCursorPosition(16)
				GlowMultiple_S = AddSliderOption("Window Glow Multiplier", SHESON_DynDOLOD_Plugin.GetGlowMultiple(), "{2}")
				SetCursorPosition(20)
				AddHeaderOption("Dragon Distance")
				SetCursorPosition(22)
				DragonDistance_S = AddSliderOption("fSkyCellRefProcessDistanceMult", SHESON_DynDOLOD_Plugin.GetDragonDistance(), "{0}")
				SetCursorPosition(1)
				AddHeaderOption("Static Object LOD")
				SetCursorPosition(3)
				fBlockLevel0Distance_S = AddSliderOption("fBlockLevel0Distance", Utility.GetINIfloat("fBlockLevel0Distance:TerrainManager"))
				SetCursorPosition(5)
				fBlockLevel1Distance_S = AddSliderOption("fBlockLevel1Distance", Utility.GetINIfloat("fBlockLevel1Distance:TerrainManager"))
				SetCursorPosition(7)
				fBlockMaximumDistance_S = AddSliderOption("fBlockMaximumDistance", Utility.GetINIfloat("fBlockMaximumDistance:TerrainManager"))
				SetCursorPosition(11)
				AddHeaderOption("Terrain LOD Multiplier")
				SetCursorPosition(13)
				fSplitDistanceMult_S = AddSliderOption("fSplitDistanceMult", Utility.GetINIfloat("fSplitDistanceMult:TerrainManager"), "{2}")
				SetCursorPosition(17)
				AddHeaderOption("Tree LOD")
				SetCursorPosition(19)
				fTreeLoadDistance_S = AddSliderOption("fTreeLoadDistance", Utility.GetINIfloat("fTreeLoadDistance:TerrainManager"))

			elseIf Page == "You Are Here"
				UnloadCustomContent()
				Int x = SHESON_DynDOLOD_Plugin.GetMyLODWorldX()
				Int y = SHESON_DynDOLOD_Plugin.GetMyLODWorldY()
				Float a = PlayerRef.GetPositionX()
				Float b = PlayerRef.GetPositionY()
				Int x4 = CellQuad(a, 1, x)
				Int x8 = CellQuad(a, 2, x)
				Int x16 = CellQuad(a, 4, x)
				Int x32 = CellQuad(a, 8, x)
				Int y4 = CellQuad(b, 1, y)
				Int y8 = CellQuad(b, 2, y)
				Int y16 = CellQuad(b, 4, y)
				Int y32 = CellQuad(b, 8, y)

				SetCursorPosition(0)
				AddHeaderOption("Player")
				SetCursorPosition(2)
				AddTextOption("X " + a + ", Y " + b, "")
				SetCursorPosition(4)
				AddTextOption("Z " + PlayerRef.GetPositionZ(), "")
				SetCursorPosition(6)
				AddTextOption("Cell " + PositionToCell(a) + "," + PositionToCell(b) + "    Block " + PositionToBlock(a) + "," + PositionToBlock(b) + "    SubBlock " + PositionToSubBlock(a) + "," + PositionToSubBlock(b), "")

				String LODWorld = SHESON_DynDOLOD_Plugin.GetMyLODWorld()
				if LODWorld != "none" && LODWorld != ""
					SetCursorPosition(10)
					AddHeaderOption("Meshes\\Terrain\\" + LODWorld + "\\Objects")
					SetCursorPosition(12)
					AddTextOption(LODWorld + ".4." + x4 + "." + y4 + ".bto", "")
					SetCursorPosition(14)
					AddTextOption(LODWorld + ".8." + x8 + "." + y8 + ".bto", "")
					SetCursorPosition(16)
					AddTextOption(LODWorld + ".16." + x16 + "." + y16 + ".bto", "")

					SetCursorPosition(20)
					AddHeaderOption("Meshes\\Terrain\\" + LODWorld + "\\Trees")
					SetCursorPosition(22)
					AddTextOption(LODWorld + ".4." + x4 + "." + y4 + ".btt", "")

					SetCursorPosition(1)
					AddHeaderOption("Meshes\\Terrain\\" + LODWorld)
					SetCursorPosition(3)
					AddTextOption(LODWorld + ".4." + x4 + "." + y4 + ".btr", "")
					SetCursorPosition(5)
					AddTextOption(LODWorld + ".8." + x8 + "." + y8 + ".btr", "")
					SetCursorPosition(7)
					AddTextOption(LODWorld + ".16." + x16 + "." + y16 + ".btr", "")
					SetCursorPosition(9)
					AddTextOption(LODWorld + ".32." + x32 + "." + y32 + ".btr", "")

					SetCursorPosition(13)
					AddHeaderOption("Textures\\Terrain\\" + LODWorld)
					SetCursorPosition(15)
					AddTextOption(LODWorld + ".4." + x4 + "." + y4 + ".dds", "")
					SetCursorPosition(17)
					AddTextOption(LODWorld + ".8." + x8 + "." + y8 + ".dds", "")
					SetCursorPosition(19)
					AddTextOption(LODWorld + ".16." + x16 + "." + y16 + ".dds", "")
					SetCursorPosition(21)
					AddTextOption(LODWorld + ".32." + x32 + "." + y32 + ".dds", "")
				endIf
			elseIf Page == "Main"
				UnloadCustomContent()
				if SHESON_DynDOLOD_Plugin.GetMyMaster()
					flags = OPTION_FLAG_None
				else
					flags = OPTION_FLAG_DISABLED
				endIf
				SetCursorPosition(0)
				AddHeaderOption("Options")
				SetCursorPosition(2)
				MyActiveID = AddToggleOption("DynDOLOD is active", SHESON_DynDOLOD_Plugin.GetMyActive(), flags)
				SetCursorPosition(4)
				MyLargeRefID = AddToggleOption("Large References Child Worlds", SHESON_DynDOLOD_Plugin.GetLargeRefChildWorlds(), OPTION_FLAG_None)

				String LastMessage = MyQuest.LastMessage
				SetCursorPosition(10)
				AddHeaderOption("Last Message")
				SetCursorPosition(12)
				AddTextOption(LastMessage, "")

				SetCursorPosition(16)
				AddHeaderOption("Important")
				SetCursorPosition(18)
				AddTextOption("While DynDOLOD can be turned off here,", "")
				SetCursorPosition(20)
				AddTextOption("it is imperative to be in an interior space", "")
				SetCursorPosition(22)
				AddTextOption("before updating DynDOLOD plugins", "")
				SetCursorPosition(1)
				AddHeaderOption("Updating DynDOLOD")
				SetCursorPosition(3)
				AddTextOption("Before updating deactivate old DynDOLOD here.", "")
				SetCursorPosition(5)
				AddTextOption("Close menu and wait for deactivated message.", "")
				SetCursorPosition(9)
				AddTextOption("Go inside a house and check here", "")
				SetCursorPosition(11)
				AddTextOption("that old DynDOLOD is still not active.", "")
				SetCursorPosition(15)
				AddTextOption("Save.", "")
				SetCursorPosition(17)
				AddTextOption("Start without old DynDOLOD plugins, load last save.", "")
				SetCursorPosition(21)
				AddTextOption("Save again.", "")
				SetCursorPosition(23)
				AddTextOption("Start with new DynDOLOD plugins, load last save.", "")
				SetInfoText(LastMessage)
			endIf	
		else
			UnloadCustomContent()
			SetCursorPosition(0)
			AddHeaderOption("Requirements")
			SetCursorPosition(2)
			AddTextOption("DynDOLOD requires DynDOLOD.DLL", "")
		endIf	
	endIf	
endEvent

Event OnOptionHighlight(int Option)
	if SHESON_DynDOLOD_Plugin.GetMyMaster()
		SetInfoText(MyQuest.LastMessage + "\nDynDOLOD active world " + SHESON_DynDOLOD_Plugin.GetMyLODWorld() + ".")
	else
		SetInfoText(MyQuest.LastMessage + "\nNo data for this location")
	endIf
endEvent

Event OnOptionSelect(int Option)
	if Option == MyActiveID
		if SHESON_DynDOLOD_Plugin.GetMyMaster()
			SHESON_DynDOLOD_Plugin.SetMyActive(!SHESON_DynDOLOD_Plugin.GetMyActive())
			SetToggleOptionValue(MyActiveID, SHESON_DynDOLOD_Plugin.GetMyActive())
			if SHESON_DynDOLOD_Plugin.GetMyActive()
				MyQuest.LastMessage = "DynDOLOD activated"
			else
				MyQuest.LastMessage = "DynDOLOD deactivated"
			endIf
			Debug.Notification(MyQuest.LastMessage)
		endIf
	endIf
	if Option == MyLargeRefID
		SHESON_DynDOLOD_Plugin.SetLargeRefChildWorlds(!SHESON_DynDOLOD_Plugin.GetLargeRefChildWorlds())
		SetToggleOptionValue(MyLargeRefID, SHESON_DynDOLOD_Plugin.GetLargeRefChildWorlds())
	endIf
endEvent

SHESON_DynDOLOD_Quest Property MyQuest = None Auto
Actor Property PlayerRef Auto
