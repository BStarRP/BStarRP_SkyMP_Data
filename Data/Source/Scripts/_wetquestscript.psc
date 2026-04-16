Scriptname _WetQuestScript extends Quest

;====================================================================================

Spell Property _WetPlayerSpell Auto
Spell Property _WetPlayerRegionSpell Auto
Spell Property _WetPlayerAshSpell Auto
Spell Property _WetPlayerAshRegionSpell Auto
Spell Property _WetNPCEquipColdChildSpell Auto
Spell Property _WetNPCEquipColdSpell Auto
Spell Property _WetNPCEquipRainSpell Auto
Spell Property _WetNPCEquipSurvivalSpell Auto
Spell Property _WetNPCEquipAshSpell Auto
Spell Property _WetNPCFXColdDeadSpell Auto
Spell Property _WetNPCFXColdSpell Auto
Spell Property _WetNPCFXRainSpell Auto
Spell Property _WetNPCFXAshSpell Auto
Spell Property _WetNPCFXGeneralSpell Auto
Spell Property _WetNPCSwimWetFeetSpell Auto
Spell Property _WetCreatureFXColdSpell Auto
Spell Property _WetCreatureFXRainSpell Auto
Spell Property _WetCreatureFXGeneralSpell Auto
Spell Property _WetOldConfigSpell Auto
Spell Property WaterskinEquipSpell Auto

VisualEffect Property _WetBreathFastVE Auto
VisualEffect Property _WetBreathFastArgVE Auto
VisualEffect Property _WetBreathFastKhajVE Auto
VisualEffect Property _WetBreathFrigidVE Auto
VisualEffect Property _WetBreathFrigidArgVE Auto
VisualEffect Property _WetBreathFrigidKhajVE Auto
VisualEffect Property _WetBreathVE Auto
VisualEffect Property _WetBreathArgVE Auto
VisualEffect Property _WetBreathKhajVE Auto
VisualEffect Property _WetBreathWerewolfVE Auto

VisualEffect Property _WetBreathHorseLVE Auto
VisualEffect Property _WetBreathHorseRVE Auto
VisualEffect Property _WetBreathGiantVE Auto
VisualEffect Property _WetBreathCanineVE Auto
VisualEffect Property _WetBreathBearVE Auto
VisualEffect Property _WetBreathSabreVE Auto
VisualEffect Property _WetBreathFalmerVE Auto
VisualEffect Property _WetBreathTrollVE Auto
VisualEffect Property _WetBreathDragonRVE Auto
VisualEffect Property _WetBreathDragonLVE Auto
VisualEffect Property _WetBreathCowRVE Auto
VisualEffect Property _WetBreathCowLVE Auto
VisualEffect Property _WetBreathHagravenVE Auto
VisualEffect Property _WetBreathLurkerVE Auto
VisualEffect Property _WetBreathBoarVE Auto
VisualEffect Property _WetBreathRiekVE Auto

ImpactDataSet Property _WetFootWetSoundIPDS Auto

Faction Property _WetBreathFaction Auto
Faction Property _WetBreathPlayerFaction Auto
Faction Property _WetIgnoreFaction Auto
Faction Property _WetColdHoodFaction Auto
Faction Property _WetColdCloakFaction Auto
Faction Property _WetColdGloveFaction Auto
Faction Property _WetColdFaceCoversFaction Auto
Faction Property _WetIsTravelerFaction Auto
Faction Property _WetRainHoodFaction Auto
Faction Property _WetRainCloakFaction Auto
Faction Property _WetFootWetFaction Auto
Faction Property _WetBPAutoFaction Auto
Faction Property _WetIsUnderShelterFaction Auto

Keyword Property ActorTypeTroll Auto
Keyword Property ClothingBody Auto
Keyword Property _WetIsScarf Auto
Keyword Property ArmorMaterialHide Auto
Keyword Property ArmorGauntlets Auto
Keyword Property ArmorHelmet Auto
Keyword Property ClothingHands Auto
Keyword Property ClothingHead Auto
Keyword Property _WetSMEvent Auto

