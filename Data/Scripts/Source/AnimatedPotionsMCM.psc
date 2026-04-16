Scriptname AnimatedPotionsMCM extends SKI_ConfigBase

;Changelog:
; 5.0.0
; - Cleaned code for better readability and using better practices for more stable code.
; - Force close menu removed, because its implementation may interfere with other mods using the same function.
; - Removed the ability to adjust slow spell strength as its pretty useless at values that vary a lot from default 50.; - Changed some naming schemes for better understandability.
; - Added toggleWaitForMenuClose
; - Added togglePotionSplash
; - Added toggleSpawnEmptyBottles
; - Changed MCM setting naming and descriptions to better communicate the setting.


Import PO3_SKSEFunctions

Quest property AnimatedPotionsQuest auto

;PLAYER
GlobalVariable property TogglePlayerPotionAnimation auto
GlobalVariable property ToggleStopSprint auto
GlobalVariable property ToggleForceThirdPerson auto
GlobalVariable property TogglePlayerSlowEffect auto
GlobalVariable property TogglePlayerStagger auto
GlobalVariable property TogglePlayerStopAnimation auto
GlobalVariable property ToggleDisableDuringCombat auto
GlobalVariable property ToggleWaitForMenuClose auto
GlobalVariable property ToggleRequireKeyword auto
GlobalVariable property toggleSpawnEmptyBottles auto
GlobalVariable property togglePotionSplash auto
GlobalVariable property ToggleReverBackToFPS auto
GlobalVariable property TogglePlayerSound auto
int OID_TogglePlayerPotionAnimation
int OID_ToggleStopSprint
int OID_ToggleForceThirdPerson
int OID_TogglePlayerSlowEffect
int OID_TogglePlayerStagger
int OID_TogglePlayerStopAnimation
int OID_ToggleDisableDuringCombat
int OID_ToggleWaitForMenuClose
int OID_ToggleRequireKeyword
int OID_toggleSpawnEmptyBottles
int OID_togglePotionSplash
int OID_ToggleReverBackToFPS
int OID_TogglePlayerSound

;NPC
GlobalVariable property ToggleNPCPotionAnimation auto
GlobalVariable property ToggleNPCSlowEffect auto
GlobalVariable property ToggleNPCSound auto
GlobalVariable property NPCStaggerToggle auto
GlobalVariable property NPCStopAnimation auto
GlobalVariable property ForceNPCDrinking auto
int OID_ToggleNPCPotionAnimation
int OID_ToggleNPCSlowEffect
int OID_ToggleNPCSound
int OID_NPCStaggerToggle
int OID_NPCStopAnimation
int OID_ForceNPCDrinking

;MCM colors
string TitleColor = "#FFD59A" 
string InfoColor = "#ABC3FC"
string OnColor = "#76FF38"
string OffColor = "#FF3838"

string CurrentSwitchColor
string CurrentNPCSwitchColor

; Jerry rig map of integers and global variables for association
;---------------
int[] OptionIDs; Keys
GlobalVariable[] globalVariables; Values
;---------------

Function OnConfigInit()
	Pages = new string[1]
	Pages[0] = ""
endFunction


