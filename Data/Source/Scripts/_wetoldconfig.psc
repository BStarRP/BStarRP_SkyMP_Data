Scriptname _wetoldconfig extends activemagiceffect  

;====================================================================================

Message Property _WetConfigAshMsg Auto
Message Property _WetConfigColdMsg Auto
Message Property _WetConfigAshGearMsg Auto
Message Property _WetConfigColdGearMsg Auto
Message Property _WetConfigMsg Auto
Message Property _WetConfigToggleMsg Auto
Message Property _WetConfigWetMsg Auto

_WetQuestScript Property _WetQuest Auto
_WetSkyUIConfig Property _WetSKConfigQuest Auto

Bool Restart

Actor targ

;====================================================================================

Function Menu(Int iButton = -1)
	iButton = _WetConfigMsg.Show()
	If iButton == 0						;Wet
		WetMenu()
	ElseIf iButton == 1					;Cold
		ColdMenu()
	ElseIf iButton == 2					;Ashes
		AshMenu()
	ElseIf iButton == 3					;Exit
		If Restart
			_WetQuest.Restart()
		EndIf
	EndIf
EndFunction

Function WetMenu(Int iButton = -1)
	iButton = _WetConfigWetMsg.Show()
	If iButton == 0						;drips
		WetDripsMenu()
	ElseIf iButton == 1					;soggyfeet
		WetSoggyMenu()
	ElseIf iButton == 2					;rainblind
		WetBlindMenu()
	ElseIf iButton == 3					;gohome
		WetGoHomeMenu()
	ElseIf iButton == 4					;raingear
		WetGearMenu()
	ElseIf iButton == 5
		Menu()
	EndIf
EndFunction

Function ColdMenu(Int iButton = -1)
	iButton = _WetConfigColdMsg.Show()
	If iButton == 0						;breaths
		ColdBreathsMenu()
	ElseIf iButton == 1					;snowy
		ColdSnowyMenu()
	ElseIf iButton == 2					;blizzblind
		ColdBlindMenu()
	ElseIf iButton == 3					;strongwinds
		ColdStrongWindsMenu()
	ElseIf iButton == 4					;coldgear
		ColdGearMenu()
	ElseIf iButton == 5
		Menu()
	EndIf
EndFunction

Function AshMenu(Int iButton = -1)
	iButton = _WetConfigAshMsg.Show()
	If iButton == 0						;dusty
		AshDustyMenu()
	ElseIf iButton == 1					;watereyes
		AshWateryEyesMenu()
	ElseIf iButton == 2					;ash/surv gear
		AshGearMenu()
	ElseIf iButton == 3					;gohome
		Menu()
	EndIf
EndFunction

;======================================================	

Function WetDripsMenu(Int iButton = -1)
	iButton = _WetConfigToggleMsg.Show()
	If iButton == 0
		_WetQuest._WetDripPlayerToggle.SetValue(0)
		_WetQuest._WetDripActorToggle.SetValue(0)
	ElseIf iButton == 1
		_WetQuest._WetDripPlayerToggle.SetValue(1)
		_WetQuest._WetDripActorToggle.SetValue(1)
	ElseIf iButton == 2
		WetMenu()
	EndIf
	If iButton < 2
		Debug.Notification(_WetQuest.ConfigText)
		WetDripsMenu()
	EndIf
EndFunction

Function WetSoggyMenu(Int iButton = -1)
	iButton = _WetConfigToggleMsg.Show()
	If iButton == 0
		_WetQuest._WetFootWetPlayerToggle.SetValue(0)
		_WetQuest._WetFootWetActorToggle.SetValue(0)
	ElseIf iButton == 1
		_WetQuest._WetFootWetPlayerToggle.SetValue(1)
		_WetQuest._WetFootWetActorToggle.SetValue(1)
	ElseIf iButton == 2
		WetMenu()
	EndIf
	If iButton < 2
		Debug.Notification(_WetQuest.ConfigText)
		WetSoggyMenu()
	EndIf
EndFunction

Function WetBlindMenu(Int iButton = -1)
	iButton = _WetConfigToggleMsg.Show()
	If iButton == 0
		_WetQuest._WetRainBlindToggle.SetValue(0)
	ElseIf iButton == 1
		_WetQuest._WetRainBlindToggle.SetValue(1)
	ElseIf iButton == 2
		WetMenu()
	EndIf
	If iButton < 2
		Debug.Notification(_WetQuest.ConfigText)
		WetBlindMenu()
	EndIf
EndFunction