Race Property ArgonianRace Auto
Race Property ArgonianRaceVampire Auto
Race Property KhajiitRace Auto
Race Property NordRace Auto
Race Property NordRaceVampire Auto
Race Property WerewolfBeastRace Auto

Race Property HorseRace Auto
Race Property CartHorseRace Auto
Race Property DogRace Auto
Race Property DogCompanionRace Auto
Race Property MG07DogRace Auto
Race Property DA03BarbasDogRace Auto
Race Property WolfRace Auto
Race Property C00GiantOutsideWhiterunRace Auto
Race Property GiantRace Auto
Race Property BearBlackRace Auto
Race Property BearBrownRace Auto
Race Property BearSnowRace Auto
Race Property SabreCatRace Auto
Race Property SabreCatSnowyRace Auto
Race Property FalmerRace Auto
Race Property DragonRace Auto
Race Property CowRace Auto
Race Property HagravenRace Auto

EffectShader Property _WetDripSwimShader Auto
EffectShader Property _WetSnowSwimShader Auto

LeveledItem Property LItemMiscVendorMiscItems75 Auto
LeveledItem Property LItemMiscVendorArmor75 Auto
LeveledItem Property LItemMiscVendorClothing75 Auto
LeveledItem Property LItemClothesAll Auto
LeveledItem Property DLC2LItemMiscVendorArmor75 Auto

LeveledItem Property _WetAshFaceCoverLItem Auto
LeveledItem Property _WetAshGoggleLItem Auto
LeveledItem Property _WetColdCloakLItem Auto
LeveledItem Property _WetColdFaceCoverLItem Auto
LeveledItem Property _WetColdGloveLItem Auto
LeveledItem Property _WetColdHoodLItem Auto
LeveledItem Property _WetRainHoodLItem Auto
LeveledItem Property _WetRainCloakLItem Auto
LeveledItem Property _WetSurvivalBPLItem Auto

WorldSpace Property Blackreach Auto
WorldSpace Property FallowstoneCaveWorldStart Auto

FormList Property _WetHoodColdList Auto
FormList Property _WetHoodColdArmoredList Auto
FormList Property _WetHoodColdChildList Auto
FormList Property _WetHoodRainList Auto
FormList Property _WetHoodRainFollowerList Auto
FormList Property _WetCloakRainList Auto
FormList Property _WetCloakColdList Auto
FormList Property _WetCloakClippingArmorList Auto
FormList Property _WetGlovesList Auto
FormList Property _WetBPLeatherList Auto
FormList Property _WetBPLeatherFarList Auto
FormList Property _WetBPFurList Auto
FormList Property _WetFaceCoverColdList Auto
FormList Property _WetFaceCoverAshList Auto
FormList Property _WetGogglesDwemerList Auto
FormList Property _WetGogglesChitinList Auto
FormList Property WaterskinList Auto

Form[] Property WorldInterior Auto
Form[] Property DGColdWorld Auto
Form[] Property WTColdWorld Auto
Form[] Property DGHuskies Auto

; Start Edits by AndrealphusVIII
Form[] Property ColdBSHeartland Auto
Location Property CountyBruma Auto
; End Edits by AndrealphusVIII

Form Property DGCat Auto
Form Property DGSnowElf Auto
Form Property DBDragon Auto
Form Property DBWerebear Auto
Form Property DBLurker Auto
Form Property DBBoar Auto
Form Property DBMountedRiek Auto
Form Property DBRiek Auto
Form Property DBThirskRiek Auto

