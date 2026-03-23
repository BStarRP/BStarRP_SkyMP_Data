Scriptname AR_QuestScript extends Quest  

Perk Property AO_AnimPerk Auto

Formlist property AO_FormList Auto
Formlist property AO_FormShrines Auto
Formlist property Interact_FirewoodMedium Auto
Formlist property Interact_FirewoodSmall Auto
Formlist property Interact_FirewoodLarge Auto
Formlist property Interact_FirewoodHuge Auto
Formlist property Interact_MeadKeg Auto
Formlist property AR_Interact_Dummys Auto
Formlist property Interact_LightedFire Auto
Formlist property Interact_AlreadyUsed Auto
Formlist property Interact_SupportedItems Auto
Formlist property Interact_Hay Auto
Formlist property Interact_FloorStuff Auto
Formlist property Interact_Bars Auto
Formlist property Interact_Chains Auto
Formlist property Interact_Levers Auto
Formlist property Interact_Buttons Auto
Formlist property Interact_Pillars Auto
Formlist property Interact_Puzzle Auto
Formlist property Interact_Claw Auto
Formlist property AR_Interact_PuzzleSM Auto
Formlist property AR_Interact_PuzzleLarge Auto
Formlist property AR_Interact_Barrels Auto
formlist property AR_Interact_MissiveBoard auto
formlist property AR_SmallDogs Auto
formlist property AR_Interact_CustomContainers Auto

idle property idlepickup_ground auto
idle property idledoglay auto
idle property dogbarktalk auto
idle property IdleBowHeadAtGrave_02 auto
idle property IdleBowHeadAtGrave_01 auto
idle property idlepointclose auto
idle property idlechildapologize auto
idle property idlegreybeardwordteach auto
idle property idlechildtaunt3 auto
idle property idlegreybeardmeditateexit auto
idle property idleSearchingChest auto
idle property pa_huga auto
Idle Property IdleStop_Loose Auto
Idle Property idlesearchbody Auto
Idle Property idleSearchingTable Auto
Idle Property idlewave Auto
Idle Property idlesalute Auto
Idle Property idletake Auto
Idle Property dogbarklaytalk Auto
idle property idlesnaptoattention auto
idle property IdleLockPick Auto
idle property idlewoodpickupenter Auto
idle property idlestudy auto
idle property IdleSearchChestExit auto
Potion Property AR_Energized Auto
Potion Property FoodMead Auto
Potion Property BYOHFoodMilk Auto

Spell Property AR_ReduceStressSpell Auto

Sound Property ITMGenericUp Auto
Sound Property AR_KissSoundMarker auto
sound property TRPPressurePlateMetalSD auto
sound property AR_Moo auto
Actor PlayerREF
Race property Horse Auto
MiscObject Property Firewood01 Auto
MiscObject property BYOHMaterialStraw Auto
static property MeadBarrel01 auto
race property racecow auto

bool busy
bool busySpecial
bool returntofirstperson
form Knocking
form HB_TokenA
form HB_TokenB
form HB_TokenC
Bool bContainerOpen
bool bisDoingFavor
bool KnockKnock

GlobalVariable Property AR_SlowAlchemy Auto
GlobalVariable Property AR_SkyrimSouls Auto
GlobalVariable Property AR_ThirdPerson Auto
GlobalVariable Property AR_DogUp Auto
GlobalVariable Property CWPlayerAllegiance Auto
GlobalVariable Property AR_HugSpouse Auto
GlobalVariable Property AR_HugFollower Auto
GlobalVariable Property AR_deadfriends Auto
GlobalVariable Property AR_PickUpBooks Auto
GlobalVariable Property AR_PutOutFire Auto
GlobalVariable Property AR_Dummys Auto
GlobalVariable Property AR_NoFirstPerson Auto
GlobalVariable Property AR_DisplayMessages Auto
GlobalVariable Property AR_Firewood Auto
GlobalVariable Property AR_Kegs Auto
GlobalVariable Property AR_PickUpAngles Auto
GlobalVariable Property AR_SlowChest Auto
GlobalVariable Property AR_ReturnTo1st Auto
GlobalVariable Property AR_welltimed Auto
Actor Property PlayerRef Auto

import Debug
;import Quickloot 


Event Oninit()
	LootingMaint()
EndEvent

Event OnPlayerLoadGame()
    LootingMaint()
EndEvent

Function LootingMaint()
	RegisterForControl("Activate")
	PlayerREF = Game.getPlayer()
	PlayerREF.AddPerk(AO_AnimPerk)
	
If Game.GetModByName("HunterBorn.esp") != 255 && Game.GetModByName("SimpleHunterborn.esp") != 255
; nothing, this is to make it compatible with DrMonops mod
Elseif Game.GetModByName("HunterBorn.esp") != 255

	bool HunterbornInstalled = Game.GetFormFromFile(0x0501b483, "HunterBorn.esp")
		If HunterbornInstalled
			HB_TokenA = Game.GetFormFromFile(0x0501b483, "HunterBorn.esp") as MiscObject
			HB_TokenB = Game.GetFormFromFile(0x0500fb59, "HunterBorn.esp") as MiscObject
			HB_TokenC = Game.GetFormFromFile(0x05027763, "HunterBorn.esp") as MiscObject
		EndIf
		Endif
EndFunction

Function ftake(Actor akActor, ObjectReference akTargetRef)

If akTargetRef.GetActorOwner() == !None && akTargetRef.GetActorOwner() == !PlayerRef || akTargetRef.GetParentCell().GetActorOwner() == !None && akTargetRef.GetParentCell().GetActorOwner() == !PlayerRef

