Scriptname FPHqsMain extends Quest  
;==============================
; Notes on scale
; GetScale (console)
;		primary value is the scale value set via SetScale (usually 1.0, gonna call it the setscale modifier) 
;		base value is the original actorbase or racial base scale, multiplied by the setscale modifier
;		does not reflect changes made via SetNodeScale("skeleton.nif")
; GetScale (Papyrus)
;		returns product of setscale modifier and original base scale (same as console's base value)
;		does not reflect changes made via SetNodeScale("skeleton.nif")
; SetScale (console and papyrus)
;		Sets base scale to (original base scale * setscale modifier)
;		Overrides SetNodeScale changes - sets skeleton.nif node scale to (original base scale * setscale modifier)
;		Causes character to both look and move like they're (original base scale * setscale modifier)
; SetNodeScale("skeleton.nif")
;		determines final visual character height, regardless of setscale modifier or actor base scale
;		but is overridden by SetScale if it's applied after SetNodeScale("skeleton.nif")
;		does not effect run speed or jumping
;		does not effect 3rd person camera height (unfortunately)
;		does effect 1st person camera height, if applied to 1st person skeleton (SKSE does it automatically if in 1st person)
;		don't think it effects bounding box
;
; Valid camera states
; 0 - first person
; 1 - auto vanity
; 2 - VATS
; 3 - free
; 4 - iron sights
; 5 - furniture
; 6 - transition		(transition to werewolf mode)
; 7 - tweenmenu
; 8 - third person 1	(also transition to werewolf mode?)
; 9 - third person 2	(3rd for both normal and werewolf)
; 10 - horse
; 11 - bleedout
; 12 - dragon
;==============================

ObjectReference property PlayerRef auto
Actor Property PlayerActor auto
ActorBase Property PlayerActorBase auto
Race Property WerewolfBeastRace Auto
Race Property DLC1VampireBeastRace Auto

string Property RACE_MENU = "RaceSex Menu" AutoReadOnly

string Property baseNodeNameFirst
	string function get()
		if NetImmerse.HasNode(PlayerActor, "skeleton.nif", true)
			return "skeleton.nif"
		Else
			Debug.Trace("FPH: Something's not right here. First person base node not found.")
		EndIf
	EndFunction
EndProperty

float Property PlayerCurrentNodeScaleFirst hidden
	float function Get()
		return NetImmerse.GetNodeScale(PlayerActor, baseNodeNameFirst, true)
	EndFunction
	function Set(float afNewScale)
		NetImmerse.SetNodeScale(PlayerActor, baseNodeNameFirst, afNewScale, true)
	endFunction
EndProperty

;==============================

Event OnInit()
	UpdateHeight()
	RegisterForMenu(RACE_MENU)
EndEvent

Event OnMenuClose(String MenuName)
	if MenuName == RACE_MENU
		UpdateHeight()
	EndIf
EndEvent

function UpdateHeight()
	Utility.Wait(0.1)
	if !PlayerActor.IsOnMount() && !PlayerActor.IsDead() && !UI.IsMenuOpen(RACE_MENU)
		int	aiCameraState = Game.GetCameraState()
		if aiCameraState == 0 || aiCameraState == 9
			Race kPlayerRace = PlayerActorBase.GetRace()
			if kPlayerRace != WerewolfBeastRace && kPlayerRace != DLC1VampireBeastRace
				float PlayerTargetHeight = PlayerRef.GetScale()
				PlayerCurrentNodeScaleFirst = PlayerTargetHeight
			EndIf
		EndIf
	EndIf
EndFunction

function OnSaveLoaded()
	UpdateHeight()
	RegisterForMenu(RACE_MENU)	
EndFunction