Scriptname SHESON_DynDOLOD_Firstborn extends ObjectReference
;speedrunning is bad mmmkay

ObjectReference MyMaster = None
ObjectReference MyBrother = None
ObjectReference MyBrotherMinion = None
ObjectReference CurrentRef = None
SHESON_DynDOLOD_Master DynMaster = None
String MyWorld = "None"
String MyImportFileName = "None"
Int MyFirstbornList = 0
Int MyMinionList = 0
Int MyCellList = 0
String MyFormID = "None"
Bool MyMasterEnable = FALSE
Bool MyCellDisable = TRUE
Bool MyGridDisable = FALSE

Event onTriggerEnter(objectReference triggerRef)
	if triggerRef == PlayerRef
		if PlayerRef.GetActorValue("SpeedMult") <= 500
			if StorageUtil.GetIntValue(None, "DynDOLOD_Active", 0) == 0
				Utility.Wait(3)
			endif
			if StorageUtil.GetIntValue(None, "DynDOLOD_Checks", 1) || !MyMaster
				MyWorld = StringUtil.SubString(self.GetWorldspace() As String, 13, StringUtil.Find(self.GetWorldspace() As String, "(") - 14)
				if JsonUtil.GetStringValue("DynDOLOD_Worlds", MyWorld, "0")
					MyImportFileName = "DynDOLOD_" + JsonUtil.GetStringValue("DynDOLOD_Worlds", MyWorld, "None")
				        if StorageUtil.GetIntValue(None, "DynDOLOD_Checks", 1)
						if MyImportFileName == "DynDOLOD_None"
							Debug.Notification("DynDOLOD can not read data for " + MyWorld + " from DynDOLOD_Worlds")
							Debug.Trace("DynDOLOD can not read data for " + MyWorld + " (" + self.GetWorldspace() + ") from DynDOLOD_Worlds")
							StorageUtil.SetStringValue(None, "DynDOLOD_Last_Message", "Can not read data for " + MyWorld + " from DynDOLOD_Worlds")
						else
							if JsonUtil.GetStringValue("DynDOLOD_Worlds", "bunchofnumbers", "x") != (Game.GetFormFromFile(0x00000910, JsonUtil.GetStringValue("DynDOLOD_Worlds", "plugin", "DynDOLOD.esp")) As Keyword).GetString() || JsonUtil.GetStringValue("DynDOLOD_Worlds", "bunchofnumbers", "x") != (Game.GetFormFromFile(0x00000910, "DynDOLOD.esp") As Keyword).GetString()
								Debug.Notification("DynDOLOD_Worlds does not belong to these DynDOLOD plugins")
								Debug.Trace("DynDOLOD error: DynDOLOD_Worlds=" + JsonUtil.GetStringValue("DynDOLOD_Worlds", "bunchofnumbers", "x") + " DynDOLOD.esm=" + (Game.GetFormFromFile(0x00000910, JsonUtil.GetStringValue("DynDOLOD_Worlds", "plugin", "DynDOLOD.esp")) As Keyword).GetString() + " DynDOLOD.esp=" + (Game.GetFormFromFile(0x00000910, "DynDOLOD.esp") As Keyword).GetString())
								StorageUtil.SetStringValue(None, "DynDOLOD_Last_Message", "DynDOLOD_Worlds does not belong to these DynDOLOD plugins")
							else
								if JsonUtil.GetStringValue(MyImportFileName, "bunchofnumbers", "x") != (Game.GetFormFromFile(0x00000910, JsonUtil.GetStringValue("DynDOLOD_Worlds", "plugin", "DynDOLOD.esp")) As Keyword).GetString() || JsonUtil.GetStringValue(MyImportFileName, "bunchofnumbers", "x") != (Game.GetFormFromFile(0x00000910, "DynDOLOD.esp") As Keyword).GetString()
							        	if JsonUtil.GetStringValue(MyImportFileName, "bunchofnumbers", "x") == "x"
										Debug.Notification("DynDOLOD can not read data from " + MyImportFileName)
										Debug.Trace("DynDOLOD error: DynDOLOD can not read data from " + MyImportFileName)
										StorageUtil.SetStringValue(None, "DynDOLOD_Last_Message", "Can not read data from " + MyImportFileName)
									else
										Debug.Notification(MyImportFileName + " does not belong to these DynDOLOD plugins")
										Debug.Trace("DynDOLOD error: " + MyImportFileName + "=" + JsonUtil.GetStringValue(MyImportFileName, "bunchofnumbers", "x") + " DynDOLOD.esm=" + (Game.GetFormFromFile(0x00000910, JsonUtil.GetStringValue("DynDOLOD_Worlds", "plugin", "DynDOLOD.esp")) As Keyword).GetString() + " DynDOLOD.esp=" + (Game.GetFormFromFile(0x00000910, "DynDOLOD.esp") As Keyword).GetString())
										StorageUtil.SetStringValue(None, "DynDOLOD_Last_Message", MyImportFileName + " does not belong to these DynDOLOD plugins")
									endIf
								else
									MyImportFileName = "DynDOLOD_" + JsonUtil.GetStringValue("DynDOLOD_Worlds", MyWorld, "None")
					        			if JsonUtil.GetStringValue(MyImportFileName, "bunchofnumbers", "x") != (Game.GetFormFromFile(0x00000910, JsonUtil.GetStringValue("DynDOLOD_Worlds", "plugin", "DynDOLOD.esp")) As Keyword).GetString() || JsonUtil.GetStringValue(MyImportFileName, "bunchofnumbers", "x") != (Game.GetFormFromFile(0x00000910, "DynDOLOD.esp") As Keyword).GetString()
						        			if JsonUtil.GetStringValue(MyImportFileName, "bunchofnumbers", "x") == "x"
											Debug.Notification("DynDOLOD can not read data from " + MyImportFileName)
											Debug.Trace("DynDOLOD can not read data from " + MyImportFileName)
											StorageUtil.SetStringValue(None, "DynDOLOD_Last_Message", "Can not read data from " + MyImportFileName)
										else
											Debug.Notification(MyImportFileName + " does not belong to this these DynDOLOD plugins")
											Debug.Trace("DynDOLOD error: " + MyImportFileName + "=" + JsonUtil.GetStringValue(MyImportFileName, "bunchofnumbers", "x") + " DynDOLOD.esm=" + (Game.GetFormFromFile(0x00000910, JsonUtil.GetStringValue("DynDOLOD_Worlds", "plugin", "DynDOLOD.esp")) As Keyword).GetString() + " DynDOLOD.esp=" + (Game.GetFormFromFile(0x00000910, "DynDOLOD.esp") As Keyword).GetString())
											StorageUtil.SetStringValue(None, "DynDOLOD_Last_Message", MyImportFileName + " does not belong to this these DynDOLOD plugins")
										endIf
									endIf
								endIf
							endIf
						endIf
					endIf
					MyFormID = Math.LogicalAnd(0x00FFFFFF, self.GetFormID()) As String
					if JsonUtil.StringListGet(MyImportFileName, MyFormID, 0)
						MyFirstbornList = StringUtil.SubString(JsonUtil.StringListGet(MyImportFileName, MyFormID, 0), 1, 0) As int
						MyMinionList = StringUtil.SubString(JsonUtil.StringListGet(MyImportFileName, MyFormID, 1), 1, 0) As int
						MyCellList = StringUtil.SubString(JsonUtil.StringListGet(MyImportFileName, MyFormID, 2), 1, 0) As int
						MyMaster = Game.GetFormFromFile(JsonUtil.IntListGet(MyImportFileName, "master", 0), "DynDOLOD.esp") As ObjectReference
						DynMaster = MyMaster As SHESON_DynDOLOD_Master
						StorageUtil.SetIntValue(None, "DynDOLOD_Checks", 0)
					else
						Debug.Notification("DynDOLOD can not read data from " + MyImportFileName)
						Debug.Trace("DynDOLOD can not read data from " + MyImportFileName)
						StorageUtil.SetStringValue(None, "DynDOLOD_Last_Message", "Can not read data from " + MyImportFileName)
					endIf
				else
					Debug.Notification("DynDOLOD can not find " + MyWorld + " in DynDOLOD_Worlds")
					Debug.Trace("DynDOLOD can not find " + MyWorld + " (" + self.GetWorldspace() + ") in DynDOLOD_Worlds")
					StorageUtil.SetStringValue(None, "DynDOLOD_Last_Message", "Can not find " + MyWorld + " in DynDOLOD_Worlds")
				endIf
			endIf
			if MyMaster
				StorageUtil.SetFormValue(MyMaster, "DynDOLOD_MyCurrentFirstborn", self)
				if self.GetDistance(StorageUtil.GetFormValue(MyMaster, "DynDOLOD_MyActiveFirstborn", self) As ObjectReference) <= 8192
					StorageUtil.SetIntValue(MyMaster, "DynDOLOD_MyCurrentDistance", 1)
				else
					float v1 = Utility.GetINIfloat("fTreeLoadDistance:TerrainManager")
					if v1 > 10240
						Utility.SetINIfloat("fTreeLoadDistance:TerrainManager", 0)
						Utility.SetINIfloat("fTreeLoadDistance:TerrainManager", v1)
					endif
					float v2 = Utility.GetINIfloat("fBlockLevel0Distance:TerrainManager")
					if v2 > 10240
						Utility.SetINIfloat("fBlockLevel0Distance:TerrainManager", 0)
						Utility.SetINIfloat("fBlockLevel0Distance:TerrainManager", v2)
					endif
					float v3 = Utility.GetINIfloat("fBlockLevel1Distance:TerrainManager")
					if v3 > 10240
						Utility.SetINIfloat("fBlockLevel1Distance:TerrainManager", 0)
						Utility.SetINIfloat("fBlockLevel1Distance:TerrainManager", v3)
					endif
					float v4 = Utility.GetINIfloat("fBlockMaximumDistance:TerrainManager")
					if v4 > 10240
						Utility.SetINIfloat("fBlockMaximumDistance:TerrainManager", 0)
						Utility.SetINIfloat("fBlockMaximumDistance:TerrainManager", v4)
					endif
					StorageUtil.UnsetIntValue(MyMaster, "DynDOLOD_MyCurrentDistance")
					if StorageUtil.GetIntValue(None, "DynDOLOD_Active", 1) == 1
						Int Index = JsonUtil.IntListCount(MyImportFileName, "c" + MyCellList)
						While Index
							Index -= 1
							CurrentRef = Game.GetFormFromFile(JsonUtil.IntListGet(MyImportFileName, "c" + MyCellList, Index) As Int, "DynDOLOD.esp") As ObjectReference
							if CurrentRef
								if StorageUtil.GetIntValue(CurrentRef, "CellState") == 0 || StorageUtil.GetIntValue(CurrentRef, "GridState") == 0
									StorageUtil.SetIntValue(CurrentRef, "CellState", 1)
									StorageUtil.SetIntValue(CurrentRef, "GridState", 1)
									CurrentRef.Activate(self)
								endIf
							endIf
						endWhile
					endIf
				endIf
				if !MyMasterEnable && (StorageUtil.GetIntValue(None, "DynDOLOD_Active", 1) == 1)
					DynMaster.IBowToTheev2(self, MyFirstbornList, MyMinionList, TRUE, FALSE)
					MyMasterEnable = TRUE
				endIf
			elseif MyMaster.GetState() != "Missing"
				Debug.Notification("DynDOLOD can not find master data in " + MyImportFileName)
				Debug.Trace("DynDOLOD can not find master data in " + MyImportFileName)
				StorageUtil.SetStringValue(None, "DynDOLOD_Last_Message", "Can not find master data in " + MyImportFileName)
			endIf
		endIf
		StorageUtil.SetIntValue(None, "DynDOLOD_CellTriggerCount", StorageUtil.GetIntValue(None, "DynDOLOD_CellTriggerCount", 0) + 1)
	endIf
