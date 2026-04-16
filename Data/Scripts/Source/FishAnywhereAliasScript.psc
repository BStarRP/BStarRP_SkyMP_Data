Scriptname FishAnywhereAliasScript extends ReferenceAlias

Event OnPlayerLoadGame()
	UnregisterForAnimationEvent(PlayerRef, "WeaponSwing")
	UnregisterForAnimationEvent(PlayerRef, "WeaponLeftSwing")
EndEvent

Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
	UpdateRegistrations()
EndEvent

Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
	UpdateRegistrations()
EndEvent

Function UpdateRegistrations()
	If FishingPoleEquipped()
		RegisterForControl("Left Attack/Block")
		RegisterForControl("Right Attack/Block")
	Else
		UnregisterForControl("Left Attack/Block")
		UnregisterForControl("Right Attack/Block")
	EndIf
EndFunction

bool Function FishingPoleEquipped()
	Return ccBGSSSE001_FishingSystemQuest.GetCurrentFishingRodType() != ccBGSSSE001_FishingSystemQuest.RODTYPE_NONE
EndFunction

Event OnControlDown(string control)
	If !playerRef.IsWeaponDrawn()
		Return
	EndIf
	GoToState("Testing")
	Weapon item
	If control == "Left Attack/Block"
		item = PlayerRef.GetEquippedWeapon(true)
	ElseIf control == "Right Attack/Block"
		item = PlayerRef.GetEquippedWeapon(false)
	EndIf
	If item && item.HasKeyword(ccBGSSSE001_FishingPoleKW)
		TestWater(item)
	EndIf
	GoToState("")
EndEvent

State Testing
	Event OnControlDown(string control)
	EndEvent
EndState

Function TestWater(Weapon item)
	If PlayerRef.IsSwimming() || !ccBGSSSE001_FishingSystemQuest.IsFishingAllowed(ccBGSSSE001_FishingSystemQuest.GetCurrentFishingRodType())
		Return
	EndIf

	FishAnywhereTarget.Enable()
	FishAnywhereTarget.MoveTo(\
		PlayerRef,\
		1000 * Math.Sin(PlayerRef.GetAngleZ()),\
		1000 * Math.Cos(PlayerRef.GetAngleZ()),\
		-200\
	)
	FishAnywhereSource.MoveTo(\
		PlayerRef,\
		50 * Math.Sin(PlayerRef.GetAngleZ()),\
		50 * Math.Cos(PlayerRef.GetAngleZ()),\
		PlayerRef.GetHeight()\
	)
	FishAnywhereSpell.Cast(FishAnywhereSource, FishAnywhereTarget)
	Utility.Wait(1)
	FishAnywhereTarget.Disable()
EndFunction

Function TestWaterFailure()
	FishAnywhereTarget.Disable()
	FishAnywhereWaterMessage.Show()
EndFunction

Function TestWaterSuccess()
	FishAnywhereTarget.Disable()

	ObjectReference[] fishingSpots = PO3_SKSEFunctions.FindAllReferencesOfType(PlayerRef, FishAnywhereActivators, 0)
	ccBGSSSE001_FishingActScript fishingSpot = None

	float minDistance
	int i = fishingSpots.Length
	While i
		i -= 1
		If !IsDefaultFishingSpot(fishingSpot)
			ObjectReference candidate = fishingSpots[i]
			float distance = candidate.GetDistance(PlayerRef)
			If !fishingSpot || distance < minDistance
				fishingSpot = candidate as ccBGSSSE001_FishingActScript
				minDistance = distance
			EndIf
		EndIf
	EndWhile

	If !fishingSpot
		fishingSpot = GetFishingSpot()
		fishingSpot.Disable()
		fishingSpot.MoveTo(PlayerRef)
	EndIf

	fishingMarker = fishingSpot.GetFishingMarker()
	fishingMarker.MoveTo(PlayerRef)
	fishingMarker.SetAngle(0, 0, PlayerRef.GetAngleZ())
	FishAnywhereFollowerMarker.MoveTo(\
		PlayerRef,\
		-400 * Math.Sin(PlayerRef.GetAngleZ()),\
		-400 * Math.Cos(PlayerRef.GetAngleZ()),\
		0\
	)
	ccBGSSSE001_FishingSystemQuest.StartPlayerInteraction(fishingSpot, False)
EndFunction

ObjectReference fishingMarker

bool Function IsDefaultFishingSpot(ObjectReference spot)
	Return spot == FishAnywhereDefaultCave || spot == FishAnywhereDefaultArctic || spot == FishAnywhereDefaultLake || spot == FishAnywhereDefaultStream
EndFunction

ccBGSSSE001_FishingActScript Function GetFishingSpot()
	If PlayerRef.GetParentCell().IsInterior()
		Return FishAnywhereDefaultCave
	EndIf
	If Weather.GetSkyMode() == 0 || Weather.GetSkyMode() == 1
		Return FishAnywhereDefaultCave
	EndIf
	If Weather.GetCurrentWeather().GetClassification() == 3
		Return FishAnywhereDefaultArctic
	EndIf
	If Utility.RandomInt(0, 1)
		FishAnywhereDefaultLake
	EndIf
	Return FishAnywhereDefaultStream
EndFunction

Keyword Property ccBGSSSE001_FishingPoleKW Auto
FormList Property FishAnywhereActivators Auto
Spell Property FishAnywhereSpell Auto
ObjectReference Property FishAnywhereSource Auto
ObjectReference Property FishAnywhereTarget Auto
ObjectReference Property FishAnywhereFollowerMarker Auto
Actor Property PlayerRef Auto

Message Property FishAnywhereMessage Auto
Message Property FishAnywhereWaterMessage Auto

ccBGSSSE001_FishingActScript Property FishAnywhereDefaultCave Auto
ccBGSSSE001_FishingActScript Property FishAnywhereDefaultArctic Auto
ccBGSSSE001_FishingActScript Property FishAnywhereDefaultLake Auto
ccBGSSSE001_FishingActScript Property FishAnywhereDefaultStream Auto

ccBGSSSE001_FishingSystemScript Property ccBGSSSE001_FishingSystemQuest Auto