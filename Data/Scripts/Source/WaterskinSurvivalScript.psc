Scriptname WaterskinSurvivalScript extends Quest  

GlobalVariable Property WaterskinSurvivalCooldown Auto
GlobalVariable Property WaterskinSurvivalIsInCooldown Auto

Potion Property WaterskinFilled Auto
MagicEffect Property Survival_FoodRestoreHungerVerySmall Auto


Bool Processing = False

Event OnWaterskinDrink()

	While Processing
		Utility.Wait(0.1)
	EndWhile

	Processing = True

	If WaterskinSurvivalIsInCooldown.GetValue() == 0.0
		WaterskinSurvivalIsInCooldown.SetValue(1.0)
		PO3_SKSEFunctions.RemoveMagicEffectFromPotion(WaterskinFilled, Survival_FoodRestoreHungerVerySmall, 0.0, 0, 0, 0.0)
		RegisterForSingleUpdateGameTime(WaterskinSurvivalCooldown.GetValue())
	EndIf

	Processing = False
	
EndEvent

Event OnUpdateGameTime()

	PO3_SKSEFunctions.AddMagicEffectToPotion(WaterskinFilled, Survival_FoodRestoreHungerVerySmall, 0.0, 0, 0, 0.0, None)
	WaterskinSurvivalIsInCooldown.SetValue(0.0)

EndEvent