Function WetGoHomeMenu(Int iButton = -1)
	iButton = _WetConfigToggleMsg.Show()
	If iButton == 0
		_WetQuest._WetGoHomeToggle.SetValue(0)
		_WetQuest._WetGoHomeRainAllQuest.Stop()
		_WetQuest._WetGoHomeRainQuest.Stop()
		_WetQuest._WetGoHomeBlizzQuest.Stop()
	ElseIf iButton == 1
		_WetQuest._WetGoHomeToggle.SetValue(1)
	ElseIf iButton == 2
		WetMenu()
	EndIf
	If iButton < 2
		Debug.Notification(_WetQuest.ConfigText)
		WetGoHomeMenu()
	EndIf
EndFunction

Function WetGearMenu(Int iButton = -1)
	iButton = _WetConfigToggleMsg.Show()
	If iButton == 1 && !_WetSKConfigQuest.PurchRainHoodSet
		_WetQuest.LItemMiscVendorMiscItems75.AddForm(_WetQuest._WetRainHoodLItem, 1, 1)
		_WetQuest.LItemMiscVendorMiscItems75.AddForm(_WetQuest._WetRainHoodLItem, 1, 1)
		_WetQuest.LItemMiscVendorArmor75.AddForm(_WetQuest._WetRainHoodLItem, 1, 1)
		_WetQuest.LItemClothesAll.AddForm(_WetQuest._WetRainHoodLItem, 1, 1)
		_WetQuest.LItemMiscVendorClothing75.AddForm(_WetQuest._WetRainHoodLItem, 1, 1)
		_WetQuest.LItemMiscVendorMiscItems75.AddForm(_WetQuest._WetRainCloakLItem, 1, 1)
		_WetQuest.LItemMiscVendorMiscItems75.AddForm(_WetQuest._WetRainCloakLItem, 1, 1)
		_WetQuest.LItemMiscVendorMiscItems75.AddForm(_WetQuest._WetRainCloakLItem, 1, 1)
		_WetQuest.LItemMiscVendorArmor75.AddForm(_WetQuest._WetRainCloakLItem, 1, 1)
		_WetQuest.LItemMiscVendorArmor75.AddForm(_WetQuest._WetRainCloakLItem, 1, 1)
		_WetQuest.LItemClothesAll.AddForm(_WetQuest._WetRainCloakLItem, 1, 1)
		_WetQuest.LItemMiscVendorClothing75.AddForm(_WetQuest._WetRainCloakLItem, 1, 1)
		_WetSKConfigQuest.PurchRainCloakSet = True
		_WetSKConfigQuest.PurchRainHoodSet = True
	EndIf
	If iButton == 1
		Debug.Notification(_WetQuest.ConfigText)
	EndIf
	WetMenu()
EndFunction

;======================================================	

Function ColdBreathsMenu(Int iButton = -1)
	iButton = _WetConfigToggleMsg.Show()
	If iButton == 0
		_WetQuest._WetBreathPlayerToggle.SetValue(0)
		_WetQuest._WetBreath1stToggle.SetValue(0)
		_WetQuest._WetBreathActorToggle.SetValue(0)
	ElseIf iButton == 1
		_WetQuest._WetBreathPlayerToggle.SetValue(1)
		_WetQuest._WetBreath1stToggle.SetValue(1)
		_WetQuest._WetBreathActorToggle.SetValue(1)
	ElseIf iButton == 2
		ColdMenu()
	EndIf
	If iButton < 2
		Debug.Notification(_WetQuest.ConfigText)
		ColdBreathsMenu()
	EndIf
EndFunction

Function ColdSnowyMenu(Int iButton = -1)
	iButton = _WetConfigToggleMsg.Show()
	If iButton == 0
		_WetQuest._WetSnowPlayerToggle.SetValue(0)
		_WetQuest._WetSnowActorToggle.SetValue(0)
	ElseIf iButton == 1
		_WetQuest._WetSnowPlayerToggle.SetValue(1)
		_WetQuest._WetSnowActorToggle.SetValue(1)
	ElseIf iButton == 2
		ColdMenu()
	EndIf
	If iButton < 2
		Debug.Notification(_WetQuest.ConfigText)
		ColdSnowyMenu()
	EndIf
EndFunction

