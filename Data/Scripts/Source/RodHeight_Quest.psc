Scriptname RodHeight_Quest extends ReferenceAlias  

Int FirstTime = 0

Event OnInIt()
NewRace()
PlayerRef.AddPerk(AnimatedFishing_FurniturePerk)
EndEvent

Event OnRaceSwitchComplete()
NewRace()
EndEvent

Event OnPlayerLoadGame()

If FirstTime == 0
NewRace()
FirstTime = 1
Endif

EndEvent

Function NewRace()

If RodHeight_IgnoreRaceChanges.GetValue() == 0
    ActorBase PlayerBase = PlayerRef.GetActorBase()
	
    If PlayerBase.GetSex() == 0 
        If PlayerRef.GetRace() == ArgonianRace || PlayerRef.GetRace() == ArgonianRaceVampire
            RodHeight.SetValue(RodHeight_MaleArgonian.GetValue())
        ElseIf PlayerRef.GetRace() == BretonRace || PlayerRef.GetRace() == BretonRaceVampire
            RodHeight.SetValue(RodHeight_MaleBreton.GetValue())
        ElseIf PlayerRef.GetRace() == DarkElfRace || PlayerRef.GetRace() == DarkElfRaceVampire
            RodHeight.SetValue(RodHeight_MaleDarkElf.GetValue())
        ElseIf PlayerRef.GetRace() == HighElfRace || PlayerRef.GetRace() == HighElfRaceVampire
            RodHeight.SetValue(RodHeight_MaleHighElf.GetValue())
        ElseIf PlayerRef.GetRace() == ImperialRace || PlayerRef.GetRace() == ImperialRaceVampire
            RodHeight.SetValue(RodHeight_MaleImperial.GetValue())
        ElseIf PlayerRef.GetRace() == KhajiitRace || PlayerRef.GetRace() == KhajiitRaceVampire
            RodHeight.SetValue(RodHeight_MaleKhajiit.GetValue())
        ElseIf PlayerRef.GetRace() == NordRace || PlayerRef.GetRace() == NordRaceVampire
            RodHeight.SetValue(RodHeight_MaleNord.GetValue())
        ElseIf PlayerRef.GetRace() == OrcRace || PlayerRef.GetRace() == OrcRaceVampire
            RodHeight.SetValue(RodHeight_MaleOrc.GetValue())
        ElseIf PlayerRef.GetRace() == RedguardRace || PlayerRef.GetRace() == RedguardRaceVampire
            RodHeight.SetValue(RodHeight_MaleRedguard.GetValue())
        ElseIf PlayerRef.GetRace() == WoodElfRace || PlayerRef.GetRace() == WoodElfRaceVampire
            RodHeight.SetValue(RodHeight_MaleWoodElf.GetValue())
        EndIf
    Else
        If PlayerRef.GetRace() == ArgonianRace || PlayerRef.GetRace() == ArgonianRaceVampire
            RodHeight.SetValue(RodHeight_FemaleArgonian.GetValue())
        ElseIf PlayerRef.GetRace() == BretonRace || PlayerRef.GetRace() == BretonRaceVampire
            RodHeight.SetValue(RodHeight_FemaleBreton.GetValue())
        ElseIf PlayerRef.GetRace() == DarkElfRace || PlayerRef.GetRace() == DarkElfRaceVampire
            RodHeight.SetValue(RodHeight_FemaleDarkElf.GetValue())
        ElseIf PlayerRef.GetRace() == HighElfRace || PlayerRef.GetRace() == HighElfRaceVampire
            RodHeight.SetValue(RodHeight_FemaleHighElf.GetValue())
        ElseIf PlayerRef.GetRace() == ImperialRace || PlayerRef.GetRace() == ImperialRaceVampire
            RodHeight.SetValue(RodHeight_FemaleImperial.GetValue())
        ElseIf PlayerRef.GetRace() == KhajiitRace || PlayerRef.GetRace() == KhajiitRaceVampire
            RodHeight.SetValue(RodHeight_FemaleKhajiit.GetValue())
        ElseIf PlayerRef.GetRace() == NordRace || PlayerRef.GetRace() == NordRaceVampire
            RodHeight.SetValue(RodHeight_FemaleNord.GetValue())
        ElseIf PlayerRef.GetRace() == OrcRace || PlayerRef.GetRace() == OrcRaceVampire
            RodHeight.SetValue(RodHeight_FemaleOrc.GetValue())
        ElseIf PlayerRef.GetRace() == RedguardRace || PlayerRef.GetRace() == RedguardRaceVampire
            RodHeight.SetValue(RodHeight_FemaleRedguard.GetValue())
        ElseIf PlayerRef.GetRace() == WoodElfRace || PlayerRef.GetRace() == WoodElfRaceVampire
            RodHeight.SetValue(RodHeight_FemaleWoodElf.GetValue())
        EndIf
    EndIf

RodHeight_MCM_Rec.SetValue(RodHeight.GetValue())

Endif
EndFunction

Actor Property PlayerRef Auto
GlobalVariable Property RodHeight Auto
GlobalVariable Property RodHeight_IgnoreRaceChanges Auto
GlobalVariable Property RodHeight_MCM_Rec Auto

GlobalVariable Property RodHeight_MaleArgonian Auto
GlobalVariable Property RodHeight_FemaleArgonian Auto
GlobalVariable Property RodHeight_MaleBreton Auto
GlobalVariable Property RodHeight_FemaleBreton Auto
GlobalVariable Property RodHeight_MaleDarkElf Auto
GlobalVariable Property RodHeight_FemaleDarkElf Auto
GlobalVariable Property RodHeight_MaleHighElf Auto
GlobalVariable Property RodHeight_FemaleHighElf Auto
GlobalVariable Property RodHeight_MaleImperial Auto
GlobalVariable Property RodHeight_FemaleImperial Auto
GlobalVariable Property RodHeight_MaleKhajiit Auto
GlobalVariable Property RodHeight_FemaleKhajiit Auto
GlobalVariable Property RodHeight_MaleNord Auto
GlobalVariable Property RodHeight_FemaleNord Auto
GlobalVariable Property RodHeight_MaleOrc Auto
GlobalVariable Property RodHeight_FemaleOrc Auto
GlobalVariable Property RodHeight_MaleRedguard Auto
GlobalVariable Property RodHeight_FemaleRedguard Auto
GlobalVariable Property RodHeight_MaleWoodElf Auto
GlobalVariable Property RodHeight_FemaleWoodElf Auto

Race Property ArgonianRace Auto
Race Property BretonRace Auto
Race Property DarkElfRace Auto
Race Property HighElfRace Auto
Race Property ImperialRace Auto
Race Property KhajiitRace Auto
Race Property NordRace Auto
Race Property OrcRace Auto
Race Property RedguardRace Auto
Race Property WoodElfRace Auto
Race Property ArgonianRaceVampire Auto
Race Property BretonRaceVampire Auto
Race Property DarkElfRaceVampire Auto
Race Property HighElfRaceVampire Auto
Race Property ImperialRaceVampire Auto
Race Property KhajiitRaceVampire Auto
Race Property NordRaceVampire Auto
Race Property OrcRaceVampire Auto
Race Property RedguardRaceVampire Auto
Race Property WoodElfRaceVampire Auto

Perk Property AnimatedFishing_FurniturePerk Auto
