Scriptname MAG_GourmetSecrets_Script extends ObjectReference  

Message Property ChoiceMessage Auto
GlobalVariable Property SecretsLearned Auto
Spell Property BuffSpell01 Auto
Spell Property BuffSpell02 Auto
Spell Property BuffSpell03 Auto
Book Property SecretBook Auto
Actor Property PlayerRef Auto

Function ReadGourmetSecrets()

int choice = ChoiceMessage.Show()

	If Choice == 0
		;Do Nothing
	ElseIf Choice == 1 
		PlayerRef.AddSpell(BuffSpell01)
	ElseIf Choice == 2 
		PlayerRef.AddSpell(BuffSpell02)
	ElseIf Choice == 3
		PlayerRef.AddSpell(BuffSpell03)
	EndIf
	
	If Choice != 0
		PlayerRef.RemoveItem(SecretBook, 1, 1)
		SecretsLearned.SetValue(1.0)
	EndIf

EndFunction

Event OnRead()

	float BookRead = SecretsLearned.GetValue()
	
	If (BookRead == 0) && (PlayerRef.GetItemCount(SecretBook) >= 1)	
		Utility.WaitMenuMode(1.25)
		ReadGourmetSecrets()
	EndIf

EndEvent