GlobalVariable Property _WetBreathActorToggle Auto
GlobalVariable Property _WetBreathPlayerToggle Auto
GlobalVariable Property _WetBreath1stToggle Auto
GlobalVariable Property _WetRainBlindToggle Auto
GlobalVariable Property _WetBlizzBlindToggle Auto
GlobalVariable Property _WetBlizzBlindPlayerToggle Auto
GlobalVariable Property _WetGoHomeToggle Auto
GlobalVariable Property _WetWindToggle Auto
GlobalVariable Property _WetRainGearToggle Auto
GlobalVariable Property _WetColdGearToggle Auto
GlobalVariable Property _WetAshGearToggle Auto
GlobalVariable Property _WetSurvGearToggle Auto
GlobalVariable Property _WetDustActorToggle Auto
GlobalVariable Property _WetDustPlayerToggle Auto
GlobalVariable Property _WetWateryEyesToggle Auto
GlobalVariable Property _WetIsBlizzarding Auto
GlobalVariable Property _WetDripPlayerToggle Auto
GlobalVariable Property _WetDripActorToggle Auto
GlobalVariable Property _WetFootWetPlayerToggle Auto
GlobalVariable Property _WetFootWetActorToggle Auto
GlobalVariable Property _WetSnowPlayerToggle Auto
GlobalVariable Property _WetSnowActorToggle Auto
GlobalVariable Property _WetWinterToggle Auto
GlobalVariable Property _WetSKSEInstalled Auto
GlobalVariable Property GameHour Auto

_WetSkyUIConfig Property _WetSKConfigQuest Auto

Quest Property _WetApplyNPCQuest Auto
Quest Property _WetApplyNPCColdQuest Auto
Quest Property _WetApplyNPCColdDeadQuest Auto
Quest Property _WetApplyNPCRainQuest Auto
Quest Property _WetApplyNPCAshQuest Auto
Quest Property _WetApplyCreatureQuest Auto
Quest Property _WetApplyCreatureColdQuest Auto
Quest Property _WetApplyCreatureRainQuest Auto
Quest Property _WetApplyGearColdChildQuest Auto
Quest Property _WetApplyGearColdQuest Auto
Quest Property _WetApplyGearRainQuest Auto
Quest Property _WetApplyGearSurvivalQuest Auto
Quest Property _WetApplyGearAshQuest Auto

Quest Property _WetGoHomeRainAllQuest Auto
Quest Property _WetGoHomeRainQuest Auto
Quest Property _WetGoHomeBlizzQuest Auto

Bool Property WetFollowersOnly Auto
Bool Property ColdFollowersOnly Auto
Bool Property AshFollowersOnly Auto
Bool Property ExcludeNords = True Auto
Bool Property ExcludeArgs = True Auto
Bool Property EyeBlack = True Auto
Bool Property RainHoodsOn = True Auto
Bool Property ColdGearOn = True Auto
Bool Property IgnoreWorkersOn = True Auto
Bool Property GogglesOn = True Auto
Bool Property FaceCoversOn = True Auto
Bool Property ColdCloaksOn = True Auto
Bool Property ColdGlovesOn = True Auto
Bool Property ColdHoodsOn = True Auto
Bool Property ColdCoversOn = True Auto
Bool Property WetCloaksOn = True Auto
Bool Property WetHoodsOn = True Auto
Bool Property SurvGearOn = True Auto
Bool Property SurvBPOn = True Auto
Bool Property SurvModItemsOn = True Auto
Bool Property FollowerHoodOn Auto
Bool Property FollowerColdOn Auto
Bool Property FollowerAshOn Auto
Bool Property AshWatery Auto
Bool Property EyeBlackBlizz Auto
Bool Property IsInCold Auto
Bool Property InVanillaCold Auto
Bool Property InVanillaColdTimed Auto
Bool Property IsIndoorsUpdate Auto
Bool Property IsIndoorsStart Auto
Bool Property ModUpdated Auto
Bool Property ModRestarted Auto
Bool Property WiCInstalled Auto
Bool Property EFFInstalled Auto
Bool Property FFInstalled Auto
Bool Property CampfireInstalled Auto
Bool Property CCORInstalled Auto
Bool Property SKSE64Installed Auto
Bool SkyInstalled
Bool DGInstalled
Bool DBInstalled
Bool WTInstalled
Bool CoSInstalled
Bool GetSnowyInstalled
Bool ICitizenAIInstalled

; Start Edits by AndrealphusVIII
Bool BSHeartlandInstalled
; End Edits by AndrealphusVIII

