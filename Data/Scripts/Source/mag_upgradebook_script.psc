Scriptname MAG_UpgradeBook_Script extends ActiveMagicEffect  

Perk Property FoodPerk Auto
Spell Property FoodSpell Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)

	akTarget.AddPerk(FoodPerk)
	akTarget.RemoveSpell(FoodSpell)

EndEvent