Scriptname MERETHPerkonActvator extends ObjectReference

Perk Property MyPerk1 Auto
Perk Property MyPerk2 Auto
Perk Property MyPerk3 Auto
Perk Property MyPerk4 Auto
Perk Property MyPerk5 Auto
Perk Property MyPerk6 Auto
Perk Property MyPerk7 Auto
Perk Property MyPerk8 Auto
Perk Property MyPerk9 Auto
Perk Property MyPerk10 Auto

Event OnActivate(ObjectReference akActionRef)
    if (akActionRef == Game.GetPlayer())
        Game.GetPlayer().AddPerk(MyPerk1)
        Game.GetPlayer().AddPerk(MyPerk2)
        Game.GetPlayer().AddPerk(MyPerk3)
        Game.GetPlayer().AddPerk(MyPerk4)
        Game.GetPlayer().AddPerk(MyPerk5)
        Game.GetPlayer().AddPerk(MyPerk6)
        Game.GetPlayer().AddPerk(MyPerk7)
        Game.GetPlayer().AddPerk(MyPerk8)
        Game.GetPlayer().AddPerk(MyPerk9)
        Game.GetPlayer().AddPerk(MyPerk10)
    endIf
EndEvent
