Scriptname FPHrasPlayer extends ReferenceAlias  

FPHqsMain Property FPHmain Auto

Event OnPlayerLoadGame()
	FPHmain.OnSaveLoaded()
EndEvent

Event OnRaceSwitchComplete()
	FPHmain.UpdateHeight()
EndEvent

Event OnGetUp(ObjectReference akFurniture)
	FPHmain.UpdateHeight()
EndEvent