Scriptname AR_Ref_AliasScript extends ReferenceAlias  

AR_QuestScript Property AR_Quest Auto
Actor Property PlayerRef Auto
Idle Property IdleStop_Loose Auto
Idle Property idlebook_reading Auto
Idle Property IdleBookSitting_Reading Auto
Idle Property idlenoteread Auto
Idle Property CombatIdleStretching Auto
Idle Property idlelaydownexit Auto
Idle Property coughing Auto
Idle Property idleblacksmithforgeexit Auto
idle property idleSearchBody  auto
Sound property AR_CoughSoundMarker Auto
Spell Property AR_ReduceStressSpell Auto

Furniture Property AR_FurnitureGreyBeard Auto
Furniture Property AR_FurnitureSit Auto
Furniture Property AR_FurnitureLay Auto

keyword property vendoritemingredient auto
keyword property ClothingHead auto
keyword property ClothingFeet auto
keyword property ClothingHands auto
keyword property ClothingBody auto
keyword property Armorcuirass auto
keyword property Armorboots auto
keyword property ArmorGauntlets auto
keyword property ArmorHelmet auto
keyword property ClothingRing auto
keyword property ArmorJewelry auto

FormList Property AR_ElderScrolls Auto
Keyword Property VendorItemSpellTome Auto
GlobalVariable Property AR_Books Auto
GlobalVariable Property AR_SkyrimSouls Auto

int previousStat 
float currenttimescale
ObjectReference orSitRef

keyword property vendoritempoison auto
GlobalVariable Property AR_DogUp Auto
GlobalVariable Property AR_Poison Auto
GlobalVariable Property AR_Wait Auto
GlobalVariable Property AR_Timescale Auto
GlobalVariable Property Timescale Auto
GlobalVariable Property AR_Coughing Auto
GlobalVariable Property AR_StandUpKey Auto
GlobalVariable Property AR_SavedSitting Auto
GlobalVariable Property AR_EquipArmors Auto

Form Property AnimObjectPoisonBottle Auto
Form Property AnimObjectPoisonArrow Auto
Form Property AnimObjectIngredient Auto

Bool Random 
bool returntofirstperson

Event OnInIt()
RegisterForControl("Wait")
EndEvent

Event OnPlayerLoadGame()
	AR_Quest.LootingMaint()
	previousStat = Game.QueryStat("Poisons Used")
	
	If AR_Wait.GetValue() == 0
	;nothing

	else

		If AR_SavedSitting.GetValue() == 1
		Game.EnablePlayerControls()
		AR_SavedSitting.SetValue(0) 	
		endif

		If AR_Timescale.GetValue() == 1 && TimeScale.GetValue() == 2000
		Timescale.SetValue(CurrentTimescale)
		endif
endif
EndEvent

Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)

	if akBaseObject.HasKeyword(VendorItemIngredient) && PlayerRef.GetSitState() == 0 && AR_Coughing.GetValue() == 1 && !PlayerRef.IsWeaponDrawn() 
		Utility.Wait(0.2)
		If PlayerRef.GetAnimationVariableBool("bIsInMT")
			Int chance = utility.RandomInt(1,3)
			
			AR_DogUp.SetValue(7)
			Debug.SendanimationEvent(PlayerRef, "AO_IdleTake")
			utility.wait(0.1)
			AR_DogUp.SetValue(0)	
			utility.wait(1.7)
			Debug.SendAnimationEvent(PlayerRef, "OffsetStop")

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;HERE;;;;;;;;;;;;;;;;;;;;;;;;;;

			If chance == 3
				PlayerRef.PlayIdle(Coughing)
				int instanceID = AR_CoughSoundMarker.play(PlayerRef)     
				Sound.SetInstanceVolume(instanceID, 0.8)
			endif
		EndIf

	elseif akBaseObject as Book && AR_Books.GetValue() == 1 && AR_SkyrimSouls.GetValue() == 1

		If !akBaseObject.HasKeyword(VendorItemSpellTome) && PlayerRef.GetSitState() == 0 && akBaseObject.GetGoldValue() == 0 && !AR_ElderScrolls.HasForm(akBaseObject)
		;Utility.Wait(0.2)
		;Game.ForceThirdPerson()
		;		Debug.SendanimationEvent(PlayerRef, "AO_NoteStart")
		;utility.wait(0.2)
		;While Utility.IsInMenuMode() == True
		;utility.WaitMenuMode(0.5)
		;endwhile
		;Debug.SendanimationEvent(PlayerRef, "AO_NoteExit")

		Utility.Wait(0.2)
		Game.ForceThirdPerson()
		PlayerRef.PlayIdle(idlebook_reading)
		utility.wait(0.2)
		While Utility.IsInMenuMode() == True
		utility.WaitMenuMode(0.5)
		endwhile
		PlayerRef.PlayIdle(IdleStop_Loose)

		elseif !akBaseObject.HasKeyword(VendorItemSpellTome) && PlayerRef.GetSitState() == 0  && !AR_ElderScrolls.HasForm(akBaseObject)
			Utility.Wait(0.2)
			Game.ForceThirdPerson()
			AR_ReduceStressSpell.Cast(playerref, playerref)
			PlayerRef.PlayIdle(idlebook_reading)
			utility.wait(0.2)
			While Utility.IsInMenuMode() == True
			utility.WaitMenuMode(0.5)
			endwhile
			PlayerRef.PlayIdle(IdleStop_Loose)

		elseif !akBaseObject.HasKeyword(VendorItemSpellTome) && PlayerRef.GetSitState() == 3  && !AR_ElderScrolls.HasForm(akBaseObject)
			Utility.Wait(0.2)
			Game.ForceThirdPerson()
			AR_ReduceStressSpell.Cast(playerref, playerref)
			PlayerRef.PlayIdle(IdleBookSitting_Reading)
			utility.wait(0.2)
			While Utility.IsInMenuMode() == True
			utility.WaitMenuMode(0.5)
			endwhile
			PlayerRef.PlayIdle(IdleStop_Loose)

		endif
	endif
