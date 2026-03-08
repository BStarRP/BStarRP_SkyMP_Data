Scriptname MAG_AddictionSpell03_Script extends ActiveMagicEffect  

Actor Property PlayerRef Auto 
Spell Property AddictionSpell01 Auto
Spell Property AddictionSpell02 Auto
Spell Property AddictionSpell03 Auto
Message Property AddictionOutMessage Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
	
	PlayerRef.RemoveSpell(AddictionSpell02)
	RegisterForSingleUpdateGameTime(24)

EndEvent

Event OnUpdateGameTime()

	AddictionOutMessage.Show()
	PlayerRef.AddSpell(AddictionSpell02, false)
	PlayerRef.RemoveSpell(AddictionSpell03)

EndEvent

