Scriptname MAG_AddictionSpell01_Script extends ActiveMagicEffect  

Actor Property PlayerRef Auto 
Spell Property AddictionSpell01 Auto
Spell Property AddictionSpell02 Auto
Spell Property AddictionSpell03 Auto
Message Property AddictionOutMessage Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
	
	RegisterForSingleUpdateGameTime(24)

EndEvent

Event OnUpdateGameTime()

	AddictionOutMessage.Show()
	PlayerRef.RemoveSpell(AddictionSpell01)

EndEvent
