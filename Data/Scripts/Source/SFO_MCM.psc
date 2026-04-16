Scriptname SFO_MCM extends SKI_ConfigBase

GlobalVariable Property FishingCamera Auto

GlobalVariable Property RodHeight Auto
GlobalVariable Property RodHeight_IgnoreRaceChanges Auto
GlobalVariable Property RodHeight_MCM_Rec Auto

GlobalVariable Property BaitReq Auto

Perk Property AnimatedFishing_FurniturePerk Auto

Actor Property PlayerRef Auto

int reco
int BaitReq_B
int RodHeight_s
int Came_M
string Came
int CameIndex = 0
string[] CameList

float RodHeightFloat = 9.0
bool BaitReq_Toggle = True


Event OnConfigInit()
	Pages = new string[1]
	Pages[0] = "Settings"
EndEvent

event OnInit()
	parent.OnInit()
	CameList = new string[3]
	CameList[0] = "Finish in 1st Person"
	CameList[1] = "Return to 3rd Person"
	CameList[2] =  "No Forced Changes"
EndEvent



Event OnPageReset(string page)

	If (page == "")
		
		LoadCustomContent("MCM/MCM_Fishing.dds", 0.0, 0.0)
		Else
		UnloadCustomContent()
	Endif

	If (page == "Settings")
SetCursorFillMode(LEFT_TO_RIGHT)
		AddHeaderOption("Camera Behaviour")
		AddHeaderOption("Bait Requirement")
		AddEmptyOption()
		AddEmptyOption()
		Came_M = AddMenuOption("Camera Mode", CameList[CameIndex])
		BaitReq_B = AddToggleOption("Bait is Required", BaitReq_Toggle)
		AddEmptyOption()
		AddEmptyOption()
		AddHeaderOption("Rod Height Offset")
		AddEmptyOption()
		AddEmptyOption()
		AddEmptyOption()
		RodHeight_s = AddSliderOption("Rod Offset Override:", RodHeightFloat, "{0}")
		Reco = AddTextOption("Recommended Rod Offset",  RodHeight_MCM_Rec.GetValue())
endif
EndEvent


event OnOptionSelect(int option)

If (option == BaitReq_B) && BaitReq_Toggle == True
		BaitReq_Toggle = False
		SetToggleOptionValue(BaitReq_B, BaitReq_Toggle)
		BaitReq.SetValue(0)
		PlayerRef.RemovePerk(AnimatedFishing_FurniturePerk)

	elseif (option == BaitReq_B) && BaitReq_Toggle == False
		BaitReq_Toggle = True
		SetToggleOptionValue(BaitReq_B, BaitReq_Toggle)
		BaitReq.SetValue(1)
		PlayerRef.AddPerk(AnimatedFishing_FurniturePerk)
endif
endevent


event OnOptionSliderOpen(int option)
	if (option == RodHeight_s)
		SetSliderDialogStartValue(RodHeightFloat)
		SetSliderDialogDefaultValue(9)
		SetSliderDialogRange(-20.0, 30.0)
		SetSliderDialogInterval(1)
		endif
endevent


event OnOptionSliderAccept(int option, float value)
	if (option == RodHeight_s)
		RodHeightFloat = value
		RodHeight.SetValue(RodHeightFloat)
		SetSliderOptionValue(RodHeight_S, RodHeightFloat, "{0}")
		RodHeight_IgnoreRaceChanges.SetValue(1)
	endIf
endEvent


event OnOptionMenuOpen(int option)
If (option == Came_M)
		SetMenuDialogOptions(CameList)
		SetMenuDialogStartIndex(cameIndex)
		SetMenuDialogDefaultIndex(1)
endIf
endEvent


event OnOptionMenuAccept(int option, int index)
If  (option == Came_M)
		CameIndex = index
		SetMenuOptionValue(Came_M, CameList[CameIndex])
	if index == 0
FishingCamera.SetValue(0)
	elseif index == 1
FishingCamera.SetValue(1)
	elseif index == 2
FishingCamera.SetValue(2)
	endif
endif
endevent


event OnOptionHighlight(int option) 
if (option == BaitReq_b) 
SetInfoText("Bait is required to fish. Activating each fishing baske gives you\na few 'bait ingredients' for free the first time you interact with them. Default: On.") 
elseif (option == RodHeight_s) 
SetInfoText("Use this to increase or decrease the height at which the rod spawns.\n Changes apply at the beginning of fishing. Higher numbers = Rod spawns closer to the ground.") 
elseif (option == Came_M) 
SetInfoText("How to deal with the final fishing screen - aka, when fish spawns.\nFeel free to experiment. Default: Finish In First Person.")
elseif (option == Reco) 
SetInfoText("The default recommended value for your race. Use it as a guide.")
Endif
EndEvent