Function ColdBlindMenu(Int iButton = -1)
	iButton = _WetConfigToggleMsg.Show()
	If iButton == 0
		_WetQuest._WetBlizzBlindPlayerToggle.SetValue(0)
		_WetQuest._WetBlizzBlindToggle.SetValue(0)
	ElseIf iButton == 1
		_WetQuest._WetBlizzBlindPlayerToggle.SetValue(1)
		_WetQuest._WetBlizzBlindToggle.SetValue(1)
	ElseIf iButton == 2
		ColdMenu()
	EndIf
	If iButton < 2
		Debug.Notification(_WetQuest.ConfigText)
		ColdBlindMenu()
	EndIf
EndFunction

Function ColdStrongWindsMenu(Int iButton = -1)
	iButton = _WetConfigToggleMsg.Show()
	If iButton == 0
		_WetQuest._WetWindToggle.SetValue(0)
	ElseIf iButton == 1
		_WetQuest._WetWindToggle.SetValue(1)
	ElseIf iButton == 2
		ColdMenu()
	EndIf
	If iButton < 2
		Debug.Notification(_WetQuest.ConfigText)
		ColdStrongWindsMenu()
	EndIf
EndFunction

Function ColdGearMenu(Int iButton = -1)
	iButton = _WetConfigColdGearMsg.Show()
	If iButton == 0
		_WetQuest._WetColdGearToggle.SetValue(0)
	ElseIf iButton == 1
		_WetQuest._WetColdGearToggle.SetValue(1)
	ElseIf iButton == 2 && !_WetSKConfigQuest.PurchColdCloakSet
		_WetQuest.LItemMiscVendorMiscItems75.AddForm(_WetQuest._WetColdCloakLItem, 1, 1)
		_WetQuest.LItemMiscVendorMiscItems75.AddForm(_WetQuest._WetColdCloakLItem, 1, 1)
		_WetQuest.LItemMiscVendorMiscItems75.AddForm(_WetQuest._WetColdCloakLItem, 1, 1)
		_WetQuest.LItemMiscVendorArmor75.AddForm(_WetQuest._WetColdCloakLItem, 1, 1)
		_WetQuest.LItemMiscVendorArmor75.AddForm(_WetQuest._WetColdCloakLItem, 1, 1)
		_WetQuest.LItemClothesAll.AddForm(_WetQuest._WetColdCloakLItem, 1, 1)
		_WetQuest.LItemMiscVendorClothing75.AddForm(_WetQuest._WetColdCloakLItem, 1, 1)
		_WetQuest.LItemMiscVendorMiscItems75.AddForm(_WetQuest._WetColdHoodLItem, 1, 1)
		_WetQuest.LItemMiscVendorMiscItems75.AddForm(_WetQuest._WetColdHoodLItem, 1, 1)
		_WetQuest.LItemMiscVendorArmor75.AddForm(_WetQuest._WetColdHoodLItem, 1, 1)
		_WetQuest.LItemClothesAll.AddForm(_WetQuest._WetColdHoodLItem, 1, 1)
		_WetQuest.LItemMiscVendorClothing75.AddForm(_WetQuest._WetColdHoodLItem, 1, 1)
		_WetQuest.LItemMiscVendorMiscItems75.AddForm(_WetQuest._WetColdGloveLItem, 1, 1)
		_WetQuest.LItemMiscVendorMiscItems75.AddForm(_WetQuest._WetColdGloveLItem, 1, 1)
		_WetQuest.LItemMiscVendorArmor75.AddForm(_WetQuest._WetColdGloveLItem, 1, 1)
		_WetQuest.LItemClothesAll.AddForm(_WetQuest._WetColdGloveLItem, 1, 1)
		_WetQuest.LItemMiscVendorClothing75.AddForm(_WetQuest._WetColdGloveLItem, 1, 1)
		_WetQuest.LItemMiscVendorMiscItems75.AddForm(_WetQuest._WetColdFaceCoverLItem, 1, 1)
		_WetQuest.LItemMiscVendorMiscItems75.AddForm(_WetQuest._WetColdFaceCoverLItem, 1, 1)
		_WetQuest.LItemMiscVendorMiscItems75.AddForm(_WetQuest._WetColdFaceCoverLItem, 1, 1)
		_WetQuest.LItemMiscVendorArmor75.AddForm(_WetQuest._WetColdFaceCoverLItem, 1, 1)
		_WetQuest.LItemMiscVendorArmor75.AddForm(_WetQuest._WetColdFaceCoverLItem, 1, 1)
		_WetQuest.LItemMiscVendorClothing75.AddForm(_WetQuest._WetColdFaceCoverLItem, 1, 1)
		_WetSKConfigQuest.PurchColdFaceCoverSet = True
		_WetSKConfigQuest.PurchColdGloveSet = True
		_WetSKConfigQuest.PurchColdHoodSet = True
		_WetSKConfigQuest.PurchColdCloakSet = True
	EndIf
	If iButton < 3
		Debug.Notification(_WetQuest.ConfigText)
		ColdGearMenu()
	Else
		ColdMenu()
	EndIf