Int Property CurrentTime Auto
Int Property ColdCloakSize Auto
Int Property ColdHoodSize Auto
Int Property ColdHoodChildSize Auto
Int Property ColdHoodArmoredSize Auto
Int Property ColdGlovesSize Auto
Int Property ColdFaceCoverSize Auto
Int Property AshFaceCoverSize Auto
Int Property AshGogglesDwemerSize Auto
Int Property AshGogglesChitinSize Auto
Int Property RainHoodSize Auto
Int Property RainHoodFollowerSize Auto
Int Property RainCloakSize Auto
Int Property SurvFurBPSize Auto
Int Property SurvLeatherBPSize Auto
Int Property SurvLeatherBPFarSize Auto
Int Property WaterskinListSize Auto
Int CCORWiCValue
Int CCORCoSValue

Float Property fModVersion Auto

String Property ConfigText = "Changes saved." Auto
String NoSKSEText = "Wet and Cold: SKSE not detected. Some features are disabled."
String FFDripText = "Wet and Cold: Player's drip shader is disabled in favor of Frostfall's."
String SnowyText = "Wet and Cold: Snowy shader is disabled in favor of Get Snowy's."
String ICitizenAIText = "Wet and Cold: Go Home disabled in favor of Immersive Citizen's AI changes."
String UpdateText = "Wet and Cold: Updated to "

Actor Property PlayerRef Auto
Actor targ

;====================================================================================		Apply spells to actors

Function ScanArea()
	;Utility.Wait(1.0)
	;_WetApplyGearSurvivalQuest.Start()
	;Utility.Wait(0.25)
	;_WetApplyNPCQuest.Start()
	;_WetApplyNPCColdDeadQuest.Start()
	;_WetApplyCreatureQuest.Start()
	;_WetApplyGearAshQuest.Start()
	;_WetApplyGearColdChildQuest.Start()
	;_WetApplyGearColdQuest.Start()
	;_WetApplyGearRainQuest.Start()
	;_WetApplyNPCColdQuest.Start()
	;_WetApplyNPCRainQuest.Start()
	;_WetApplyNPCAshQuest.Start()
	;_WetApplyCreatureColdQuest.Start()
	;_WetApplyCreatureRainQuest.Start()
	_WetSMEvent.SendStoryEventAndWait()
	Utility.Wait(0.1)
	_WetApplyGearSurvivalQuest.Stop()
	_WetApplyNPCQuest.Stop()
	_WetApplyNPCColdDeadQuest.Stop()
	_WetApplyCreatureQuest.Stop()
	_WetApplyGearAshQuest.Stop()
	_WetApplyGearColdChildQuest.Stop()
	_WetApplyGearColdQuest.Stop()
	_WetApplyGearRainQuest.Stop()
	_WetApplyNPCColdQuest.Stop()
	_WetApplyNPCRainQuest.Stop()
	_WetApplyNPCAshQuest.Stop()
	_WetApplyCreatureColdQuest.Stop()
	_WetApplyCreatureRainQuest.Stop()
EndFunction

;====================================================================================		List lengths

Function CalcListLengths()
	ColdHoodSize = _WetHoodColdList.GetSize() as Int
	ColdHoodArmoredSize = _WetHoodColdArmoredList.GetSize() as Int
	ColdHoodChildSize = _WetHoodColdChildList.GetSize() as Int
	ColdGlovesSize = _WetGlovesList.GetSize() as Int
	ColdCloakSize = _WetCloakColdList.GetSize() as Int
	ColdFaceCoverSize = _WetFaceCoverColdList.GetSize() as Int

	AshFaceCoverSize = _WetFaceCoverAshList.GetSize() as Int
	AshGogglesDwemerSize = _WetGogglesDwemerList.GetSize() as Int
	AshGogglesChitinSize = _WetGogglesChitinList.GetSize() as Int

	RainHoodSize = _WetHoodRainList.GetSize() as Int
	RainHoodFollowerSize = _WetHoodRainFollowerList.GetSize() as Int
	RainCloakSize = _WetCloakRainList.GetSize() as Int

	If _WetBPFurList
		SurvFurBPSize = _WetBPFurList.GetSize() as Int
	EndIf
	SurvLeatherBPSize = _WetBPLeatherList.GetSize() as Int
	SurvLeatherBPFarSize = _WetBPLeatherFarList.GetSize() as Int
	If WaterskinList
		WaterskinListSize = WaterskinList.GetSize() as Int
	EndIf
	Utility.Wait(1.0)