Endif

	If busy == False 
		if bisDoingFavor == False
			busy = true
						bool notfirst =  !Game.GetCameraState() == 0 
						bool angles = AR_PickUpAngles.GetValue() == 1
						bool welltimed = AR_WellTimed.GetValue() == 1

						if angles == True && notfirst == True
						float playerobjectposition = (akTargetRef.GetPositionZ() -  playerRef.GetPositionZ()) / 100						

						If PlayerRef.IsSneaking() == False && playerobjectposition < 0.35
						AR_DogUp.SetValue(6)	
						PlayerREF.PlayIdle(idlepickup_ground)
						utility.wait(0.1)
						AR_DogUp.SetValue(0)	
						busy = False
							
								If welltimed == 1
								utility.wait(0.4)

										Book maybebook 
										maybebook = akTargetRef.GetBaseObject() as Book

										If Game.GetFormFromFile(0x0080C, "AlwaysPickUpBooks.esp") && maybebook as Book
											else

								akTargetRef.Activate(akActor)
								utility.wait(0.7)
								endif
								endif

						elseif playerobjectposition  > 1.2 
						AR_DogUp.SetValue(6)	
						Debug.SendanimationEvent(akActor, "AO_IdleTake")
						utility.wait(0.1)
						AR_DogUp.SetValue(0)	
						busy = False


								If welltimed == 1
								utility.wait(0.7)

										Book maybebook 
										maybebook = akTargetRef.GetBaseObject() as Book

										If Game.GetFormFromFile(0x0080C, "AlwaysPickUpBooks.esp") && maybebook as Book
											else

								akTargetRef.Activate(akActor)
								utility.wait(0.7)
										endif
								
								else
 								utility.wait(1.5)
								endif
								Debug.SendAnimationEvent(akActor, "OffsetStop")
						else
							Debug.SendanimationEvent(akActor, "AO_IdleTake")
			

								If welltimed == 1
								utility.wait(0.6)

										Book maybebook 
										maybebook = akTargetRef.GetBaseObject() as Book

										If Game.GetFormFromFile(0x0080C, "AlwaysPickUpBooks.esp") && maybebook as Book
											else

								akTargetRef.Activate(akActor)
								utility.wait(0.5)
								endif
							else
							utility.wait(0.8)
							endif
							Debug.SendAnimationEvent(akActor, "OffsetStop")
							busy = False
						endif
	else
			Debug.SendanimationEvent(akActor, "AO_IdleTake")
			
				If welltimed == 1
				utility.wait(0.6)

				Book maybebook 
				maybebook = akTargetRef.GetBaseObject() as Book
	
										If Game.GetFormFromFile(0x0080C, "AlwaysPickUpBooks.esp") && maybebook as Book
				else

				akTargetRef.Activate(akActor)
				
				endif
				utility.wait(0.8)
			endif
			utility.wait(0.8)
			Debug.SendAnimationEvent(akActor, "OffsetStop")
			busy = False
	endif
endif
endif
EndFunction


Function fOpen(Actor akActor, ObjectReference akTargetRef)

If AR_NoFirstPerson.GetValue() == 1 && Game.GetCameraState() == 0 && bisDoingFavor == False
;Player is in first person and first person activations are disabled, they activate object immediately like in vanilla. No animation.
If Utility.IsInMenuMode() == False
akTargetRef.Activate(akActor)
endif


elseif busy == False && bisDoingFavor == False
			busy = true

If akTargetRef.IsLocked() 
		If Utility.IsInMenuMode() == True
			;nothing, player has encountered a menu from another mod.
							utility.wait(3)
							busy = False
		else

					IsPlayerIn3rd()

If  akActor.GetItemCount(akTargetRef.GetKey())
					AR_DogUp.SetValue(1)
					PlayerRef.PlayIdle(IdleLockPick)
					utility.wait(1.5)

elseif playerRef.IsSneaking()	
	Debug.SendanimationEvent(akActor, "AO_IdleLockPick")
	utility.wait(2.2)
else
					PlayerRef.PlayIdle(IdleLockPick)
					utility.wait(2.2)
endif
					akTargetRef.Activate(akActor) 

If AR_SkyrimSouls.GetValue() == 1 &&  akActor.GetItemCount(akTargetRef.GetKey()) == false
					AR_DogUp.SetValue(6)
					Utility.Wait(0.1)

If playerRef.IsSneaking()					
Debug.SendAnimationEvent(akActor, "idlesilentbow")
else
Debug.SendAnimationEvent(akActor, "idlesearchchestenter")
endif

	While Utility.IsInMenuMode() == True
	Endwhile

	If playerRef.IsSneaking()					
				PlayerRef.PlayIdle(idlestop_loose)
	else
				PlayerRef.PlayIdle(IdleSearchChestExit) 
				Utility.Wait(0.5)
				Debug.SendanimationEvent(PlayerRef, "IdleForceDefaultState")
	endif
			

else
					utility.wait(1.6)

					If playerRef.IsSneaking()					
					Debug.SendAnimationEvent(akActor, "OffsetStop")
					else
					Debug.SendanimationEvent(PlayerRef, "IdleForceDefaultState")
					endif
endif
					AR_DogUp.SetValue(0)
					utility.wait(0.5)
					Returnto1st()

					busy = False
		endif

 
Elseif akTargetRef.GetBaseObject() as Container	&& AR_SlowChest.GetValue() == 1 || AR_Interact_CustomContainers.HasForm(akTargetRef.GetBaseObject())
				IsPlayerIn3rd()
				Utility.Wait(0.1)
float playerobjectposition = (akTargetRef.GetPositionZ() -  playerRef.GetPositionZ()) / 100

If playerref.issneaking()
	if playerobjectposition > 0.45 || AR_Interact_Barrels.HasForm(akTargetRef.GetBaseObject())
		AR_DogUp.SetValue(4)
	elseif playerobjectposition < 0.25
		AR_DogUp.SetValue(3)
	endif
Utility.Wait(0.1)
Playerref.PlayIdle(idleSearchingChest)

elseif playerobjectposition > 0.40 || AR_Interact_Barrels.HasForm(akTargetRef.GetBaseObject())
	AR_DogUp.SetValue(3)
	Playerref.PlayIdle(idleSearchingTable)
else
AR_DogUp.SetValue(3)
PlayerRef.PlayIdle(idleSearchBody)
endif
			utility.wait(0.5)
			akTargetRef.Activate(akActor)
			utility.wait(0.8)
		If AR_SkyrimSouls.GetValue() == 1
