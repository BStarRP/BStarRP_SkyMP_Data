Scriptname SHESON_DynDOLOD_Worshipper extends ObjectReference
; Having to jump through fiery hoops because of game breaking bugs and scripting inconsistencies

ObjectReference MyMaster = None
ObjectReference MyFirstBorn = None
ObjectReference MyBrother = None
String MyWorld = "None"
String MyImportFileName = "None"
String MyFormID = "None"
String MyFirstBornFormID = "None"
Bool MyCellDisable = TRUE
Bool MyGridDisable = FALSE

Event OnCellAttach()
	if StorageUtil.GetIntValue(None, "DynDOLOD_LargeRefFix", JsonUtil.GetIntValue("DynDOLOD_Worlds", "largereffix", 0)) == 1
		if !MyMaster
			if StorageUtil.GetIntValue(None, "DynDOLOD_Active", 0) == 0
				Utility.Wait(3)
			endif
			MyWorld = StringUtil.SubString(self.GetWorldspace() As String, 13, StringUtil.Find(self.GetWorldspace() As String, "(") - 14)
			MyImportFileName = "DynDOLOD_" + JsonUtil.GetStringValue("DynDOLOD_Worlds", MyWorld, "None") As String
			MyMaster = Game.GetFormFromFile(JsonUtil.IntListGet(MyImportFileName, "master", 0), "DynDOLOD.esp") As ObjectReference
			MyFormID = Math.LogicalAnd(0x00FFFFFF, self.GetFormID()) As String
			MyFirstBorn = Game.GetFormFromFile(JsonUtil.IntListGet(MyImportFileName, "w" + MyFormID, 0), "DynDOLOD.esp") As ObjectReference
			MyFirstBornFormID = Math.LogicalAnd(0x00FFFFFF, MyFirstBorn.GetFormID()) As String
		endIf
		if MyMaster && PlayerRef.GetActorValue("SpeedMult") <= 500 && StorageUtil.GetIntValue(None, "DynDOLOD_Active", 1) == 1 && JsonUtil.GetIntValue(MyImportFileName, "largereffix", 0) == 1
			MyBrother = Game.GetFormFromFile(JsonUtil.IntListGet(MyImportFileName, MyFirstBornFormID, 0), "DynDOLOD.esp") As ObjectReference
			if !MyBrother
				StorageUtil.SetFormValue(MyFirstBorn, "Loaded", MyFirstBorn)
				if StorageUtil.GetIntValue(MyFirstBorn, "CellState") == 0 || StorageUtil.GetIntValue(MyFirstBorn, "GridState") == 0
					;debug.trace(self + " attach " + MyFirstBorn + " " + PlayerRef.GetWorldspace() + " " + self.GetWorldspace() + " " + MyFirstBorn.GetWorldspace())
					StorageUtil.SetIntValue(MyFirstBorn, "CellState", 1)
					StorageUtil.SetIntValue(MyFirstBorn, "GridState", 1)
					MyFirstBorn.Activate(MyFirstBorn)
				endIf
			else
				StorageUtil.SetFormValue(MyBrother, "Loaded", MyFirstBorn)
				if StorageUtil.GetIntValue(MyBrother, "CellState") == 0 || StorageUtil.GetIntValue(MyBrother, "GridState") == 0
					;debug.trace(self + " attach " + MyBrother + " -> " + MyFirstBorn + " " + PlayerRef.GetWorldspace() + " " + self.GetWorldspace() + " " + MyFirstBorn.GetWorldspace())
					StorageUtil.SetIntValue(MyBrother, "CellState", 1)
					StorageUtil.SetIntValue(MyBrother, "GridState", 1)
					MyBrother.Activate(MyFirstBorn)
				endIf
			endIf
		endIf
	endIf
endEvent

