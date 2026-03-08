Scriptname MAG_SurvivalToggle_Script extends ActiveMagicEffect  

GlobalVariable Property SurvivalToggle Auto

Event OnEffectStart(Actor akTaget, Actor akCaster)

	SurvivalToggle.SetValue(0.0)

EndEvent

Event OnEffectFinish(Actor akTaget, Actor akCaster)

	SurvivalToggle.SetValue(100.0)

EndEvent