utility.wait(0.5)
			If Utility.IsInMenuMode() == True
;Is the player still in the menu?
			endif
			While Utility.IsInMenuMode() == True
;inmenu
				endwhile
			else
		utility.wait(0.7)
		endif
AR_DogUp.SetValue(0)
PlayerRef.PlayIdle(IdleStop_Loose)
				busy = False
				Returnto1st()
else

				Debug.SendanimationEvent(akActor, "AO_OpenDoor") 
					utility.wait(0.4)
					akTargetRef.Activate(akActor)
					Debug.SendAnimationEvent(akActor, "OffsetStop")
					utility.wait(0.2)
					busy = False
				EndIf	
Else
			akTargetRef.Activate(akActor)
Endif	
EndFunction



Function fpuzzle(Actor akActor, ObjectReference akTargetRef)
ObjectReference TempRef = akTargetRef

If AR_NoFirstPerson.GetValue() == 1 && Game.GetCameraState() == 0 && bisDoingFavor == False
;Player is in first person and first person activations are disabled, they activate object immediately like in vanilla. No animation.
akTargetRef.Activate(akActor)

elseif busy == False && bisDoingFavor == False
		busy = true

If AR_NoFirstPerson.GetValue() == 1 && Game.GetCameraState() == 0
akTargetRef.Activate(akActor)
else

			If Interact_FloorStuff.HasForm(akTargetRef.GetBaseObject())
	
				IsPlayerIn3rd()
				PlayerREF.PlayIdle(idlepickup_ground)
				Utility.Wait(0.8)
				akTargetRef.Activate(akActor)
				Utility.Wait(1.5)
				Returnto1st()
				busy = False

			elseif Interact_Bars.HasForm(akTargetRef.GetBaseObject())

				if Interact_AlreadyUsed.HasForm(akTargetRef)
				akTargetRef.Activate(akActor)
				busy = False
				Interact_AlreadyUsed.RemoveAddedForm(akTargetRef)

				else

				IsPlayerIn3rd()
				AR_DogUp.SetValue(6)
				Utility.Wait(0.1)
				PlayerREF.PlayIdle(idlegreybeardwordteach)
				Utility.Wait(0.95)
				akTargetRef.Activate(akActor)
				Interact_AlreadyUsed.AddForm(akTargetRef)
				Utility.Wait(1.5)
				Returnto1st()
				AR_DogUp.SetValue(0)
				busy = False
				endif

			elseif Interact_Chains.HasForm(akTargetRef.GetBaseObject())

			IsPlayerIn3rd()
			AR_DogUp.SetValue(6)
			Utility.Wait(0.1)
	
			PlayerRef.PlayIdle(IdleLockPick)
						Utility.Wait(0.6)
				akTargetRef.Activate(akActor)
			Utility.Wait(1)
				AR_DogUp.SetValue(0)
				Returnto1st()
				busy = False

			elseif Interact_Levers.HasForm(akTargetRef.GetBaseObject())

				IsPlayerIn3rd()
				akTargetRef.Activate(akActor, true)
				Utility.Wait(2.0)
				akTargetRef.Activate(akActor)
				busy = False
				Utility.Wait(2)
				Returnto1st()

			elseif Interact_Buttons.HasForm(akTargetRef.GetBaseObject())

				IsPlayerIn3rd()
				AR_DogUp.SetValue(4)
				Utility.Wait(0.1)
				PlayerREF.PlayIdle(idlewave)
				Utility.Wait(1.1)
				akTargetRef.Activate(akActor)
				int instanceID = TRPPressurePlateMetalSD.play(PlayerRef)     
				Sound.SetInstanceVolume(instanceID, 0.9)
				Utility.Wait(1)
				AR_DogUp.SetValue(0)
				Returnto1st()
				busy = False

			elseif Interact_Pillars.HasForm(akTargetRef.GetBaseObject())

			IsPlayerIn3rd()
			AR_DogUp.SetValue(5)
			Utility.Wait(0.1)
			PlayerREF.PlayIdle(idlewave)
				Utility.Wait(1)
				akTargetRef.Activate(akActor)
				Utility.Wait(1.5)
				Returnto1st()
				AR_DogUp.SetValue(0)
				busy = False

			elseif Interact_Puzzle.HasForm(akTargetRef.GetBaseObject())

				IsPlayerIn3rd()
				AR_DogUp.SetValue(4)
				Utility.Wait(0.1)
				PlayerREF.PlayIdle(idlegreybeardwordteach)
				Utility.Wait(0.35)
				akTargetRef.Activate(akActor)
				Utility.Wait(2.2)
				Returnto1st()
				AR_DogUp.SetValue(0)
				busy = False

			elseif AR_Interact_PuzzleSM.HasForm(akTargetRef.GetBaseObject())

				IsPlayerIn3rd()
				AR_DogUp.SetValue(4)
				Utility.Wait(0.1)
				PlayerREF.PlayIdle(idlepickup_ground)
				Utility.Wait(0.35)
				akTargetRef.Activate(akActor)
				Utility.Wait(2.2)
				Returnto1st()
				AR_DogUp.SetValue(0)
				busy = False

			elseif AR_Interact_PuzzleLarge.HasForm(akTargetRef.GetBaseObject())
				IsPlayerIn3rd()
				AR_DogUp.SetValue(5)
				Utility.Wait(0.1)
				PlayerREF.PlayIdle(idlegreybeardwordteach)
				Utility.Wait(0.35)
				akTargetRef.Activate(akActor)
				Utility.Wait(2.2)
				Returnto1st()
				AR_DogUp.SetValue(0)
				busy = False

			elseif Interact_Claw.HasForm(akTargetRef.GetBaseObject())

				IsPlayerIn3rd()

		  If Game.GetFormFromFile(0x00000805, "Dragon Claws Auto-Unlock.esp") && (Game.GetFormFromFile(0x00000806, "Dragon Claws Auto-Unlock.esp") as GlobalVariable).GetValue() != 3
                    AR_DogUp.SetValue(5)
                    PlayerREF.PlayIdle(idletake)
                    Utility.Wait(1.3)
                    akTargetRef.Activate(akActor)
                    

                else
                    PlayerREF.PlayIdle(idlegreybeardwordteach)
                    Utility.Wait(0.4)
                    akTargetRef.Activate(akActor)
                endif

				Utility.Wait(2.2)
				AR_DogUp.SetValue(0)
				busy = False
				Returnto1st()

		Else
			akTargetRef.Activate(akActor)