EndFunction

;====================================================================================

Function SetCoSCloaks(String CoSPlugin)
	If !CoSInstalled
		_WetCloakRainList.AddForm(Game.GetFormFromFile(0x00000D67, CoSPlugin))
		_WetCloakRainList.AddForm(Game.GetFormFromFile(0x00005383, CoSPlugin))
		_WetCloakRainList.AddForm(Game.GetFormFromFile(0x00000D66, CoSPlugin))
		_WetCloakRainList.AddForm(Game.GetFormFromFile(0x0000538E, CoSPlugin))
		_WetCloakRainList.AddForm(Game.GetFormFromFile(0x00000D69, CoSPlugin))
		_WetCloakRainList.AddForm(Game.GetFormFromFile(0x00005392, CoSPlugin))
		_WetCloakRainList.AddForm(Game.GetFormFromFile(0x00011BD2, CoSPlugin))
		_WetCloakRainList.AddForm(Game.GetFormFromFile(0x00012151, CoSPlugin))
		_WetCloakRainList.AddForm(Game.GetFormFromFile(0x00012157, CoSPlugin))
	EndIf
	CoSInstalled = True
EndFunction

Function SetWiCCloaks(String WiCPlugin)
	If !WiCInstalled
		_WetCloakColdList.AddForm(Game.GetFormFromFile(0x00002345, WiCPlugin))
		_WetCloakColdList.AddForm(Game.GetFormFromFile(0x00002344, WiCPlugin))
		_WetCloakColdList.AddForm(Game.GetFormFromFile(0x0000233C, WiCPlugin))
		_WetCloakColdList.AddForm(Game.GetFormFromFile(0x00001DD7, WiCPlugin))

		_WetHoodColdArmoredList.AddForm(Game.GetFormFromFile(0x0001B48D, WiCPlugin))
		_WetHoodColdArmoredList.AddForm(Game.GetFormFromFile(0x0001B48C, WiCPlugin))
		_WetHoodColdArmoredList.AddForm(Game.GetFormFromFile(0x0001B48E, WiCPlugin))
		_WetHoodColdArmoredList.AddForm(Game.GetFormFromFile(0x00013CF4, WiCPlugin))
		_WetHoodColdArmoredList.AddForm(Game.GetFormFromFile(0x00013CF5, WiCPlugin))
		_WetHoodColdArmoredList.AddForm(Game.GetFormFromFile(0x00013CF6, WiCPlugin))
		_WetHoodColdArmoredList.AddForm(Game.GetFormFromFile(0x0001B490, WiCPlugin))
		_WetHoodColdArmoredList.AddForm(Game.GetFormFromFile(0x0001B48F, WiCPlugin))
		_WetHoodColdArmoredList.AddForm(Game.GetFormFromFile(0x0001B491, WiCPlugin))
		_WetHoodColdArmoredList.AddForm(Game.GetFormFromFile(0x00013CF7, WiCPlugin))
		_WetHoodColdArmoredList.AddForm(Game.GetFormFromFile(0x00013CF8, WiCPlugin))
		_WetHoodColdArmoredList.AddForm(Game.GetFormFromFile(0x00013CF9, WiCPlugin))
		_WetHoodColdArmoredList.AddForm(Game.GetFormFromFile(0x0001B493, WiCPlugin))
		_WetHoodColdArmoredList.AddForm(Game.GetFormFromFile(0x0001B492, WiCPlugin))
		_WetHoodColdArmoredList.AddForm(Game.GetFormFromFile(0x0001B494, WiCPlugin))
		_WetHoodColdArmoredList.AddForm(Game.GetFormFromFile(0x00013CFA, WiCPlugin))
		_WetHoodColdArmoredList.AddForm(Game.GetFormFromFile(0x00013CFB, WiCPlugin))
		_WetHoodColdArmoredList.AddForm(Game.GetFormFromFile(0x00013CFC, WiCPlugin))
		_WetHoodColdArmoredList.AddForm(Game.GetFormFromFile(0x0001AED0, WiCPlugin))
		_WetHoodColdArmoredList.AddForm(Game.GetFormFromFile(0x0001AED1, WiCPlugin))
		_WetHoodColdArmoredList.AddForm(Game.GetFormFromFile(0x0001AED2, WiCPlugin))
		_WetHoodColdArmoredList.AddForm(Game.GetFormFromFile(0x00012C98, WiCPlugin))
		_WetHoodColdArmoredList.AddForm(Game.GetFormFromFile(0x00012C99, WiCPlugin))
		_WetHoodColdArmoredList.AddForm(Game.GetFormFromFile(0x00012C9A, WiCPlugin))
		_WetHoodColdArmoredList.AddForm(Game.GetFormFromFile(0x0001AED6, WiCPlugin))
		_WetHoodColdArmoredList.AddForm(Game.GetFormFromFile(0x0001AED7, WiCPlugin))
		_WetHoodColdArmoredList.AddForm(Game.GetFormFromFile(0x0001AED8, WiCPlugin))
		_WetHoodColdArmoredList.AddForm(Game.GetFormFromFile(0x00013203, WiCPlugin))
		_WetHoodColdArmoredList.AddForm(Game.GetFormFromFile(0x00013204, WiCPlugin))
		_WetHoodColdArmoredList.AddForm(Game.GetFormFromFile(0x00013205, WiCPlugin))

		_WetHoodColdList.AddForm(Game.GetFormFromFile(0x000028CD, WiCPlugin))
		_WetHoodColdList.AddForm(Game.GetFormFromFile(0x000038F5, WiCPlugin))
		_WetHoodColdList.AddForm(Game.GetFormFromFile(0x000038F6, WiCPlugin))
		_WetHoodColdList.AddForm(Game.GetFormFromFile(0x0000C56B, WiCPlugin))
		_WetHoodColdList.AddForm(Game.GetFormFromFile(0x0000C56C, WiCPlugin))
		_WetHoodColdList.AddForm(Game.GetFormFromFile(0x0000C5CD, WiCPlugin))
		Utility.Wait(1.0)
	EndIf
	WiCInstalled = True
