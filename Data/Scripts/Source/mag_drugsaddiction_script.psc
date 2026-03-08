Scriptname MAG_DrugsAddiction_Script extends ActiveMagicEffect  

Spell Property AddictionSpell01 Auto
Spell Property AddictionSpell02 Auto
Spell Property AddictionSpell03 Auto
Message Property AddictionMessage01 Auto
Message Property AddictionMessage02 Auto
Message Property AddictionMessage03 Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)

	Int Random = Utility.RandomInt(1, 100)

	If (Random <= 25) 
		If (akTarget.HasSpell(AddictionSpell01) == 0) && (akTarget.HasSpell(AddictionSpell02) == 0) && (akTarget.HasSpell(AddictionSpell03) == 0)
			AddictionMessage01.Show()
			akTarget.AddSpell(AddictionSpell01, false)
		ElseIf (akTarget.HasSpell(AddictionSpell01) == 1) 
			AddictionMessage02.Show()
			akTarget.AddSpell(AddictionSpell02, false)
		ElseIf (akTarget.HasSpell(AddictionSpell02) == 1)
			AddictionMessage03.Show()
			akTarget.AddSpell(AddictionSpell03, false)
		ElseIf (akTarget.HasSpell(AddictionSpell03) == 1)
			akTarget.AddSpell(AddictionSpell03, false)
		EndIf
	ElseIf (Random >= 26) 
		If (akTarget.HasSpell(AddictionSpell01) == 1) 
			akTarget.RemoveSpell(AddictionSpell01)
			akTarget.AddSpell(AddictionSpell01, false)
		ElseIf (akTarget.HasSpell(AddictionSpell02) == 1) 
			akTarget.RemoveSpell(AddictionSpell02)
			akTarget.AddSpell(AddictionSpell02, false)
		ElseIf (akTarget.HasSpell(AddictionSpell03) == 1)
			akTarget.RemoveSpell(AddictionSpell03)
			akTarget.AddSpell(AddictionSpell03, false)
		EndIf
	EndIf

EndEvent

