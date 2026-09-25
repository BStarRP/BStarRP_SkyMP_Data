Scriptname WaterskinEmptyScript extends ObjectReference  

Actor Property PlayerRef Auto

Idle Property IdleStop_Loose Auto
Idle Property idlepickup_ground Auto

Message Property WaterskinCannotFillMessage Auto

Potion Property WaterskinFilled Auto
MiscObject Property WaterskinEmpty Auto


Bool Function Refill()

	Game.DisablePlayerControls()
	Utility.Wait(0.1)
	Game.EnablePlayerControls()

	Bool handleFirstPerson = PlayerRef.GetAnimationVariableInt("i1stPerson") == 1 
	Bool handleWeaponDrawn = PlayerRef.IsWeaponDrawn()

	If handleFirstPerson
		Game.ForceThirdPerson()
	EndIf

	If handleWeaponDrawn
		PlayerRef.SheatheWeapon()
		While PlayerRef.GetAnimationVariablebool("isUnEquipping")
            Utility.wait(0.1)
        endWhile
	EndIf

	PlayerRef.PlayIdle(idlepickup_ground)
	Utility.Wait(1.0)

	PlayerRef.RemoveItem(WaterskinEmpty, 1, true, None)
	PlayerRef.AddItem(WaterskinFilled, 1, false)

	Utility.Wait(1.0)
	PlayerRef.PlayIdle(IdleStop_Loose)
	Utility.Wait(1.0)

	If handleFirstPerson
		Game.ForceThirdPerson()
	EndIf

	If handleWeaponDrawn
		PlayerRef.DrawWeapon()
	EndIf

EndFunction

Event OnEquipped(Actor akActor)

	If akActor != PlayerRef
		Return
	EndIf
	
	If !PlayerRef.IsInCombat() && PO3_SKSEFunctions.IsActorInWater(PlayerRef) && !PlayerRef.IsSwimming()
		Refill()
	Else
		WaterskinCannotFillMessage.Show()
	EndIf

EndEvent

