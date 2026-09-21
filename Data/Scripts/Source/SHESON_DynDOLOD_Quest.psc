Scriptname SHESON_DynDOLOD_Quest extends Quest

Event OnInit()
	Initialize()
EndEvent

Function Initialize()
	if SKSE.GetVersionRelease() == SKSE.GetScriptVersionRelease()
		if SKSE.GetVersionRelease() >= SHESON_DynDOLOD_Plugin.GetSKSEVersion()
			if SHESON_DynDOLOD_Plugin.GetVersion() == SHESON_DynDOLOD_Plugin.GetScriptVersion()
				if (Game.GetFormFromFile(0x00000910, "DynDOLOD.esp") As Keyword).GetString() != "" && Math.RightShift((Game.GetFormFromFile(0x00000910, "DynDOLOD.esp") As Form).GetFormID(), 24) < SHESON_DynDOLOD_Plugin.GetPluginLimit()
					Utility.Wait(3)
					LastMessage = SHESON_DynDOLOD_Plugin.GetLastMessage()
					if SHESON_DynDOLOD_Plugin.GetSuccessful()
						if LastMessage == ""
							LastMessage = "DynDOLOD successfully initialized"
						endIf
						if Active != 1
							Debug.Notification(LastMessage)
						endIf
						Active = 1;
						Debug.Trace(LastMessage)
					else
						Active = 0;
						if LastMessage == ""
							LastMessage = "DynDOLOD error"
						endIf
						Debug.MessageBox(LastMessage)
						Debug.Trace(LastMessage)
					endIf	
				else
					Active = 0;
					LastMessage = "DynDOLOD.esp not found or too high in the load order"
					Debug.MessageBox(LastMessage)
					Debug.Trace(LastMessage)
				endIf	
			else
				Active = 0;
				LastMessage = "DynDOLOD.DLL and papyrus scripts versions do not match"
				Debug.MessageBox(LastMessage)
				Debug.Trace(LastMessage + " " + SHESON_DynDOLOD_Plugin.GetVersion() + " " + SHESON_DynDOLOD_Plugin.GetScriptVersion())
			endIf	
		else
			Active = 0;
			LastMessage = "DynDOLOD.DLL and SKSE versions do not match"
			Debug.MessageBox(LastMessage)
			Debug.Trace(LastMessage + " " + SKSE.GetVersionRelease() + " " + SHESON_DynDOLOD_Plugin.GetSKSEVersion())
		endIf
	else
		Active = 0;
		LastMessage = "DynDOLOD requires SKSE"
		Debug.MessageBox(LastMessage)
		Debug.Trace(LastMessage + " " + SKSE.GetVersionRelease() + " " + SKSE.GetScriptVersionRelease())
	endIf
endFunction

Actor Property PlayerRef Auto
Int Property Active = -1 Auto
String Property LastMessage = "Initializing" Auto