endif
endif
endif
endfunction



Function fHarvest(Actor akActor, ObjectReference akTargetRef)
ObjectReference TempRef = akTargetRef

If AR_NoFirstPerson.GetValue() == 1 && Game.GetCameraState() == 0 && bisDoingFavor == False
;Player is in first person and first person activations are disabled, they activate object immediately like in vanilla. No animation.
akTargetRef.Activate(akActor)

	elseif busy == False && bisDoingFavor == False
			busy = true

			If AO_FormList.HasForm(akTargetRef.GetBaseObject())
				Debug.SendanimationEvent(akActor, "AO_IdleTake")
				utility.wait(0.7)
				akTargetRef.Activate(akActor)
				Debug.SendAnimationEvent(akActor, "OffsetStop")
				busy = False
		
else

If AR_SlowAlchemy.GetValue() == 2
Debug.SendanimationEvent(akActor, "AO_IdleTake")
				utility.wait(0.7)
	Debug.SendAnimationEvent(akActor, "OffsetStop")

else

Float CurrentAlch = PlayerRef.GetActorValue("Alchemy")
Float AlchSpeed

If CurrentAlch < 15
AlchSpeed = 3.0
elseif CurrentAlch > 14 && CurrentAlch < 35
AlchSpeed = 2.5
elseif CurrentAlch > 34 && CurrentAlch < 50
AlchSpeed = 2.0
elseif CurrentAlch >49 && CurrentAlch < 65
AlchSpeed = 1.6
elseif CurrentAlch > 65 && CurrentAlch < 85
AlchSpeed = 1.3
elseif CurrentAlch > 84
AlchSpeed = 1.0
endif
		
			IsPlayerIn3rd()
			PlayerRef.PlayIdle(idleSearchBody)
			utility.wait(AlchSpeed)
endif
			akActor.AddItem(TempRef, 1, True)
			TempRef.Activate(akActor)

			If akActor.GetItemCount(TempRef.GetBaseObject()) !=1
				akActor.RemoveItem(TempRef, 1, True)
			EndIf
			PlayerRef.PlayIdle(IdleStop_Loose)

Returnto1st()

			utility.wait(0.2)
			busy = False
			Endif
		Else
			akTargetRef.Activate(akActor)
		EndIf
EndFunction


Function fSearch(Actor akActor, ObjectReference akTargetRef)
	If HB_TokenA
		Utility.wait(0.1)
		If akTargetRef.GetItemCount(HB_TokenA) >=1 || akTargetRef.GetItemCount(HB_TokenB) >=1 || akTargetRef.GetItemCount(HB_TokenC) >=1 
			Return
		endif

	Else
		Actor  Body = akTargetRef as Actor
		If Body.IsDead() == True

If AR_NoFirstPerson.GetValue() == 1 && Game.GetCameraState() == 0 && bisDoingFavor == False
;Player is in first person and first person activations are disabled, they activate object immediately like in vanilla. No animation.
akTargetRef.Activate(akActor)

			elseif busy == False
				If bisDoingFavor == False 
					busy = true

IsPlayerIn3rd()
					AR_DogUp.SetValue(7)
					utility.wait(0.1)
					Debug.SendanimationEvent(akActor, "AO_Tan") ; AO_CannibalC
					utility.wait(1.5)
					akTargetRef.Activate(akActor)
					While Utility.IsInMenuMode() == True
			;Debug.notification("InMenuMode")
					endwhile
					utility.wait(0.7)
			;Debug.notification("Playing exit animation")
			Debug.SendAnimationEvent(akActor, "idlesilentbow")
					Utility.Wait(0.6)
				AR_DogUp.SetValue(0)
			;Debug.notification("forcing exit")
			Debug.SendanimationEvent(PlayerRef, "IdleForceDefaultState")
					Returnto1st()
					busy = False
				Else
					akTargetRef.Activate(akActor)
				EndIf	
			EndIf
		Else
			akTargetRef.Activate(akActor)
		EndIf
	EndIf
EndFunction





Function fSearchNPC(Actor akActor, ObjectReference akTargetRef)

	Actor deadfriend = akTargetRef as Actor

If AR_NoFirstPerson.GetValue() == 1 && Game.GetCameraState() == 0 && bisDoingFavor == False
;Player is in first person and first person activations are disabled, they activate object immediately like in vanilla. No animation.
akTargetRef.Activate(akActor)
	
	elseif deadfriend.GetRelationshipRank(PlayerRef) > 1 && !Interact_AlreadyUsed.Hasform(deadfriend) && AR_deadfriends.GetValue() == 1

	IsPlayerIn3rd()
	PlayerRef.PlayIdle(IdleBowHeadAtGrave_01)
	Utility.Wait(3)
	PlayerRef.PlayIdle(IdleStop_Loose)
	Interact_AlreadyUsed.AddForm(deadfriend)
	Returnto1st()


	elseif busy == False && bisDoingFavor == False
			busy = true

IsPlayerIn3rd()



if PlayerRef.IsSneaking()
AR_DogUp.SetValue(3)
Utility.Wait(0.1)
Playerref.PlayIdle(idleSearchingChest)
Utility.Wait(0.1)
AR_DogUp.SetValue(0)
else
	PlayerRef.PlayIdle(idleSearchBody)
endif
			utility.wait(0.8)
			akTargetRef.Activate(akActor)
		If AR_SkyrimSouls.GetValue() == 1
			While Utility.IsInMenuMode() == True
			endwhile
		else
		utility.wait(0.4)
		endif
			PlayerRef.PlayIdle(IdleStop_Loose)