EndFunction

;====================================================================================

Function CheckWiCPlugins()
	If Game.GetFormFromFile(0x00001DD7, "1nivWICCloaksCRAFT.esp")			;Winter is Coming
		SetWiCCloaks("1nivWICCloaksCRAFT.esp")
	ElseIf Game.GetFormFromFile(0x00001DD7, "1nivWICCloaks.esp")
		SetWiCCloaks("1nivWICCloaks.esp")
	ElseIf Game.GetFormFromFile(0x00001DD7, "1nivWICCloaksNoGuards.esp")
		SetWiCCloaks("1nivWICCloaksNoGuards.esp")
	Else
		WiCInstalled = False
	EndIf
EndFunction

Function CheckCoSPlugins()
	If Game.GetFormFromFile(0x00000D67, "Cloaks.esp")						;Cloaks of Skyrim
		SetCoSCloaks("Cloaks.esp")
	ElseIf Game.GetFormFromFile(0x00000D67, "Cloaks - No Imperial.esp")
		SetCoSCloaks("Cloaks - No Imperial.esp")
	ElseIf Game.GetFormFromFile(0x00000D67, "Cloaks - Player Only.esp")
		SetCoSCloaks("Cloaks - Player Only.esp")
	Else
		CoSInstalled = False
	EndIf
EndFunction

Function CheckMainCloakPlugins()
	If CCORInstalled
		WiCInstalled = False
		CoSInstalled = False
	EndIf
	CheckWiCPlugins()
	CheckCoSPlugins()
	CCORInstalled = False
EndFunction

;====================================================================================

