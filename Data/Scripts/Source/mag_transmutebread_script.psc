Scriptname MAG_TransmuteBread_Script extends ActiveMagicEffect  

MiscObject Property Firewood Auto
Potion Property BreadLoaf Auto
Message Property FailureMessage Auto


Event OnEffectStart(Actor akTarget, Actor akCaster)

	If akCaster.GetItemCount(Firewood) >= 1
		akCaster.RemoveItem(Firewood)
		akCaster.AddItem(BreadLoaf)
		Game.AdvanceSkill("Alteration", 150.0)
	ElseIf akCaster.GetItemCount(Firewood) == 0
		FailureMessage.Show()
	Endif
	
EndEvent