Event OnPageReset(string page)
	globalVariables = New GlobalVariable[21]
	OptionIDs = New int[21]
	if page == ""
		if TogglePlayerPotionAnimation.GetValueint() == 1
			CurrentSwitchColor = OnColor
		else
			CurrentSwitchColor = OffColor
		endif
		if ToggleNPCPotionAnimation.GetValueint() == 1
			CurrentNPCSwitchColor = OnColor
		else
			CurrentNPCSwitchColor = OffColor
		endif
		self.UnloadCustomContent() 
		SetCursorFillMode(TOP_TO_BOTTOM)	
		SetCursorPosition(0)
		AddHeaderOption("<font color='"+TitleColor+"'>Master switches</font>")

		OID_TogglePlayerPotionAnimation = AddToggleOption("<font color='"+CurrentSwitchColor+"'>Player potion animations</font>", TogglePlayerPotionAnimation.GetValue())
		globalVariables[0] = TogglePlayerPotionAnimation
		OptionIDs[0] = OID_TogglePlayerPotionAnimation

		OID_ToggleNPCPotionAnimation = AddToggleOption("<font color='"+CurrentNPCSwitchColor+"'>NPC potion animations</font>", ToggleNPCPotionAnimation.GetValue())
		globalVariables[1] = ToggleNPCPotionAnimation
		OptionIDs[1] = OID_ToggleNPCPotionAnimation

		AddHeaderOption("<font color='"+TitleColor+"'>Player options</font>")
		OID_TogglePlayerSlowEffect = AddToggleOption("Slow player movement", TogglePlayerSlowEffect.GetValue())
		globalVariables[2] = TogglePlayerSlowEffect
		OptionIDs[2] = OID_TogglePlayerSlowEffect

		OID_ToggleStopSprint = AddToggleOption("Stop sprinting", ToggleStopSprint.GetValue())
		globalVariables[3] = ToggleStopSprint
		OptionIDs[3] = OID_ToggleStopSprint

		OID_togglePotionSplash = AddToggleOption("Potion splashing effect", togglePotionSplash.GetValue())
		globalVariables[19] = togglePotionSplash
		OptionIDs[19] = OID_togglePotionSplash

		OID_ToggleReverBackToFPS = AddToggleOption("Revert back to 1st person",ToggleReverBackToFPS.GetValue())
		globalVariables[20] = ToggleReverBackToFPS
		OptionIDs[20] = OID_ToggleReverBackToFPS

		OID_ToggleForceThirdPerson = AddToggleOption("Force 3rd person", ToggleForceThirdPerson.GetValue())
		globalVariables[4] = ToggleForceThirdPerson
		OptionIDs[4] = OID_ToggleForceThirdPerson


		OID_TogglePlayerSound = AddToggleOption("Toggle sound", TogglePlayerSound.GetValue())
		globalVariables[6] = TogglePlayerSound
		OptionIDs[6] = OID_TogglePlayerSound

		OID_toggleSpawnEmptyBottles  = AddToggleOption("Empty bottles", toggleSpawnEmptyBottles.GetValue())
		globalVariables[7] = toggleSpawnEmptyBottles
		OptionIDs[7] = OID_toggleSpawnEmptyBottles

		

		OID_ToggleWaitForMenuClose = AddToggleOption("Wait for menu close", ToggleWaitForMenuClose.GetValue())
		globalVariables[8] = ToggleWaitForMenuClose
		OptionIDs[8] = OID_ToggleWaitForMenuClose

		SetCursorPosition(1)
		AddHeaderOption("")

		OID_ToggleDisableDuringCombat = AddToggleOption("Disable drinking animations during combat", ToggleDisableDuringCombat.GetValue())
		globalVariables[10] = ToggleDisableDuringCombat
		OptionIDs[10] = OID_ToggleDisableDuringCombat

		OID_ToggleRequireKeyword = AddToggleOption("Only 'VendorItemPotion' potions", ToggleRequireKeyword.GetValue())
		globalVariables[11] = ToggleRequireKeyword
		OptionIDs[11] = OID_ToggleRequireKeyword

		
		AddHeaderOption("<font color='"+TitleColor+"'>NPC Options</font>")

		OID_ToggleNPCSlowEffect = AddToggleOption("Slow NPC movement", ToggleNPCSlowEffect.GetValue())
		globalVariables[12] = ToggleNPCSlowEffect
		OptionIDs[12] = OID_ToggleNPCSlowEffect
		
		OID_ToggleNPCSound = AddToggleOption("Toggle NPC sound", ToggleNPCSound.GetValue())
		globalVariables[13] = ToggleNPCSound
		OptionIDs[13] = OID_ToggleNPCSound

		OID_ForceNPCDrinking = AddToggleOption("Force NPC to drink", ForceNPCDrinking.GetValue())
		globalVariables[14] = ForceNPCDrinking
		OptionIDs[14] = OID_ForceNPCDrinking

		AddHeaderOption("<font color='"+TitleColor+"'>On hit options</font>")

		OID_TogglePlayerStagger = AddToggleOption("Hit staggers player", TogglePlayerStagger.GetValueint())
		globalVariables[15] = TogglePlayerStagger
		OptionIDs[15] = OID_TogglePlayerStagger

		OID_TogglePlayerStopAnimation = AddToggleOption("Stagger stops player animation", TogglePlayerStopAnimation.GetValueint())
		globalVariables[16] = TogglePlayerStopAnimation
		OptionIDs[16] = OID_TogglePlayerStopAnimation

		OID_NPCStaggerToggle = AddToggleOption("Hit staggers NPC", NPCStaggerToggle.GetValueint())
		globalVariables[17] = NPCStaggerToggle
		OptionIDs[17] = OID_NPCStaggerToggle

		OID_NPCStopAnimation = AddToggleOption("Stagger stops NPC animations", NPCStopAnimation.GetValueint())
		globalVariables[18] = NPCStopAnimation
		OptionIDs[18] = OID_NPCStopAnimation
	endif
