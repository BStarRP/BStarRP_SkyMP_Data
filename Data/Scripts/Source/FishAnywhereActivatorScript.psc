Scriptname FishAnywhereActivatorScript extends ObjectReference  

event OnInit()
	FishAnywhereTester.MoveTo(self)
	FishAnywhereTester.MoveTo(self)
	Utility.Wait(0.1)
	bool isWater = PO3_SKSEFunctions.IsActorInWater(FishAnywhereTester)
	if !isWater
		FishAnywhereTester.MoveToMyEditorLocation()
		PlayerAlias.TestWaterFailure()
	else
		Utility.Wait(0.2)
		bool isDamage = FishAnywhereTester.GetAVPercentage("Health") < 1
		FishAnywhereTester.MoveToMyEditorLocation()
		if isDamage
			PlayerAlias.TestWaterFailure()
		else
			PlayerAlias.TestWaterSuccess()
		endIf
	endIf
endEvent

Actor Property FishAnywhereTester Auto
FishAnywhereAliasScript Property PlayerAlias Auto