Returnto1st()

			busy = False
		Else
			akTargetRef.Activate(akActor)
		EndIf
EndFunction





Function fPray(Actor akActor, ObjectReference akTargetRef)

If AR_NoFirstPerson.GetValue() == 1 && Game.GetCameraState() == 0 && bisDoingFavor == False
;Player is in first person and first person activations are disabled, they activate object immediately like in vanilla. No animation.
akTargetRef.Activate(akActor)

elseif busy == False && bisDoingFavor == False
			busy = true
			ObjectReference TempRef = akTargetRef

IsPlayerIn3rd()

			Debug.SendAnimationEvent(akActor, "IdleGreybeardMeditateEnter")
			utility.wait(5.0)
			TempRef.Activate(akActor)
			utility.wait(0.4)
			playerref.playidle(idlegreybeardmeditateexit)
			busy = False
			utility.wait(2)
			Returnto1st()

		Else
			akTargetRef.Activate(akActor)
		EndIf
EndFunction






Function fwavehorse(Actor akActor, ObjectReference akTargetRef)

If AR_NoFirstPerson.GetValue() == 1 && Game.GetCameraState() == 0 && bisDoingFavor == False
;Player is in first person and first person activations are disabled, they activate object immediately like in vanilla. No animation.
akTargetRef.Activate(akActor)

elseif busy == False && bisDoingFavor == False
		Actor horsey = akTargetRef as Actor
			busy = true
		AR_DogUp.SetValue(2)

			IsPlayerIn3rd()
																																					
If Interact_AlreadyUsed.HasForm(horsey)
Debug.Notification("This cow is out of milk!")
elseif horsey.getrace() == RaceCow
Playerref.PlayIdle(idleSearchingChest)
horsey.SetDontMove()
Utility.Wait(0.4)
int instanceID = AR_Moo.play(PlayerRef)     
Sound.SetInstanceVolume(instanceID, 0.8)
Interact_AlreadyUsed.AddForm(horsey)
Utility.Wait(2.2)
playerref.AddItem(BYOHFoodMilk, 2)
Utility.Wait(0.2)
PlayerRef.PlayIdle(IdleStop_Loose)
horsey.SetDontMove(false)

else
			PlayerRef.PlayIdle(idlewave)
			horsey.SetDontMove()
			utility.wait(2)
			horsey.SetDontMove(false)
endif
			Returnto1st()
			utility.wait(2)
			busy = False
		AR_DogUp.SetValue(0)

		Else
			akTargetRef.Activate(akActor)
	EndIf
EndFunction


Function fwavestone(Actor akActor, ObjectReference akTargetRef)

If AR_NoFirstPerson.GetValue() == 1 && Game.GetCameraState() == 0 && bisDoingFavor == False
;Player is in first person and first person activations are disabled, they activate object immediately like in vanilla. No animation.
akTargetRef.Activate(akActor)

elseif busy == False && bisDoingFavor == False

				If AR_Interact_MissiveBoard.HasForm(akTargetRef.GetBaseObject())
			IsPlayerIn3rd()
			busy = true
			PlayerRef.Playidle(idlestudy)
			utility.wait(0.5)
			akTargetRef.Activate(akActor)

		If AR_SkyrimSouls.GetValue() == 1
utility.wait(0.5)
			If Utility.IsInMenuMode() == True
;Is the player still in the menu?
			endif
			While Utility.IsInMenuMode() == True
;inmenu
				endwhile
			else
		utility.wait(1)
		endif
			PlayerRef.PlayIdle(IdleStop_Loose)
			Returnto1st()
			busy = false

				else
			IsPlayerIn3rd()
			busy = true
			AR_DogUp.SetValue(2)
			;Debug.SendanimationEvent(akActor, "idlewave")
			PlayerRef.PlayIdle(idlewave)
			utility.wait(2.5)
			akTargetRef.Activate(akActor)

			Returnto1st()
			utility.wait(5)
			busy = False
			AR_DogUp.SetValue(0)
				endif
		Else
			akTargetRef.Activate(akActor)
	EndIf
EndFunction


Function fpetdog(Actor akActor, ObjectReference akTargetRef)

If AR_NoFirstPerson.GetValue() == 1 && Game.GetCameraState() == 0 && bisDoingFavor == False
;Player is in first person and first person activations are disabled, they activate object immediately like in vanilla. No animation.
akTargetRef.Activate(akActor)

elseif busy == False && bisDoingFavor == False
			busy = true

	Actor Dog = akTargetRef as Actor

IsPlayerIn3rd()

	int UporDown = Utility.RandomInt(1,3)
	Dog.SetDontMove()	
	AR_ReduceStressSpell.Cast(playerref, playerref)
	
If AR_SmallDogs.HasForm(Dog.GetBaseObject())
UporDown = 2
endif

	If UporDown == 1 ;DOG UP!!
	AR_DogUp.SetValue(1)
	Dog.PlayIdle(dogbarktalk)
	utility.wait(0.3)
	PlayerRef.PlayIdle(idleSearchBody)
	utility.wait(2.5)
	PlayerRef.PlayIdle(IdleStop_Loose)

	elseif UporDown == 2 
	AR_DogUp.SetValue(2)
	Dog.PlayIdle(idledoglay)
	utility.wait(0.3)
	Dog.PlayIdle(dogbarklaytalk)
	PlayerRef.PlayIdle(idleSearchBody)
	utility.wait(2.5)
	PlayerRef.PlayIdle(IdleStop_Loose)
	
	elseif UporDown == 3
	AR_DogUp.SetValue(1)
	Dog.PlayIdle(dogbarktalk)
	utility.wait(0.3)
	PlayerRef.PlayIdle(idlegreybeardwordteach)
	utility.wait(2.5)
	endif
	Dog.SetDontMove(false)	
			utility.wait(0.5)

Returnto1st()
			busy = False
		Else
			akTargetRef.Activate(akActor)
	Endif
	AR_DogUp.SetValue(0)

EndFunction