EndEvent

Event OnOptionHighlight(int Option)
	if (Option == OID_ToggleNPCPotionAnimation)
		SetInfoText("Potion drinking animations for NPCs for restore and invisibility potions. Disable everytime before making any changes to potions with mods.")
	elseif (Option == OID_ToggleNPCSlowEffect)
		SetInfoText("Slows NPC movement while drinking potion.")
	elseif (Option == OID_ToggleNPCSound)
		SetInfoText("Plays NPC potion drinking sound effect.")
	elseif (Option == OID_NPCStaggerToggle)
		SetInfoText("Staggers NPC when getting hit while drinking potion.")
	elseif (Option == OID_NPCStopAnimation)
		SetInfoText("NPC animation gets cancelled when getting hit while drinking potion.")
	elseif (Option == OID_ForceNPCDrinking)
		SetInfoText("Make NPC drink potion if they consume it while being staggered or knocked.")
	elseif (Option == OID_TogglePlayerPotionAnimation)
		SetInfoText("Potion drinking animations for player.")
	elseif (Option == OID_ToggleStopSprint)
		SetInfoText("Forcibly stops player when sprinting to drink potion.")
	elseif (Option == OID_ToggleForceThirdPerson)
		SetInfoText("Switches player to 3rd person view from 1st person view. Returns to 1st person view after potion drinking.")
	elseif (Option == OID_TogglePlayerSlowEffect)
		SetInfoText("Slows player movement while potion drinking.")
	elseif (Option == OID_TogglePlayerSound)
		SetInfoText("Toggle player potion drinking sound effect.")
	elseif (Option == OID_TogglePlayerStagger)
		SetInfoText("Staggers player when getting hit while drinking potion.")
	elseif (Option == OID_TogglePlayerStopAnimation)
		SetInfoText("Animation gets cancelled when getting hit while drinking potion.")
	elseif (Option == OID_ToggleWaitForMenuClose)
		SetInfoText("Toggle to wait for menu closing before drinking potion (Only disable if you use SkyrimSouls mod).")
	elseif (Option == OID_ToggleDisableDuringCombat)
		SetInfoText("Disable potion animations for player during combat situations.")
	elseif (Option == OID_ToggleRequireKeyword)
		SetInfoText("Filter out potions that do not have keyword 'VendorItemPotion' to not play animation for them.")
	elseif (Option == OID_toggleSpawnEmptyBottles)
		SetInfoText("Empty potion bottle stays on the ground or gets added to inventory after potion use. Bottle can be smelted to glass at smelters.")
	elseif (Option == OID_togglePotionSplash)
		SetInfoText("Potion splashes out of the bottle when drinking.")
	elseif (Option == OID_toggleReverBackToFPS)
		SetInfoText("If 'Force Third Person' is on and player is in 1st person when drinking potion, player is returned to 1st person after drinking potion.")
	endif
EndEvent


Event OnOptionSelect(int option)
	if (option == OID_TogglePlayerPotionAnimation)
		if TogglePlayerPotionAnimation.GetValue() == 1
			CurrentSwitchColor = OffColor
			TogglePlayerPotionAnimation.SetValue(0)
			SetToggleOptionValue(OID_TogglePlayerPotionAnimation, 0)
			AnimatedPotionsQuest.Stop()
			ForcePageReset()
		elseif TogglePlayerPotionAnimation.GetValue() == 0
			CurrentSwitchColor = OnColor
			TogglePlayerPotionAnimation.SetValue(1)
			SetToggleOptionValue(OID_TogglePlayerPotionAnimation, 1)
			AnimatedPotionsQuest.Start()
			ForcePageReset()
		endif
	elseif (option == OID_ToggleNPCPotionAnimation)
		if ToggleNPCPotionAnimation.GetValue() == 1
			CurrentNPCSwitchColor = OffColor
			ToggleNPCPotionAnimation.SetValue(0)
			SetToggleOptionValue(OID_ToggleNPCPotionAnimation, 0)
			ClearPopulatedPotions()
			ForcePageReset()
		elseif ToggleNPCPotionAnimation.GetValue() == 0
			CurrentNPCSwitchColor = OnColor
			ToggleNPCPotionAnimation.SetValue(1)
			SetToggleOptionValue(OID_ToggleNPCPotionAnimation, 1)
			PopulatePotions()
			ForcePageReset()
		endif
	else
		SwitchToggle(option)
	endif
EndEvent