endEvent

Event onTriggerLeave(objectReference triggerRef)
	if triggerRef == PlayerRef && MyMasterEnable
		MyMasterEnable = FALSE
		if !MyMaster
			MyWorld = StringUtil.SubString(self.GetWorldspace() As String, 13, StringUtil.Find(self.GetWorldspace() As String, "(") - 14)
			MyImportFileName = "DynDOLOD_" + JsonUtil.GetStringValue("DynDOLOD_Worlds", MyWorld, "None")
			MyMaster = Game.GetFormFromFile(JsonUtil.IntListGet(MyImportFileName, "master", 0), "DynDOLOD.esp") As ObjectReference
			DynMaster = MyMaster As SHESON_DynDOLOD_Master
			MyFormID = Math.LogicalAnd(0x00FFFFFF, self.GetFormID()) As String
			MyFirstbornList = StringUtil.SubString(JsonUtil.StringListGet(MyImportFileName, MyFormID, 0), 1, 0) As int
			MyMinionList = StringUtil.SubString(JsonUtil.StringListGet(MyImportFileName, MyFormID, 1), 1, 0) As int
			MyCellList = StringUtil.SubString(JsonUtil.StringListGet(MyImportFileName, MyFormID, 2), 1, 0) As int
		endIf
		if MyMaster
			if StorageUtil.GetFormValue(MyMaster, "DynDOLOD_MyActiveFirstborn", None) == self
				Utility.Wait(3)
			endIf
			if StorageUtil.GetFormValue(MyMaster, "DynDOLOD_MyActiveFirstborn", None) == self
				; cell attach can happen because of wait
				if self.GetParentCell()
					if !self.GetParentCell().IsAttached()
						DynMaster.IBowToTheev2(self, MyFirstbornList, MyMinionList, FALSE, FALSE)
					endIf
				else
					DynMaster.IBowToTheev2(self, MyFirstbornList, MyMinionList, FALSE, FALSE)
				endIf
			endIf
		endIf
	endIf
