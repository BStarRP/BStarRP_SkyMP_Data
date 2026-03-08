Scriptname MAG_UpgradeBottle_Script extends ActiveMagicEffect  

Perk Property MeadPerk Auto
Spell Property MeadSpell Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)

	akTarget.AddPerk(MeadPerk)
	akTarget.AddSpell(MeadSpell)

EndEvent