; Flip Flop for OptionID and its associated GlobalVariable value
Function SwitchToggle(int option)
	int foundIndex = OptionIDs.Find(option)
	if foundIndex < 0
		return
	endif

	GlobalVariable foundVariable = globalVariables[foundIndex]
	if foundVariable.GetValue() == 1
		foundVariable.SetValue(0)
		SetToggleOptionValue(option, 0)
	elseif foundVariable.GetValue() == 0
		foundVariable.SetValue(1)
		SetToggleOptionValue(option, 1)
	endif
EndFunction

;NPC potion segment. Below are currently supported potions.
Potion property RestoreHealth01 auto
Potion property RestoreHealth02 auto
Potion property RestoreHealth03 auto
Potion property RestoreHealth04 auto
Potion property RestoreHealth05 auto
Potion property RestoreHealth06 auto
Potion property RestoreStamina01 auto
Potion property RestoreStamina02 auto
Potion property RestoreStamina03 auto
Potion property RestoreStamina04 auto
Potion property RestoreStamina05 auto
Potion property RestoreStamina06 auto
Potion property RestoreMagicka01 auto
Potion property RestoreMagicka02 auto
Potion property RestoreMagicka03 auto
Potion property RestoreMagicka04 auto
Potion property RestoreMagicka05 auto
Potion property RestoreMagicka06 auto
Potion property Invisibility01 auto
Potion property Invisibility02 auto
Potion property Invisibility03 auto
Potion property Invisibility04 auto

MagicEffect property RestoreHealth01ME auto
MagicEffect property RestoreHealth02ME auto
MagicEffect property RestoreHealth03ME auto
MagicEffect property RestoreHealth04ME auto
MagicEffect property RestoreHealth05ME auto
MagicEffect property RestoreHealth06ME auto
MagicEffect property RestoreStamina01ME auto
MagicEffect property RestoreStamina02ME auto
MagicEffect property RestoreStamina03ME auto
MagicEffect property RestoreStamina04ME auto
MagicEffect property RestoreStamina05ME auto
MagicEffect property RestoreStamina06ME auto
MagicEffect property RestoreMagicka01ME auto
MagicEffect property RestoreMagicka02ME auto
MagicEffect property RestoreMagicka03ME auto
MagicEffect property RestoreMagicka04ME auto
MagicEffect property RestoreMagicka05ME auto
MagicEffect property RestoreMagicka06ME auto
MagicEffect property Invisibility01ME auto
MagicEffect property Invisibility02ME auto
MagicEffect property Invisibility03ME auto
MagicEffect property Invisibility04ME auto


Function PopulatePotions()
	string[] EmptyList
	Debug.Notification("Adding NPC poisons please wait...")
    AddMagicEffectToPotion(RestoreHealth01, RestoreHealth01ME, 0.0, 0, 12, 0.0, EmptyList)
    AddMagicEffectToPotion(RestoreHealth02, RestoreHealth02ME, 0.0, 0, 12, 0.0, EmptyList)
    AddMagicEffectToPotion(RestoreHealth03, RestoreHealth03ME, 0.0, 0, 12, 0.0, EmptyList)
    AddMagicEffectToPotion(RestoreHealth04, RestoreHealth04ME, 0.0, 0, 12, 0.0, EmptyList)
    AddMagicEffectToPotion(RestoreHealth05, RestoreHealth05ME, 0.0, 0, 12, 0.0, EmptyList)
    AddMagicEffectToPotion(RestoreHealth06, RestoreHealth06ME, 0.0, 0, 12, 0.0, EmptyList)
    AddMagicEffectToPotion(RestoreStamina01, RestoreStamina01ME, 0.0, 0, 12, 0.0, EmptyList)
    AddMagicEffectToPotion(RestoreStamina02, RestoreStamina02ME, 0.0, 0, 12, 0.0, EmptyList)
    AddMagicEffectToPotion(RestoreStamina03, RestoreStamina03ME, 0.0, 0, 12, 0.0, EmptyList)
    AddMagicEffectToPotion(RestoreStamina04, RestoreStamina04ME, 0.0, 0, 12, 0.0, EmptyList)
    AddMagicEffectToPotion(RestoreStamina05, RestoreStamina05ME, 0.0, 0, 12, 0.0, EmptyList)
    AddMagicEffectToPotion(RestoreStamina06, RestoreStamina06ME, 0.0, 0, 12, 0.0, EmptyList)
    AddMagicEffectToPotion(RestoreMagicka01, RestoreMagicka01ME, 0.0, 0, 12, 0.0, EmptyList)
    AddMagicEffectToPotion(RestoreMagicka02, RestoreMagicka02ME, 0.0, 0, 12, 0.0, EmptyList)
    AddMagicEffectToPotion(RestoreMagicka03, RestoreMagicka03ME, 0.0, 0, 12, 0.0, EmptyList)
    AddMagicEffectToPotion(RestoreMagicka04, RestoreMagicka04ME, 0.0, 0, 12, 0.0, EmptyList)
    AddMagicEffectToPotion(RestoreMagicka05, RestoreMagicka05ME, 0.0, 0, 12, 0.0, EmptyList)
    AddMagicEffectToPotion(RestoreMagicka06, RestoreMagicka06ME, 0.0, 0, 12, 0.0, EmptyList)
    AddMagicEffectToPotion(Invisibility01, Invisibility01ME, 0.0, 0, 12, 0.0, EmptyList)
    AddMagicEffectToPotion(Invisibility02, Invisibility02ME, 0.0, 0, 12, 0.0, EmptyList)
    AddMagicEffectToPotion(Invisibility03, Invisibility03ME, 0.0, 0, 12, 0.0, EmptyList)
    AddMagicEffectToPotion(Invisibility04, Invisibility04ME, 0.0, 0, 12, 0.0, EmptyList)
    Debug.Notification("NPC potion animations active")