Function Maintenance()
	targ = PlayerRef
	Debug.Trace("")
	Debug.Trace("=====Wet and Cold is refreshing itself and searching for addons. Any errors below are harmless.=====")
	Debug.Trace("")

	WorldInterior = New Form[4]
	WorldInterior[0] = Blackreach as Form
	WorldInterior[1] = FallowstoneCaveWorldStart as Form

	If (SKSE.GetVersion() + SKSE.GetVersionMinor() * 0.01 + SKSE.GetVersionBeta() * 0.0001) > 0.0
		SKSE64Installed = True
	Else
		If SKSE64Installed
			Debug.Notification(NoSKSEText)
		EndIf
		SKSE64Installed = False
	EndIf

	If Game.GetFormFromFile(0x00000802, "SkyUI_SE.esp")		;SkyUI
		targ.RemoveSpell(_WetOldConfigSpell)
		SkyInstalled = True
	Else
		targ.AddSpell(_WetOldConfigSpell, false)
		SkyInstalled = False
	EndIf

	DGCat = Game.GetFormFromFile(0x0000D0B6, "Dawnguard.esm")
	If Game.GetFormFromFile(0x00003C67, "Dawnguard.esm")		;Dawnguard, vale sabrecat
		If !DGInstalled
			DGColdWorld = New Form[1]
			DGColdWorld[0] = Game.GetFormFromFile(0x00000BB5, "Dawnguard.esm")		;Falmer Valley
			DGHuskies = New Form[4]
			DGHuskies[0] = Game.GetFormFromFile(0x00003D01, "Dawnguard.esm")		;Huskies
			DGHuskies[1] = Game.GetFormFromFile(0x00018B33, "Dawnguard.esm")
			DGHuskies[2] = Game.GetFormFromFile(0x000122B7, "Dawnguard.esm")
			DGHuskies[3] = Game.GetFormFromFile(0x00018B36, "Dawnguard.esm")
			DGSnowElf = Game.GetFormFromFile(0x0000377D, "Dawnguard.esm")			;Snow elf
		EndIf
		WorldInterior[2] = Game.GetFormFromFile(0x00004BEA, "Dawnguard.esm")	;Darkfall
		WorldInterior[3] = Game.GetFormFromFile(0x000048C7, "Dawnguard.esm")	;Ancestors Glade
		DGInstalled = True
	Else
		DGInstalled = False
	EndIf

	DBDragon = Game.GetFormFromFile(0x0002C88C, "Dragonborn.esm")		;Dragonborn, black dragon
	If !DBInstalled
		DBWerebear = Game.GetFormFromFile(0x0001E17B, "Dragonborn.esm")		;Werebear
		DBLurker = Game.GetFormFromFile(0x00014495, "Dragonborn.esm")		;Lurker
		DBBoar = Game.GetFormFromFile(0x00024038, "Dragonborn.esm")			;Boar
		DBMountedRiek = Game.GetFormFromFile(0x000179CF, "Dragonborn.esm")	;Mounted Riekling
		DBRiek = Game.GetFormFromFile(0x00017F44, "Dragonborn.esm")			;Riekling
		DBThirskRiek = Game.GetFormFromFile(0x0001A50A, "Dragonborn.esm")	;Thirsk Riekling
		DLC2LItemMiscVendorArmor75 = Game.GetFormFromFile(0x000374FC, "Dragonborn.esm") as LeveledItem
		ColdCoversOn = True
		DBInstalled = True
	EndIf

	If Game.GetFormFromFile(0x00000DA1, "Wyrmstooth.esp")		;Wyrmstooth
		WTColdWorld = New Form[1]
		WTColdWorld[0] = Game.GetFormFromFile(0x00000D62, "Wyrmstooth.esp")		;Island
		WTInstalled = True
	Else
		WTInstalled = False
	EndIf

	If Game.GetFormFromFile(0x00024B64, "Frostfall.esp")		;Frostfall
		If !FFInstalled
			Debug.Notification(FFDripText)
			_WetDripPlayerToggle.SetValue(0)
		EndIf
		FFInstalled = True
	Else
		FFInstalled = False
	EndIf
	
	_WetBPFurList = Game.GetFormFromFile(0x0002C274, "Campfire.esm") as FormList	;Campfire
	If _WetBPFurList
		CampfireInstalled = True
	Else
		CampfireInstalled = False
	EndIf

	WaterskinList = Game.GetFormFromFile(0x00009479, "iNeed.esp") as FormList		;iNeed
	If WaterskinList
		WaterskinEquipSpell = Game.GetFormFromFile(0x0004B596, "iNeed.esp") as Spell
	EndIf

	If Game.GetFormFromFile(0x00000800, "getSnowy.esp")		;Get Snowy
		If !GetSnowyInstalled
			Debug.Notification(SnowyText)
			_WetSnowPlayerToggle.SetValue(0)
			_WetSnowActorToggle.SetValue(0)
		EndIf
		GetSnowyInstalled = True
	Else
		GetSnowyInstalled = False
	EndIf
	
	If Game.GetFormFromFile(0x00022FBA, "Immersive Citizens - AI Overhaul.esp")		;ICitizenAI
		If !ICitizenAIInstalled
			Debug.Notification(ICitizenAIText)
			_WetGoHomeToggle.SetValue(0)
			_WetGoHomeRainAllQuest.Stop()
			_WetGoHomeRainQuest.Stop()
			_WetGoHomeBlizzQuest.Stop()
		EndIf
		ICitizenAIInstalled = True
	Else
		ICitizenAIInstalled = False
	EndIf

	If Game.GetFormFromFile(0x00000EFF, "EFFCore.esm")		;EFF
		EFFInstalled = True
	Else
		EFFInstalled = False
	EndIf
	
	; Start Edits by AndrealphusVIII
	If Game.GetFormFromFile(0x000D3F2C, "BSHeartland.esm")		;Bruma
		ColdBSHeartland = New Form[1]
		ColdBSHeartland[0] = Game.GetFormFromFile(0x000A764B, "BSHeartland.esm")		;Cyrodiil
		CountyBruma = Game.GetFormFromFile(0x00000F17, "BSHeartland.esm") as Location			;County Bruma
		BSHeartlandInstalled = True
	Else
		BSHeartlandInstalled = False
	EndIf	
	; End Edits by AndrealphusVIII

	CalcListLengths()

	If fModVersion
		If SkyInstalled && SKSE64Installed
			_WetSKConfigQuest.OnConfigInit()
		EndIf
		If fModVersion < 2.40			;CHANGE VERSION NUMBER WHEN UPDATING
			ModUpdated = True
			Restart()
			Debug.Notification(UpdateText + "v2.4.0")	;CHANGE VERSION NUMBER WHEN UPDATING
		EndIf
	Else
		If SkyInstalled && SKSE64Installed
			_WetSKConfigQuest.OnConfigInit()
		EndIf
		EnableMod()
	EndIf
	
	fModVersion = 2.40			;CHANGE VERSION NUMBER WHEN UPDATING
	ModUpdated = False
	Debug.Trace("")
	Debug.Trace("=====Wet and Cold is finished refreshing itself and searching for addons!=====")
	Debug.Trace("")