endEvent

Event OnCellAttach()
	if Math.LogicalAnd(0x00FFFFFF, self.GetBaseObject().GetFormID()) == 0x00000903
		if PlayerRef.GetActorValue("SpeedMult") <= 500
			if StorageUtil.GetIntValue(None, "DynDOLOD_Active", 0) == 0
				Utility.Wait(2)
			endIf
			if StorageUtil.GetIntValue(None, "DynDOLOD_Active", 1) == 1
				if StorageUtil.GetIntValue(self, "CellState") == 0 || StorageUtil.GetIntValue(self, "GridState") == 0
					StorageUtil.SetIntValue(self, "CellState", 1)
					StorageUtil.SetIntValue(self, "GridState", 1)
					Activate(self)
				endIf
			endIf
		endIf
	else
		if !MyMaster
			if StorageUtil.GetIntValue(None, "DynDOLOD_Active", 0) == 0
				Utility.Wait(2)
			endif
			MyWorld = StringUtil.SubString(self.GetWorldspace() As String, 13, StringUtil.Find(self.GetWorldspace() As String, "(") - 14)
			MyImportFileName = "DynDOLOD_" + JsonUtil.GetStringValue("DynDOLOD_Worlds", MyWorld, "None")
			MyMaster = Game.GetFormFromFile(JsonUtil.IntListGet(MyImportFileName, "master", 0), "DynDOLOD.esp") As ObjectReference
			DynMaster = MyMaster As SHESON_DynDOLOD_Master
			MyFormID = Math.LogicalAnd(0x00FFFFFF, self.GetFormID()) As String
			MyFirstbornList = StringUtil.SubString(JsonUtil.StringListGet(MyImportFileName, MyFormID, 0), 1, 0) As int
			MyMinionList = StringUtil.SubString(JsonUtil.StringListGet(MyImportFileName, MyFormID, 1), 1, 0) As int
			MyCellList = StringUtil.SubString(JsonUtil.StringListGet(MyImportFileName, MyFormID, 2), 1, 0) As int
			StorageUtil.SetIntValue(None, "DynDOLOD_UniqueCellAttachCount", StorageUtil.GetIntValue(None, "DynDOLOD_UniqueCellAttachCount", 0) + 1)
		endIf
		if MyMaster && PlayerRef.GetActorValue("SpeedMult") <= 500 && StorageUtil.GetIntValue(None, "DynDOLOD_Active", 1) == 1
			MyBrother = Game.GetFormFromFile(JsonUtil.IntListGet(MyImportFileName, MyFormID, 0), "DynDOLOD.esp") As ObjectReference
			if !MyBrother
				if (StorageUtil.GetIntValue(None, "DynDOLOD_LargeRefFix", JsonUtil.GetIntValue("DynDOLOD_Worlds", "largereffix", 0)) == 0 || JsonUtil.GetIntValue(MyImportFileName, "largereffix", 0) == 0) && (StorageUtil.GetIntValue(self, "CellState") == 0 || StorageUtil.GetIntValue(self, "GridState") == 0)
					StorageUtil.SetIntValue(self, "CellState", 1)
					StorageUtil.SetIntValue(self, "GridState", 1)
					Activate(self)
				endIf
			else
				if (StorageUtil.GetIntValue(None, "DynDOLOD_LargeRefFix", JsonUtil.GetIntValue("DynDOLOD_Worlds", "largereffix", 0)) == 0 || JsonUtil.GetIntValue(MyImportFileName, "largereffix", 0) == 0) && (StorageUtil.GetIntValue(MyBrother, "CellState") == 0 || StorageUtil.GetIntValue(MyBrother, "GridState") == 0)
					StorageUtil.SetIntValue(MyBrother, "CellState", 1)
					StorageUtil.SetIntValue(MyBrother, "GridState", 1)
					MyBrother.Activate(self)
				endIf
				MyBrotherMinion = Game.GetFormFromFile(JsonUtil.IntListGet(MyImportFileName, MyFormID, 1), "DynDOLOD.esp") As ObjectReference
				if MyBrotherMinion && (StorageUtil.GetIntValue(MyBrotherMinion, "CellState") == 0 || StorageUtil.GetIntValue(MyBrotherMinion, "GridState") == 0)
					StorageUtil.SetIntValue(MyBrotherMinion, "CellState", 1)
					StorageUtil.SetIntValue(MyBrotherMinion, "GridState", 1)
					MyBrotherMinion.Activate(self)
				endIf
			endIf
		endIf
		StorageUtil.SetIntValue(None, "DynDOLOD_GlobalCellAttachCount", StorageUtil.GetIntValue(None, "DynDOLOD_GlobalCellAttachCount", 0) + 1)
	endIf