EndEvent

Event OnItemRemoved(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer) 
if akBaseItem.HasKeyword(VendorItemPoison) && AR_Poison.GetValue() == 1
AR_DogUp.SetValue(6)
int stat = Game.QueryStat("Poisons Used") 
if (stat > previousStat) ; the poison was actually used

previousStat = stat
if PlayerRef.IsWeaponDrawn()
Utility.Wait(0.2)
Playerref.PlayIdle(CombatIdleStretching)
endif
endif
Utility.Wait(0.8)
AR_DogUp.SetValue(0)
endif
EndEvent

Event OnControlDown(string control)
	If control == "Wait" && UI.IsMenuOpen("Sleep/Wait Menu") && !PlayerRef.IsWeaponDrawn() && PlayerRef.GetSitState() == 0 && PlayerRef.GetSleepState() == 0 && !AR_Wait.GetValue() == 0

		If AR_Wait.GetValue() == 4
			AR_Wait.SetValue(Utility.RandomInt(1,3))
			Random = True
		EndIf

		If AR_Wait.GetValue() == 1
			orSitRef = PlayerRef.PlaceAtMe(AR_FurnitureSit)
		ElseIf AR_Wait.GetValue() == 2
			orSitRef = PlayerRef.PlaceAtMe(AR_FurnitureGreyBeard)
		ElseIf AR_Wait.GetValue() == 3
			orSitRef = PlayerRef.PlaceAtMe(AR_FurnitureLay)
		EndIf

If Game.GetCameraState() == 0
returntofirstperson = true
else
returntofirstperson = false
endif


		Utility.Wait(0.1)
Game.ForceThirdPerson()		
		orSitRef.Activate(PlayerRef)
		Utility.Wait(1.5)
		CurrentTimeScale = Timescale.GetValue()

AR_SavedSitting.SetValue(1) 
Game.DisablePlayerControls(abMovement = false, abFighting = false, abCamSwitch = true, abMenu = false, abActivate = false, abJournalTabs = false, aiDisablePOVType = 0)
				
		If Random == True
			AR_Wait.SetValue(4)
			Random = False
		EndIf

		If AR_Timescale.GetValue() == 1
			Timescale.SetValue(2000.0)
		EndIf
				
		GoToState("Waiting")
	
		EndIf
		
		Utility.Wait(0.5)
EndEvent


State Waiting
	Event OnGetUp(ObjectReference akFurniture)
		StandUp()
		GoToState("")
	EndEvent
EndState


Function StandUp() 

AR_SavedSitting.SetValue(0)
Game.EnablePlayerControls()

	If AR_Timescale.GetValue() == 1
		Timescale.SetValue(CurrentTimeScale)

			If Timescale.GetValue() > 1999
				Timescale.SetValue(20)
			EndIf
	EndIf

If returntofirstperson == true
Game.ForceFirstPerson()
endif

Utility.wait(2)

orSitRef.Disable()
orSitRef.Delete()

EndFunction