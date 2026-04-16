;/ Decompiled by Champollion V1.0.1
Source   : ccBGSSSE001_FishingActScript.psc
Modified : 2021-07-28 11:40:01
Compiled : 2021-11-13 20:17:07
User     : builds
Computer : RKVBGSBUILD07
/;
scriptName ccBGSSSE001_FishingActScript extends ObjectReference
{The main script attached to fishing supply items, which drives the majority of the fishing mechanic.}

;-- Properties --------------------------------------
Float property myQuestCatchChance = 1.00000 auto
{(Optional) What chance do I have of catching the quest item? Default: 1.0}
Int property myQuestRequiredStage = -1 auto
{(Optional) The minimum (or specific, if no RequiredStageMax set) quest stage required in order to catch items from the Quest Catch Data List, if any. Default: -1}
globalvariable property myQuestAllowCatchGlobal auto
{(Optional) The global variable that must be 1 to catch items from the Quest Catch Data List, if any. Intended use is to track when catching the quest item is allowed when a required Quest Stage will not work. Must be set externally (this script does not change the value). Default: None}
Int property BiomeType = 0 auto
{What type of biome this set of fishing supplies is in. 0 = Temperate Stream, 1 = Temperate Lake, 2 = Arctic, 3 = Cave. Default: 0}
Int property myQuestSetStageRequiredRodType = -1 auto
{(Optional) If this rod type is used, set myQuestStageToSet when the first item is caught. RODTYPE_IMPERIAL = 0, RODTYPE_ALIKRI = 1, RODTYPE_ARGONIAN = 2, RODTYPE_DWARVEN = 3 Default: -1}
ccbgssse001_fishingsystemscript property FishingSystem auto
{The system that handles all fishing gameplay mechanics.}
globalvariable property myQuestItemCaughtGlobal auto
{(Optional) The global variable that must be 0 to catch items from the Quest Catch Data List, if any. Intended use is to track when enough of the quest item has been caught. Must be set externally (this script does not change the value). Default: None}
quest property myQuest auto
{(Optional) The quest, if any, this set of fishing supplies is associated with. Default: None}
Int property myQuestRequiredStageMax = -1 auto
{(Optional) The maximum quest stage required in order to catch items from the Quest Catch Data List, if any. Default: -1}
formlist property myQuestCatchDataList auto
{(Optional) The quest item list to draw from for this set of fishing supplies. Default: None}
Int property myQuestStageToSet = -1 auto
{(Optional) The quest stage to set once a quest item is caught. Default: -1}
formlist property myOverrideJunkCatchDataList auto
{The junk override list to draw from for this set of fishing supplies, used for catching specific flavors of junk.}

;-- Variables ---------------------------------------
Bool wasMorningEvening = false
Int currentFishPopulation = 0
Bool calculatedPopulationRecently = false

;-- Functions ---------------------------------------

; Skipped compiler generated GotoState

function ReduceFishPopulation(Int aiAmount)

	currentFishPopulation -= aiAmount
	if currentFishPopulation < 0
		currentFishPopulation = 0
	endIf
endFunction

function UpdateFishCatchSuccess()

	; Empty function
endFunction

Bool function CanCatchQuestItem()

	if !myQuestCatchDataList
		return false
	endIf
	if myQuestRequiredStage > -1
		Int currentStage = myQuest.GetStage()
		if myQuestRequiredStageMax > -1
			if currentStage < myQuestRequiredStage || currentStage > myQuestRequiredStageMax
				return false
			endIf
		elseIf currentStage != myQuestRequiredStage
			return false
		endIf
	endIf
	if myQuestItemCaughtGlobal as Bool && myQuestItemCaughtGlobal.GetValueInt() != 0
		return false
	endIf
	if myQuestAllowCatchGlobal as Bool && myQuestAllowCatchGlobal.GetValueInt() != 1
		return false
	endIf
	if myQuestSetStageRequiredRodType > -1 && FishingSystem.GetCurrentFishingRodType() != myQuestSetStageRequiredRodType
		return false
	endIf
	if utility.RandomFloat(0.000000, 1.00000) > myQuestCatchChance
		return false
	endIf
	return true
endFunction

Bool function GetCalculatedPopulationRecently()

	return calculatedPopulationRecently
endFunction

function UpdateFish()

	; Empty function
endFunction

ObjectReference function GetFishingMarker()

	return self.GetLinkedRef(none)
endFunction

function UpdateNibble()

	; Empty function
endFunction

function OnUpdateGameTime()

	debug.trace("Fishing Supplies " + self as String + " OnUpdateGameTime()", 0)
	self.SetCalculatedPopulationRecently(false)
	self.SetWasMorningEvening(false)
	self.SetFishPopulation(0)
endFunction

function SetFishPopulation(Int aiValue)

	currentFishPopulation = aiValue
endFunction

; Skipped compiler generated GetState

function RegisterForPopulationUpdate(Float afHours)

	self.RegisterForSingleUpdateGameTime(afHours)
endFunction

Bool function GetWasMorningEvening()

	return wasMorningEvening
endFunction

function SetCalculatedPopulationRecently(Bool akCalculatedRecently)

	calculatedPopulationRecently = akCalculatedRecently
endFunction

function SetWasMorningEvening(Bool abWasMorningEvening)

	wasMorningEvening = abWasMorningEvening
endFunction

Int function GetCurrentFishPopulation()

	return currentFishPopulation
endFunction

;-- State -------------------------------------------
auto state Waiting

	function OnActivate(ObjectReference akActivatorRef)
		self.GotoState("busy")
		GetFishingMarker().MoveToMyEditorLocation()
		ObjectReference followerMarker = Game.GetFormFromFile(0x808, "Fish Anywhere.esp") as ObjectReference
		followerMarker.MoveToMyEditorLocation()
		if akActivatorRef == game.GetPlayer() as ObjectReference
			FishingSystem.StartPlayerInteraction(self, false)
		endIf
		self.GotoState("Waiting")
	endFunction
endState

;-- State -------------------------------------------
state busy
endState