Function fsaluteguard(Actor akActor, ObjectReference akTargetRef)

If AR_NoFirstPerson.GetValue() == 1 && Game.GetCameraState() == 0 && bisDoingFavor == False
;Player is in first person and first person activations are disabled, they activate object immediately like in vanilla. No animation.
akTargetRef.Activate(akActor)

elseif busy == False && bisDoingFavor == False && PlayerRef.IsSneaking() == False
			busy = true
			Actor Guard = akTargetRef as Actor
			Guard.SetLookAt(PlayerRef, true)
If !Game.GetCameraState() == 0 
			Game.DisablePlayerControls(false, false, true, false, false, false, false)
			Debug.SendanimationEvent(akActor, "idlesalute")
endif
			akTargetRef.Activate(akActor)
			utility.wait(0.5)
			Guard.PlayIdle(idlesnaptoattention)
			utility.wait(3)
			Guard.ClearLookAt()
			Game.EnablePlayerControls()
			utility.wait(5)
			busy = False
		Else
			akTargetRef.Activate(akActor)
	EndIf
EndFunction



Function fsalutechild(Actor akActor, ObjectReference akTargetRef)

If AR_NoFirstPerson.GetValue() == 1 && Game.GetCameraState() == 0 && bisDoingFavor == False
;Player is in first person and first person activations are disabled, they activate object immediately like in vanilla. No animation.
akTargetRef.Activate(akActor)

elseif busy == False && bisDoingFavor == False
			busy = true

			Actor Child = akTargetRef as Actor
			Child.SetLookAt(PlayerRef, true)
			AR_DogUp.SetValue(1)
			Utility.wait(0.1)
If !Game.GetCameraState() == 0 
			;Debug.SendanimationEvent(akActor, "idlewave")
			Game.DisablePlayerControls(false, false, true, false, false, false, false)
			PlayerRef.PlayIdle(idlewave)
endif
					Utility.wait(0.4)
				AR_DogUp.SetValue(0)
				akTargetRef.Activate(akActor)
int chance = Utility.RandomInt(1,5)
				if chance == 1
				Child.PlayIdle(idlewave)
				elseif chance == 2
				Child.PlayIdle(idlepointclose)
				elseif chance == 3
			Child.PlayIdle(idlechildapologize)
				elseif chance == 4
			Child.PlayIdle(idlechildtaunt3)
				elseif chance == 5
			Child.PlayIdle(IdleBowHeadAtGrave_02)
			Utility.Wait(2)
			Child.PlayIdle(IdleStop_Loose)
				endif


			Child.ClearLookAt()			
			utility.wait(1)
			Game.EnablePlayerControls()
			busy = False
		Else
			akTargetRef.Activate(akActor)
	Endif
EndFunction



Function fsalutecommander(Actor akActor, ObjectReference akTargetRef)

If AR_NoFirstPerson.GetValue() == 1 && Game.GetCameraState() == 0 && bisDoingFavor == False
;Player is in first person and first person activations are disabled, they activate object immediately like in vanilla. No animation.
akTargetRef.Activate(akActor)

elseif busy == False && bisDoingFavor == False

IsPlayerIn3rd()

			busy = true
	If CWPlayerAllegiance.GetValue() == 2
			Debug.SendanimationEvent(akActor, "idlesalute")
	else
			PlayerRef.PlayIdle(idlesnaptoattention)
	endif
			Actor Guard = akTargetRef as Actor
			utility.wait(0.4)
			Debug.SendanimationEvent(Guard, "idlesalute")
			akTargetRef.Activate(akActor)
			utility.wait(3)

Returnto1st()
			busy = False
		Else
			akTargetRef.Activate(akActor)
	Endif
EndFunction


Function fsalutejarl(Actor akActor, ObjectReference akTargetRef)

If AR_NoFirstPerson.GetValue() == 1 && Game.GetCameraState() == 0 && bisDoingFavor == False
;Player is in first person and first person activations are disabled, they activate object immediately like in vanilla. No animation.
akTargetRef.Activate(akActor)

elseif busy == False && bisDoingFavor == False

IsPlayerIn3rd()

		busy = true
			Debug.SendanimationEvent(akActor, "idlesalute")
			utility.wait(0.5)
			akTargetRef.Activate(akActor)
			utility.wait(3)

Returnto1st()
			busy = False
		Else
			akTargetRef.Activate(akActor)
	EndIf
EndFunction




Function fapplaud(Actor akActor, ObjectReference akTargetRef)

If AR_NoFirstPerson.GetValue() == 1 && Game.GetCameraState() == 0 && bisDoingFavor == False
;Player is in first person and first person activations are disabled, they activate object immediately like in vanilla. No animation.
akTargetRef.Activate(akActor)

elseif busy == False && bisDoingFavor == False

IsPlayerIn3rd()

			busy = true
			Debug.SendanimationEvent(akActor, "idleapplaud2")
			AR_ReduceStressSpell.Cast(playerref, playerref)
			utility.wait(2)
			busy = False

Returnto1st()

		Else
			akTargetRef.Activate(akActor)
	EndIf
EndFunction




Function ffollower(Actor akActor, ObjectReference akTargetRef)
	;This is currently used for pickpocketing, despite the name

If AR_NoFirstPerson.GetValue() == 1 && Game.GetCameraState() == 0 && bisDoingFavor == False
;Player is in first person and first person activations are disabled, they activate object immediately like in vanilla. No animation.
akTargetRef.Activate(akActor)


elseif busy == False && bisDoingFavor == False && PlayerRef.IsSneaking() == True
			IsPlayerIn3rd()
			busy = true
			Debug.SendanimationEvent(akActor, "AO_IdleLockPick")
			utility.wait(2.2)
			akTargetRef.Activate(akActor)
			utility.wait(0.2)
		Debug.SendAnimationEvent(akActor, "OffsetStop")

Returnto1st()
			utility.wait(0.2)
			busy = False
	else
			akTargetRef.Activate(akActor)
		EndIf

EndFunction



