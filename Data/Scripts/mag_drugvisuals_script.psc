Scriptname MAG_DrugVisuals_Script extends ActiveMagicEffect  

ImageSpaceModifier Property DrugMod01 Auto
ImageSpaceModifier Property DrugMod02 Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)

	If akTarget == Game.GetPlayer()
		DrugMod01.ApplyCrossFade(2.0)
		RegisterForSingleUpdate(6.0)
	EndIf

EndEvent

Event OnUpdate()
	
	DrugMod02.ApplyCrossFade(2.0)

EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)

	If akTarget == Game.GetPlayer()
		ImageSpaceModifier.RemoveCrossFade(2.0)	
	EndIf

endEvent
	