endFunction

Function ClearPopulatedPotions()
    Debug.Notification("Clearing NPC poisons please wait...")
    RemoveMagicEffectFromPotion(RestoreHealth01, RestoreHealth01ME, 0.0, 0, 12, 0.0)
    RemoveMagicEffectFromPotion(RestoreHealth02, RestoreHealth02ME, 0.0, 0, 12, 0.0)
    RemoveMagicEffectFromPotion(RestoreHealth03, RestoreHealth03ME, 0.0, 0, 12, 0.0)
    RemoveMagicEffectFromPotion(RestoreHealth04, RestoreHealth04ME, 0.0, 0, 12, 0.0)
    RemoveMagicEffectFromPotion(RestoreHealth05, RestoreHealth05ME, 0.0, 0, 12, 0.0)
    RemoveMagicEffectFromPotion(RestoreHealth06, RestoreHealth06ME, 0.0, 0, 12, 0.0)
    RemoveMagicEffectFromPotion(RestoreStamina01, RestoreStamina01ME, 0.0, 0, 12, 0.0)
    RemoveMagicEffectFromPotion(RestoreStamina02, RestoreStamina02ME, 0.0, 0, 12, 0.0)
    RemoveMagicEffectFromPotion(RestoreStamina03, RestoreStamina03ME, 0.0, 0, 12, 0.0)
    RemoveMagicEffectFromPotion(RestoreStamina04, RestoreStamina04ME, 0.0, 0, 12, 0.0)
    RemoveMagicEffectFromPotion(RestoreStamina05, RestoreStamina05ME, 0.0, 0, 12, 0.0)
    RemoveMagicEffectFromPotion(RestoreStamina06, RestoreStamina06ME, 0.0, 0, 12, 0.0)
    RemoveMagicEffectFromPotion(RestoreMagicka01, RestoreMagicka01ME, 0.0, 0, 12, 0.0)
    RemoveMagicEffectFromPotion(RestoreMagicka02, RestoreMagicka02ME, 0.0, 0, 12, 0.0)
    RemoveMagicEffectFromPotion(RestoreMagicka03, RestoreMagicka03ME, 0.0, 0, 12, 0.0)
    RemoveMagicEffectFromPotion(RestoreMagicka04, RestoreMagicka04ME, 0.0, 0, 12, 0.0)
    RemoveMagicEffectFromPotion(RestoreMagicka05, RestoreMagicka05ME, 0.0, 0, 12, 0.0)
    RemoveMagicEffectFromPotion(RestoreMagicka06, RestoreMagicka06ME, 0.0, 0, 12, 0.0)
    RemoveMagicEffectFromPotion(Invisibility01, Invisibility01ME, 0.0, 0, 12, 0.0)
    RemoveMagicEffectFromPotion(Invisibility02, Invisibility02ME, 0.0, 0, 12, 0.0)
    RemoveMagicEffectFromPotion(Invisibility03, Invisibility03ME, 0.0, 0, 12, 0.0)
    RemoveMagicEffectFromPotion(Invisibility04, Invisibility04ME, 0.0, 0, 12, 0.0)
    Debug.Notification("NPC potion animations disabled")
endFunction