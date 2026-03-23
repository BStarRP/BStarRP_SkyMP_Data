;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 6
Scriptname AnimatedFishing_Perk Extends Perk Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akTargetRef, Actor akActor)
;BEGIN CODE
If !AnimatedFishing_UsedActivators.HasForm(akTargetRef)
Int BaitNum = Utility.RandomInt(2, 4)
PlayerRef.AddItem(AnimatedFishing_FreeBaitForTheTaking, BaitNum, true)
PlayerRef.AddItem(AnimatedFishing_FreeBaitForTheTaking, (BaitNum - 1), true)
ITMGenericIngredientUpSD.play(PlayerRef)
AnimatedFishing_UsedActivators.AddForm(akTargetRef)
AnimatedFishing_YouGetBait.Show()
endif
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Actor Property PlayerRef Auto
FormList Property AnimatedFishing_UsedActivators Auto
LeveledItem Property AnimatedFishing_FreeBaitForTheTaking Auto
Message Property AnimatedFishing_YouGetBait Auto
Sound Property ITMGenericIngredientUpSD Auto
