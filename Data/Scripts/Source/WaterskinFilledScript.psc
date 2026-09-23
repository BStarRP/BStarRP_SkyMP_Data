Scriptname WaterskinFilledScript extends ActiveMagicEffect  

Actor Property PlayerRef Auto

WaterskinSurvivalScript Property WaterskinSurvivalQuest Auto


MiscObject Property WaterskinEmpty Auto

GlobalVariable Property WaterskinDegradationChance Auto

Message Property WaterskinDegradedMessage Auto

Bool Processing = False

Event OnEffectStart(Actor akTarget, Actor akCaster)

	If Utility.RandomInt(0, 100) < WaterskinDegradationChance.GetValueInt()
		If akTarget == PlayerRef
			WaterskinDegradedMessage.Show()
		EndIf
	Else
		akTarget.AddItem(WaterskinEmpty, 1, true)
	EndIf

	WaterskinSurvivalQuest.OnWaterskinDrink()

EndEvent