endEvent

Event OnCellDetach()
	Worldspace PlayerWorldspace = PlayerRef.GetWorldspace()
	if Math.LogicalAnd(0x00FFFFFF, self.GetBaseObject().GetFormID()) == 0x00000903
		if StorageUtil.GetIntValue(self, "CellState") == 1
			if PlayerWorldspace
				if self.GetDistance(PlayerRef) > 20480
					Float f1 = math.abs(self.GetPositionX() - PlayerRef.GetPositionX())
					Float f2 = math.abs(self.GetPositionY() - PlayerRef.GetPositionY())
					if f1 > JsonUtil.GetFloatValue("DynDOLOD_Worlds", "NearGrid", 22528) && f2 > JsonUtil.GetFloatValue("DynDOLOD_Worlds", "NearGrid", 22528)
						StorageUtil.UnsetIntValue(self, "GridState")
					endIf
				endIf
				if self.GetWorldSpace() != PlayerWorldspace
					Float f1 = math.abs(self.GetPositionX() - PlayerRef.GetPositionX())
					Float f2 = math.abs(self.GetPositionY() - PlayerRef.GetPositionY())
					if f1 <= JsonUtil.GetFloatValue("DynDOLOD_Worlds", "uGrid", 10240) && f2 <= JsonUtil.GetFloatValue("DynDOLOD_Worlds", "uGrid", 10240)
						;StorageUtil.SetIntValue(self, "CellState", 1)
					else
						StorageUtil.UnsetIntValue(self, "CellState")
					endIf
				else
					StorageUtil.UnsetIntValue(self, "CellState")
				endIf
				Activate(self)
			endIf
		endIf
	else
		if PlayerWorldspace
			if self.GetDistance(PlayerRef) > JsonUtil.GetFloatValue("DynDOLOD_Worlds", "FarGrid", 43008)
				Float f1 = math.abs(self.GetPositionX() - PlayerRef.GetPositionX())
				Float f2 = math.abs(self.GetPositionY() - PlayerRef.GetPositionY())
				if f1 > JsonUtil.GetFloatValue("DynDOLOD_Worlds", "FarGrid", 43008) && f2 > JsonUtil.GetFloatValue("DynDOLOD_Worlds", "FarGrid", 43008)
					MyGridDisable = TRUE
				else
					MyGridDisable = FALSE
				endIf
			else
				MyGridDisable = FALSE
			endIf
			if self.GetWorldSpace() != PlayerWorldspace
				Float f1 = math.abs(self.GetPositionX() - PlayerRef.GetPositionX())
				Float f2 = math.abs(self.GetPositionY() - PlayerRef.GetPositionY())
				if f1 <= JsonUtil.GetFloatValue("DynDOLOD_Worlds", "uGrid", 10240) && f2 <= JsonUtil.GetFloatValue("DynDOLOD_Worlds", "uGrid", 10240)
					MyCellDisable = FALSE
				else
					MyCellDisable = TRUE
			endIf
			else
				MyCellDisable = TRUE
			endIf
			if !MyBrother
				if (StorageUtil.GetIntValue(None, "DynDOLOD_LargeRefFix", JsonUtil.GetIntValue("DynDOLOD_Worlds", "largereffix", 0)) == 0 || JsonUtil.GetIntValue(MyImportFileName, "largereffix", 0) == 0) && StorageUtil.GetIntValue(self, "CellState") == 1
					if MyCellDisable
						StorageUtil.UnsetIntValue(self, "CellState")
					endIf
					if MyGridDisable
						StorageUtil.UnsetIntValue(self, "GridState")
					endIf
					Activate(self)
				endIf
			else
				if (StorageUtil.GetIntValue(None, "DynDOLOD_LargeRefFix", JsonUtil.GetIntValue("DynDOLOD_Worlds", "largereffix", 0)) == 0 || JsonUtil.GetIntValue(MyImportFileName, "largereffix", 0) == 0) && StorageUtil.GetIntValue(MyBrother, "CellState") == 1
					if MyCellDisable
						StorageUtil.UnsetIntValue(MyBrother, "CellState")
					endIf
					if MyGridDisable
						StorageUtil.UnsetIntValue(MyBrother, "GridState")
					endIf
					MyBrother.Activate(self)
				endIf
				if MyBrotherMinion && StorageUtil.GetIntValue(MyBrotherMinion, "CellState") == 1
					if MyCellDisable
						StorageUtil.UnsetIntValue(MyBrotherMinion, "CellState")
					endIf
					if MyGridDisable
						StorageUtil.UnsetIntValue(MyBrotherMinion, "GridState")
					endIf
					MyBrotherMinion.Activate(self)
				endIf
			endIf
		endIf
		if MyMasterEnable
			MyMasterEnable = FALSE
			if !MyMaster
				MyWorld = StringUtil.SubString(self.GetWorldspace() As String, 13, StringUtil.Find(self.GetWorldspace() As String, "(") - 14)
				MyImportFileName = "DynDOLOD_" + JsonUtil.GetStringValue("DynDOLOD_Worlds", MyWorld, "None")
				MyMaster = Game.GetFormFromFile(JsonUtil.IntListGet(MyImportFileName, "master", 0), "DynDOLOD.esp") As ObjectReference
				DynMaster = MyMaster As SHESON_DynDOLOD_Master
				MyFormID = Math.LogicalAnd(0x00FFFFFF, self.GetFormID()) As String
				MyFirstbornList = StringUtil.SubString(JsonUtil.StringListGet(MyImportFileName, MyFormID, 0), 1, 0) As int
				MyMinionList = StringUtil.SubString(JsonUtil.StringListGet(MyImportFileName, MyFormID, 1), 1, 0) As int
				MyCellList = StringUtil.SubString(JsonUtil.StringListGet(MyImportFileName, MyFormID, 2), 1, 0) As int
			endIf
			if MyMaster
				if StorageUtil.GetFormValue(MyMaster, "DynDOLOD_MyActiveFirstborn", None) == self
					Utility.Wait(3)
				endIf
				if StorageUtil.GetFormValue(MyMaster, "DynDOLOD_MyActiveFirstborn", None) == self
					; cell attach can happen because of wait
					if self.GetParentCell()
						if !self.GetParentCell().IsAttached()
							DynMaster.IBowToTheev2(self, MyFirstbornList, MyMinionList, FALSE, FALSE)
						endIf
					else
						DynMaster.IBowToTheev2(self, MyFirstbornList, MyMinionList, FALSE, FALSE)
					endIf
				endIf
			endIf
		endIf
	endIf
endEvent

Actor Property PlayerRef Auto