Function ffriend(Actor akActor, ObjectReference akTargetRef)
	;This is used for followers and spouses

If AR_NoFirstPerson.GetValue() == 1 && Game.GetCameraState() == 0 && bisDoingFavor == False
;Player is in first person and first person activations are disabled, they activate object immediately like in vanilla. No animation.
akTargetRef.Activate(akActor)
	Actor follower = akTargetRef as Actor
	while follower.IsInDialogueWithPlayer()
		;nothing happens, player talking.
		endwhile
utility.wait(1.5)
		while follower.IsDoingFavor()
		;favor ongoing. 
		bisDoingFavor = True
		endwhile
		bisDoingFavor = False

	elseif busySpecial == False && bisDoingFavor == False
		Actor friend = akTargetRef as Actor
			busySpecial = true
				Int chance = Utility.RandomInt(1,15)

if friend.GetRelationshipRank(PlayerRef) == 3 && AR_HugFollower.GetValue() == 1  && AR_HugSpouse.GetValue() == 1 

		If chance > 14

IsPlayerIn3rd()
	friend.SetExpressionOverride(2, 70)
	playerref.PlayIdleWithTarget(pa_huga, friend)
	utility.wait(5)
	AR_ReduceStressSpell.Cast(playerref, playerref)
	friend.ClearExpressionOverride()
Returnto1st()
utility.wait(5)
	busySpecial = False
		
		else
		Debug.SendanimationEvent(friend, "idlesalute")
		utility.wait(0.2)
		akTargetRef.Activate(akActor)
		utility.wait(1)
		Actor follower = akTargetRef as Actor
		while follower.IsInDialogueWithPlayer()
		;nothing happens, player talking. Notification below empty because otherwise it won't work.
		endwhile
utility.wait(1.5)
		while follower.IsDoingFavor()
		;favor ongoing. Notification below empty because otherwise it won't work.
		bisDoingFavor = True
		endwhile
		bisDoingFavor = False
		endif
	utility.wait(5)
	busySpecial = False

elseif friend.GetRelationshipRank(PlayerRef) == 4 && AR_HugSpouse.GetValue() == 1
If chance > 11

IsPlayerIn3rd()
friend.SetExpressionOverride(2, 70)
playerref.PlayIdleWithTarget(pa_huga, friend)
;	int instanceID = AR_KissSoundMarker.play(PlayerRef)     
;	Sound.SetInstanceVolume(instanceID, 0.7)
utility.wait(5)

Returnto1st()
friend.ClearExpressionOverride()
utility.wait(10)

else
		akTargetRef.Activate(akActor)
		Actor follower = akTargetRef as Actor
		while follower.IsInDialogueWithPlayer()
		endwhile
utility.wait(1.5)
		while follower.IsDoingFavor()
		bisDoingFavor = True
		endwhile
		bisDoingFavor = False

	utility.wait(10)
	busySpecial = False
Endif

Else
		akTargetRef.Activate(akActor)
		Actor follower = akTargetRef as Actor
		
		while follower.IsInDialogueWithPlayer()
		endwhile
		while follower.IsDoingFavor()
		bisDoingFavor = True
		endwhile
		bisDoingFavor = False
		busySpecial = False
Endif
	Else
		akTargetRef.Activate(akActor)
		Actor follower = akTargetRef as Actor
		
		while follower.IsInDialogueWithPlayer()
		endwhile
		while follower.IsDoingFavor()
		bisDoingFavor = True
		endwhile
		bisDoingFavor = False
		busySpecial = False
	EndIf
EndFunction



Event OnControlUp(string control, float HoldTime)
	If control == "Activate" && HoldTime > 0.5 && (Game.GetCurrentCrosshairRef() as Actor)
Actor tempActor = Game.GetCurrentCrosshairRef() as Actor
If TempActor.IsPlayerTeammate()
Utility.Wait(0.5)
If tempActor.IsDoingFavor()
bisDoingFavor = True
while tempActor.IsDoingFavor()
EndWhile
bisDoingFavor = False
tempActor = None
endif
endif
	elseif control == "Activate" && HoldTime > 1.0 && PlayerRef.IsWeaponDrawn() == 0 && Game.GetPlayerGrabbedRef() == none

ObjectReference StaticItem

StaticItem = Game.FindClosestReferenceOfAnyTypeInList(Interact_SupportedItems, PlayerRef.GetPositionX(), PlayerRef.GetPositionY(), PlayerRef.GetPositionZ(), 200.0)

If StaticItem == None

If AR_DisplayMessages.GetValue() == 1
Debug.Notification("No nearby items to interact with")
endif

elseif Interact_FirewoodSmall.HasForm(StaticItem.GetBaseObject()) && !Interact_AlreadyUsed.HasForm(StaticItem) && AR_Firewood.GetValue() == 1
Game.ForceThirdPerson()
Game.DisablePlayerControls(false, false, true, false, false, false, false)	
	Debug.SendanimationEvent(PlayerRef, "idlewoodpickupenter")						
		utility.wait(6)
		PlayerRef.additem(Firewood01, 2)
		utility.wait(0.5)
	Debug.SendanimationEvent(PlayerRef, "offsetstop")
Interact_AlreadyUsed.AddForm(StaticItem)
StaticItem.disable()
Game.EnablePlayerControls()
;	StaticItem.Delete()

Elseif Interact_FirewoodMedium.HasForm(StaticItem.GetBaseObject()) && !Interact_AlreadyUsed.HasForm(StaticItem) && AR_Firewood.GetValue() == 1
Game.ForceThirdPerson()
Game.DisablePlayerControls(false, false, true, false, false, false, false)	
	Debug.SendanimationEvent(PlayerRef, "idlewoodpickupenter")						
		utility.wait(6)
		PlayerRef.additem(Firewood01, 4)
		utility.wait(0.5)
	Debug.SendanimationEvent(PlayerRef, "offsetstop")
	Game.EnablePlayerControls()	
Interact_AlreadyUsed.AddForm(StaticItem)
	StaticItem.disable()
;	StaticItem.Delete()