Event OnLoad()
	if StorageUtil.GetIntValue(None, "DynDOLOD_LargeRefFix", JsonUtil.GetIntValue("DynDOLOD_Worlds", "largereffix", 0)) == 1
		if !MyMaster
			if StorageUtil.GetIntValue(None, "DynDOLOD_Active", 0) == 0
				Utility.Wait(3)
			endif
			MyWorld = StringUtil.SubString(self.GetWorldspace() As String, 13, StringUtil.Find(self.GetWorldspace() As String, "(") - 14)
			MyImportFileName = "DynDOLOD_" + JsonUtil.GetStringValue("DynDOLOD_Worlds", MyWorld, "None") As String
			MyMaster = Game.GetFormFromFile(JsonUtil.IntListGet(MyImportFileName, "master", 0), "DynDOLOD.esp") As ObjectReference
			MyFormID = Math.LogicalAnd(0x00FFFFFF, self.GetFormID()) As String
			MyFirstBorn = Game.GetFormFromFile(JsonUtil.IntListGet(MyImportFileName, "w" + MyFormID, 0), "DynDOLOD.esp") As ObjectReference
			MyFirstBornFormID = Math.LogicalAnd(0x00FFFFFF, MyFirstBorn.GetFormID()) As String
		endIf
		if MyMaster && PlayerRef.GetActorValue("SpeedMult") <= 500 && StorageUtil.GetIntValue(None, "DynDOLOD_Active", 1) == 1 && JsonUtil.GetIntValue(MyImportFileName, "largereffix", 0) == 1
			MyBrother = Game.GetFormFromFile(JsonUtil.IntListGet(MyImportFileName, MyFirstBornFormID, 0), "DynDOLOD.esp") As ObjectReference
			if !MyBrother
				if StorageUtil.GetFormValue(MyFirstBorn, "Loaded", MyFirstBorn) != MyFirstBorn
					;debug.trace(self + " -wait1- " + StorageUtil.GetFormValue(MyFirstBorn, "Loaded", MyFirstBorn) + " =" + MyFirstBorn)
					Utility.Wait(1)
				endIf
				StorageUtil.SetFormValue(MyFirstBorn, "Loaded", MyFirstBorn)
				if StorageUtil.GetIntValue(MyFirstBorn, "CellState") == 0 || StorageUtil.GetIntValue(MyFirstBorn, "GridState") == 0
					;debug.trace(self + " load #3 " + MyFirstBorn + " " + PlayerRef.GetWorldspace() + " " + self.GetWorldspace() + " " + MyFirstBorn.GetWorldspace())
					StorageUtil.SetIntValue(MyFirstBorn, "CellState", 1)
					StorageUtil.SetIntValue(MyFirstBorn, "GridState", 1)
					MyFirstBorn.Activate(MyFirstBorn)
				endIf
			else
				if StorageUtil.GetFormValue(MyBrother, "Loaded", MyFirstBorn) != MyFirstBorn
					;debug.trace(self + " -wait2- " + StorageUtil.GetFormValue(MyBrother, "Loaded", MyFirstBorn) + " =" + MyFirstBorn)
					Utility.Wait(1)
				endIf
				StorageUtil.SetFormValue(MyBrother, "Loaded", MyFirstBorn)
				if StorageUtil.GetIntValue(MyBrother, "CellState") == 0 || StorageUtil.GetIntValue(MyBrother, "GridState") == 0
					;debug.trace(self + " load " + MyBrother + " -> " + MyFirstBorn + " " + MyBrother.IsActivationBlocked() + " " + PlayerRef.GetWorldspace() + " " + self.GetWorldspace() + " " + MyFirstBorn.GetWorldspace())
					StorageUtil.SetIntValue(MyBrother, "CellState", 1)
					StorageUtil.SetIntValue(MyBrother, "GridState", 1)
					MyBrother.Activate(MyFirstBorn)
				endIf
			endIf
		endIf
	endIf
endEvent

Event OnUnLoad()
	if StorageUtil.GetIntValue(None, "DynDOLOD_LargeRefFix", JsonUtil.GetIntValue("DynDOLOD_Worlds", "largereffix", 0)) == 1 && JsonUtil.GetIntValue(MyImportFileName, "largereffix", 0) == 1
		Worldspace PlayerWorldspace = PlayerRef.GetWorldspace()
		if PlayerWorldspace
			if MyFirstBorn.GetDistance(PlayerRef) > JsonUtil.GetFloatValue("DynDOLOD_Worlds", "FarGrid", 43008)
				Float f1 = math.abs(MyFirstBorn.GetPositionX() - PlayerRef.GetPositionX())
				Float f2 = math.abs(MyFirstBorn.GetPositionY() - PlayerRef.GetPositionY())
				if f1 > JsonUtil.GetFloatValue("DynDOLOD_Worlds", "FarGrid", 43008) && f2 > JsonUtil.GetFloatValue("DynDOLOD_Worlds", "FarGrid", 43008)
					MyGridDisable = TRUE
				else
					MyGridDisable = FALSE
				endIf
			else
				MyGridDisable = FALSE
			endIf
			if MyFirstBorn.GetWorldSpace() != PlayerWorldspace
				Float f1 = math.abs(MyFirstBorn.GetPositionX() - PlayerRef.GetPositionX())
				Float f2 = math.abs(MyFirstBorn.GetPositionY() - PlayerRef.GetPositionY())
				if f1 <= JsonUtil.GetFloatValue("DynDOLOD_Worlds", "uLargeGrid", 14336) && f2 <= JsonUtil.GetFloatValue("DynDOLOD_Worlds", "uLargeGrid", 14336)
					MyCellDisable = FALSE
				else
					MyCellDisable = TRUE
				endIf
			else
				MyCellDisable = TRUE
			endIf
			if !MyBrother
				if StorageUtil.GetIntValue(MyFirstBorn, "CellState") == 1
					;debug.trace(self + " unload " + MyFirstBorn + " " + MyGridDisable + " " +  MyCellDisable + " " + PlayerRef.GetWorldspace() + " NONE " + MyFirstBorn.GetWorldspace())
					if MyCellDisable
						StorageUtil.UnsetIntValue(MyFirstBorn, "CellState")
					endIf
					if MyGridDisable
						StorageUtil.UnsetIntValue(MyFirstBorn, "GridState")
					endIf
					MyFirstBorn.Activate(MyFirstBorn)
				endIf
				StorageUtil.UnsetFormValue(MyFirstBorn, "Loaded")
			else
				if StorageUtil.GetIntValue(MyBrother, "CellState") == 1
					;debug.trace(self + " unload " + MyBrother + " -> " + MyFirstBorn + " " + MyBrother.IsActivationBlocked() + MyGridDisable + " " +  MyCellDisable + " " + PlayerRef.GetWorldspace() + " NONE " + MyFirstBorn.GetWorldspace())
					if MyCellDisable
						StorageUtil.UnsetIntValue(MyBrother, "CellState")
					endIf
					if MyGridDisable
						StorageUtil.UnsetIntValue(MyBrother, "GridState")
					endIf
					MyBrother.Activate(MyFirstBorn)
				endIf
				StorageUtil.UnsetFormValue(MyBrother, "Loaded")
			endIf
		endIf
	endIf
endEvent

Actor Property PlayerRef Auto
