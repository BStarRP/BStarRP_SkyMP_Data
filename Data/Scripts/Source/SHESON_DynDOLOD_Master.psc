Scriptname SHESON_DynDOLOD_Master extends ObjectReference

; This is for backwards compatibility for 3rd party script patches
Function IBowToTheev2(ObjectReference MyFirstborn, Int FirstbornList, Int MinionList, Bool MyAttach, Bool MyActivateAll)
	; update all dynamic LOD references in the current worldspace
	if SHESON_DynDOLOD_Plugin.GetMyMaster() && SHESON_DynDOLOD_Plugin.GetMyActive()
		SHESON_DynDOLOD_Plugin.SetMyActive(TRUE)
	endIf
EndFunction

Event OnInit()
	MyActiveFirstborn = self
EndEvent

Actor Property PlayerRef Auto
SHESON_DynDOLOD_Quest Property MyQuest = None Auto
ObjectReference Property MyActiveFirstborn = None Auto
Int Property MyCurrentFirstbornList = 0 Auto
Int Property MyCurrentMinionList = 0 Auto
