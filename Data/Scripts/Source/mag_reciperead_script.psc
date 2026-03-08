Scriptname MAG_RecipeRead_Script extends ObjectReference  

Perk Property CookingPerk Auto
Actor Property PlayerRef Auto

Event OnRead()

    PlayerRef.AddPerk(CookingPerk)

EndEvent