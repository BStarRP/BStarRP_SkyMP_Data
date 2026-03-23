Scriptname ActivationKeyScript Extends ReferenceAlias

GlobalVariable Property AKK_Hotkey Auto
GlobalVariable Property AlternativeActivationKey Auto
Int CurrentKeyCode
Int OldKeyCode
Actor Property PlayerRef Auto

Event OnInIt()
CurrentKeyCode = (AKK_Hotkey.GetValue() as Int)
OldKeyCode = CurrentKeyCode 
RegisterForKey(CurrentKeyCode)
EndEvent

Event OnPlayerLoadGame()
If (AKK_Hotkey.GetValue() as int) != CurrentKeyCode
OldKeyCode = CurrentKeyCode
CurrentKeyCode = (AKK_Hotkey.GetValue() as Int)
UnregisterForKey(OldKeyCode)
RegisterForKey(CurrentKeyCode)
Debug.notification("New Activation Key Registered")
endif
EndEvent

;;;


Event OnKeyDown(Int KeyCode)
    If !UI.IsTextInputEnabled() && !Utility.IsInMenuMode() && !PlayerRef.IsSprinting() 
        If KeyCode == CurrentKeyCode
            AlternativeActivationKey.SetValue(1)
            PO3_SKSEFunctions.UpdateCrosshairs()

	while Input.IsKeyPressed(KeyCode)
	utility.wait(0.2)
	endwhile

			If CurrentKeyCode < 266
			AlternativeActivationKey.SetValue(0)
			PO3_SKSEFunctions.UpdateCrosshairs()
			Endif
        EndIf
    Endif
EndEvent


;;; The following is mostly for controllers, as IsKeyPressed doesn't like controllers

Event OnKeyUp(Int KeyCode, Float HoldTime)
      	if KeyCode == CurrentKeyCode && AlternativeActivationKey.GetValue() == 1
		AlternativeActivationKey.SetValue(0)
		PO3_SKSEFunctions.UpdateCrosshairs()
	EndIf
EndEvent
