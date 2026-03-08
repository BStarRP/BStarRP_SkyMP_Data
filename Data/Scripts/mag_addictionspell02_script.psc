Scriptname MAG_AddictionSpell02_Script extends ActiveMagicEffect  

Actor Property PlayerRef Auto 
Spell Property AddictionSpell01 Auto
Spell Property AddictionSpell02 Auto
Spell Property AddictionSpell03 Auto
Message Property AddictionOutMessage Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
	
	PlayerRef.RemoveSpell(AddictionSpell01)
	RegisterForSingleUpdateGameTime(24)

EndEvent

Event OnUpdateGameTime()

	AddictionOutMessage.Show()
	PlayerRef.AddSpell(AddictionSpell01, false)
	PlayerRef.RemoveSpell(AddictionSpell02)

EndEvent