Elseif Interact_FirewoodLarge.HasForm(StaticItem.GetBaseObject()) && !Interact_AlreadyUsed.HasForm(StaticItem) && AR_Firewood.GetValue() == 1
Game.ForceThirdPerson()
Game.DisablePlayerControls(false, false, true, false, false, false, false)
	Debug.SendanimationEvent(PlayerRef, "idlewoodpickupenter")						
		utility.wait(6)
		PlayerRef.additem(Firewood01, 8)
		utility.wait(0.5)
	Debug.SendanimationEvent(PlayerRef, "offsetstop")
	Game.EnablePlayerControls()	
Interact_AlreadyUsed.AddForm(StaticItem)
	StaticItem.disable()
;	StaticItem.Delete()

Elseif Interact_FirewoodHuge.HasForm(StaticItem.GetBaseObject()) && !Interact_AlreadyUsed.HasForm(StaticItem) && AR_Firewood.GetValue() == 1

Game.ForceThirdPerson()
Game.DisablePlayerControls(false, false, true, false, false, false, false)

	Debug.SendanimationEvent(PlayerRef, "idlewoodpickupenter")						
		utility.wait(6)
		PlayerRef.additem(Firewood01, 6)
		utility.wait(0.5)
		Debug.SendanimationEvent(PlayerRef, "offsetstop")
		Game.EnablePlayerControls()						
;huge piles are infinite!



Elseif Interact_MeadKeg.HasForm(StaticItem.GetBaseObject()) && AR_Kegs.GetValue() == 1

	if  Interact_AlreadyUsed.HasForm(StaticItem)
	Debug.Notification("This keg is empty!")
	else
Game.ForceThirdPerson()
Game.DisablePlayerControls(false, false, true, false, false, false, false)	
	Debug.SendanimationEvent(PlayerRef, "idleTG03UseMeadBarrel")						
	Utility.Wait(2.8)
	PlayerRef.additem(FoodMead, 2)
	Utility.Wait(0.5)
	Debug.SendanimationEvent(PlayerRef, "IdleForceDefaultState")	
	Interact_AlreadyUsed.AddForm(StaticItem)
	Game.EnablePlayerControls()
	endif

Elseif Interact_Hay.HasForm(StaticItem.GetBaseObject()) && AR_PickUpBooks.GetValue() == 1
	If  Interact_AlreadyUsed.HasForm(StaticItem)
	Debug.Notification("There's no more usable straw in this bale!")
	else
Game.ForceThirdPerson()
Game.DisablePlayerControls(false, false, true, false, false, false, false)	
	Debug.SendanimationEvent(PlayerRef, "idlepickup_ground")						
	Utility.Wait(1.5)
	PlayerRef.additem(BYOHMaterialStraw, 2)
	Utility.Wait(1.8)
	Debug.SendanimationEvent(PlayerRef, "IdleForceDefaultState")	
	Game.EnablePlayerControls()
	Interact_AlreadyUsed.AddForm(StaticItem)
	endif

elseif Interact_LightedFire.HasForm(StaticItem.GetBaseObject()) && !Interact_AlreadyUsed.HasForm(StaticItem) && AR_PutOutFire.GetValue() == 1
Game.ForceThirdPerson()
Game.DisablePlayerControls(false, false, true, false, false, false, false)	
	Interact_AlreadyUsed.AddForm(StaticItem)
	Debug.SendanimationEvent(PlayerRef, "idlecarrybucketpourenter")						
	Utility.Wait(1.7)
	StaticItem.disable()	
	;StaticItem.Delete()
	Fire()
	Utility.Wait(2.3)
	PlayerRef.additem(Firewood01, 4)
	Debug.SendanimationEvent(PlayerRef, "IdleForceDefaultState")	
	Utility.Wait(0.1)
	Game.EnablePlayerControls()

elseif AR_Interact_Dummys.HasForm(StaticItem.GetBaseObject()) && AR_Dummys.GetValue() == 1
Game.ForceThirdPerson()
Game.DisablePlayerControls(false, false, true, false, false, false, false)
	AR_DogUp.SetValue(2)
	utility.wait(0.3)
	;playerref.SetAngle( playerref.GetAngleX(), playerref.GetAngleY(), playerref.GetAngleZ() - 25  )
	PlayerRef.PlayIdle(idlegreybeardwordteach)
	Utility.Wait(16)
		Playerref.EquipItem(AR_Energized, false, true)
	Debug.notification("Feeling energized!")
	Debug.SendanimationEvent(PlayerRef, "IdleForceDefaultState")	
	AR_DogUp.SetValue(0)
	Game.EnablePlayerControls()

else 

If AR_DisplayMessages.GetValue() == 1 && Game.GetPlayerGrabbedRef() == none
Debug.Notification("No nearby items to interact with")
Game.EnablePlayerControls()
endif
endif
endif
EndEvent

Function Fire()
Int FireList = 1
While Firelist < 27
ObjectReference Fire = Game.FindClosestReferenceOfType(Interact_LightedFire.GetAt(FireList), 0.0, 0.0, 0.0, 200.0)
If Fire == None
else
	Interact_AlreadyUsed.AddForm(Fire)
	Fire.disable()	
;	Fire.Delete()
endif
FireList = FireList +1
endwhile
endfunction

Function IsPlayerIn3rd()
	If AR_ThirdPerson.GetValue() == 1 && Game.GetCameraState() == 0
	Game.ForceThirdPerson()
	Game.DisablePlayerControls(false, false, true, false, false, false, false)
	returntofirstperson = true
	else
	Game.DisablePlayerControls(false, false, true, false, false, false, false)
	endif
Endfunction

Function Returnto1st()
				If returntofirstperson == true && AR_ReturnTo1st.GetValue() == 1
					IF playerref.issneaking() == false
					Debug.SendanimationEvent(PlayerRef, "IdleForceDefaultState")	
					endif
				returntofirstperson = false
				Game.ForceFirstPerson()
				Game.EnablePlayerControls()
				else
				Game.EnablePlayerControls()
				Endif
endfunction