EndFunction
			
;======================================================	

Function AshDustyMenu(Int iButton = -1)
	iButton = _WetConfigToggleMsg.Show()
	If iButton == 0
		_WetQuest._WetDustPlayerToggle.SetValue(0)
		_WetQuest._WetDustActorToggle.SetValue(0)
	ElseIf iButton == 1
		_WetQuest._WetDustPlayerToggle.SetValue(1)
		_WetQuest._WetDustActorToggle.SetValue(1)
	ElseIf iButton == 2
		AshMenu()
	EndIf
	If iButton < 2
		Debug.Notification(_WetQuest.ConfigText)
		AshDustyMenu()
	EndIf
EndFunction

Function AshWateryEyesMenu(Int iButton = -1)
	iButton = _WetConfigToggleMsg.Show()
	If iButton == 0
		_WetQuest._WetWateryEyesToggle.SetValue(0)
	ElseIf iButton == 1
		_WetQuest._WetWateryEyesToggle.SetValue(1)
	ElseIf iButton == 2
		AshMenu()
	EndIf
	If iButton < 2
		Debug.Notification(_WetQuest.ConfigText)
		AshWateryEyesMenu()
	EndIf
EndFunction

Function AshGearMenu(Int iButton = -1)
	iButton = _WetConfigAshGearMsg.Show()
	If iButton == 0
		_WetQuest.SurvGearOn = False
		_WetQuest._WetSurvGearToggle.SetValue(0)
	ElseIf iButton == 1
		_WetQuest.SurvGearOn = True
		_WetQuest._WetSurvGearToggle.SetValue(1)
	ElseIf iButton == 2 && !_WetSKConfigQuest.PurchSurvivalBPSet
		_WetQuest.LItemMiscVendorMiscItems75.AddForm(_WetQuest._WetSurvivalBPLItem, 1, 1)
		_WetQuest.LItemMiscVendorMiscItems75.AddForm(_WetQuest._WetSurvivalBPLItem, 1, 1)
		_WetQuest.LItemMiscVendorMiscItems75.AddForm(_WetQuest._WetSurvivalBPLItem, 1, 1)
		_WetQuest.LItemMiscVendorMiscItems75.AddForm(_WetQuest._WetSurvivalBPLItem, 1, 1)
		_WetQuest.LItemMiscVendorArmor75.AddForm(_WetQuest._WetSurvivalBPLItem, 1, 1)
		_WetQuest.LItemMiscVendorArmor75.AddForm(_WetQuest._WetSurvivalBPLItem, 1, 1)
		_WetQuest.LItemMiscVendorArmor75.AddForm(_WetQuest._WetSurvivalBPLItem, 1, 1)
		_WetQuest.LItemMiscVendorClothing75.AddForm(_WetQuest._WetSurvivalBPLItem, 1, 1)
		_WetQuest.DLC2LItemMiscVendorArmor75.AddForm(_WetQuest._WetAshFaceCoverLItem, 1, 1)
		_WetQuest.DLC2LItemMiscVendorArmor75.AddForm(_WetQuest._WetAshFaceCoverLItem, 1, 1)
		_WetQuest.DLC2LItemMiscVendorArmor75.AddForm(_WetQuest._WetAshFaceCoverLItem, 1, 1)
		_WetQuest.DLC2LItemMiscVendorArmor75.AddForm(_WetQuest._WetAshGoggleLItem, 1, 1)
		_WetQuest.DLC2LItemMiscVendorArmor75.AddForm(_WetQuest._WetAshGoggleLItem, 1, 1)
		_WetQuest.DLC2LItemMiscVendorArmor75.AddForm(_WetQuest._WetAshGoggleLItem, 1, 1)
		_WetSKConfigQuest.PurchAshGoggleSet = True
		_WetSKConfigQuest.PurchAshFaceCoverSet = True
		_WetSKConfigQuest.PurchSurvivalBPSet = True
	EndIf
	If iButton < 3
		Debug.Notification(_WetQuest.ConfigText)
		AshGearMenu()
	Else
		AshMenu()	
	EndIf
EndFunction

;====================================================================================

Event OnEffectStart(Actor akTarget, Actor akCaster)
	targ = akTarget
	If targ == _WetQuest.PlayerRef
		Menu()
	EndIf
EndEvent