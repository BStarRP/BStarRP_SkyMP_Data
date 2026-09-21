Scriptname SHESON_DynDOLOD_ObjectActivator extends ObjectReference

Event OnLoad()
	if SHESON_DynDOLOD_Plugin.GetMyMaster() && SHESON_DynDOLOD_Plugin.GetMyActive()
		SHESON_DynDOLOD_Plugin.SetMyActive(TRUE)
	endIf
endEvent

Event OnUnload()
	if SHESON_DynDOLOD_Plugin.GetMyMaster() && SHESON_DynDOLOD_Plugin.GetMyActive()
		SHESON_DynDOLOD_Plugin.SetMyActive(TRUE)
	endIf
endEvent

Actor Property PlayerRef Auto
