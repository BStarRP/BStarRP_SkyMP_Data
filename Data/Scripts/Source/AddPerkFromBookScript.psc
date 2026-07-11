Scriptname AddPerkFromBookScript extends ObjectReference
{Generic script for adding a Perk to the player when a book is read.}

Perk property PerkToAdd Auto
Actor Property PlayerRef Auto

Event OnRead()
	If (Game.GetPlayer().HasPerk(PerkToAdd) == 0)
		Game.GetPlayer().AddPerk(PerkToAdd)
		Game.GetPlayer().RemoveItem(SpellTome, 1)
	EndIf
EndEvent

book Property SpellTome  Auto 