EndFunction

;====================================================================================

Function DisableMod()
	ModUpdated = True
	ScanArea()
	targ.RemoveSpell(_WetPlayerSpell)
	targ.RemoveSpell(_WetPlayerAshSpell)
	targ.RemoveSpell(_WetPlayerRegionSpell)
	targ.RemoveSpell(_WetPlayerAshRegionSpell)
	targ.RemoveSpell(_WetNPCSwimWetFeetSpell)
	targ.RemoveSpell(_WetOldConfigSpell)
	_WetGoHomeRainAllQuest.Stop()
	_WetGoHomeRainQuest.Stop()
	_WetGoHomeBlizzQuest.Stop()
	Utility.Wait(0.5)
	ModUpdated = False
EndFunction

Function EnableMod()
	targ.AddSpell(_WetPlayerSpell, false)
	targ.AddSpell(_WetPlayerAshSpell, false)
	targ.AddSpell(_WetPlayerRegionSpell, false)
	targ.AddSpell(_WetPlayerAshRegionSpell, false)
	If !SkyInstalled
		targ.AddSpell(_WetOldConfigSpell, false)
	EndIf
EndFunction

Function Restart()
	ModRestarted = True
	targ = PlayerRef
	DisableMod()
	EnableMod()
	Utility.Wait(1.0)
	ModRestarted = False
EndFunction

;====================================================================================

Event OnInit()
	Utility.Wait(5.0)
	Maintenance()
EndEvent