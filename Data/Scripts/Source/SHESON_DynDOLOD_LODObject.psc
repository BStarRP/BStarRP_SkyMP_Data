Scriptname SHESON_DynDOLOD_LODObject extends ObjectReference
;Switching "states" with one activtor parent
;Firstborn may be a Minion

ObjectReference MyMaster = None
Actor PlayerRef = None
String MyWorld = "None"
String MyImportFileName = "None"
Int SafetyCounter = 0
String MyFormID = "None"
Float MyMultiple = -1.0
Bool MyEnabled = FALSE
Bool MyFirstbornState = FALSE
Bool MyAttached = FALSE
Bool MySelfDisable = FALSE
Bool MyDeBounce = FALSE

Event OnActivate(ObjectReference akActionRef)
	; safety check in case people do not RTFM
	if !MyMaster || !JsonUtil.StringListCount(MyImportFileName, MyFormID)
		PlayerRef = Game.GetForm(0x00000014) As Actor
		if MyWorldspace == None
			MyWorldspace = self.GetWorldspace()
		endIf
		if StorageUtil.GetIntValue(None, "DynDOLOD_Active", 0) == 0
			Utility.Wait(3)
		endif
		MyWorld = JsonUtil.GetStringValue("DynDOLOD_Worlds", StringUtil.SubString(MyWorldspace As String, 13, StringUtil.Find(MyWorldspace As String, "(") - 14), StringUtil.SubString(MyWorldspace As String, 13, StringUtil.Find(MyWorldspace As String, "(") - 14))
		MyMaster = Game.GetFormFromFile(JsonUtil.IntListGet("DynDOLOD_" + MyWorld, "master", 0), "DynDOLOD.esp") As ObjectReference
		MyFormID = Math.LogicalAnd(0x00FFFFFF, self.GetFormID()) As String
		MyImportFileName = "DynDOLOD_" + MyWorld + "_Objects"
	endIf
	Worldspace PlayerWorldspace = PlayerRef.GetWorldspace()
	Worldspace akActionWorldspace = akActionRef.GetWorldspace()
	if !MySelfDisable && (MyFirstbornState || (StorageUtil.GetIntValue(akActionRef, "GridState") == 1))
		if self.IsDisabled() && MyEnabled && MyAttached && (StorageUtil.GetIntValue(akActionRef, "GridState") == 1) && (StorageUtil.GetIntValue(akActionRef, "CellState") == 0) && (akActionWorldspace == PlayerWorldspace) && (StorageUtil.GetIntValue(None, "DynDOLOD_Active", 0) != 0)
			if JsonUtil.GetStringValue("DynDOLOD_Worlds", "debug", "false") == "true" || JsonUtil.GetStringValue("DynDOLOD_Worlds", "debug", "false") == MyFormID
				debug.trace(self + " " + akActionRef + " Enable #1 " + self.GetBaseObject() + " using " + self.GetBaseObject().GetWorldModelPath())
			endIf
			self.EnableNoWait(FALSE)
		elseif !MyAttached && (StorageUtil.GetIntValue(akActionRef, "CellState") == 1) && !StorageUtil.GetIntValue(MyMaster, "DynDOLOD_MyCurrentDistance", 1) && ((JsonUtil.StringListGet(MyImportFileName, MyFormID, 3) && (akActionWorldspace == PlayerWorldspace)) || (JsonUtil.StringListGet(MyImportFileName, MyFormID, 10) && (akActionWorldspace != PlayerWorldspace)))
			if !self.IsDisabled()
				;if JsonUtil.GetStringValue("DynDOLOD_Worlds", "debug", "false") == "true" || JsonUtil.GetStringValue("DynDOLOD_Worlds", "debug", "false") == MyFormID
				;	debug.trace(self + " " + akActionRef + " Disable #1 " + self.GetBaseObject() + " using " + self.GetBaseObject().GetWorldModelPath())
				;endIf
				self.DisableNoWait(FALSE)
			EndIf
		endIf
	endIf
	if self && akActionRef && MyMaster && JsonUtil.StringListCount(MyImportFileName, MyFormID)
		if JsonUtil.StringListGet(MyImportFileName, MyFormID, 11) && Math.LogicalAnd(0x00FFFFFF, self.GetBaseObject().GetFormID()) == 0x00000903
			if StorageUtil.GetIntValue(none, "DynDOLOD_UseNiOverride", 0)
				if StorageUtil.GetIntValue(akActionRef, "GridState") == 0
					MyMultiple = StorageUtil.GetFloatValue(none, "DynDOLOD_FarMultiple", JsonUtil.GetFloatValue("DynDOLOD_Worlds", "FarMultiple", 1.5))
				else
					MyMultiple = StorageUtil.GetFloatValue(none, "DynDOLOD_NearMultiple", JsonUtil.GetFloatValue("DynDOLOD_Worlds", "NearMultiple", 1.25))
				endIf
			endIf
		else
			if JsonUtil.StringListGet(MyImportFileName, MyFormID, 11) && StorageUtil.GetIntValue(none, "DynDOLOD_UseNiOverride", 0) != 0
				if StorageUtil.GetIntValue(akActionRef, "GridState") == 0
					MyMultiple = StorageUtil.GetFloatValue(none, "DynDOLOD_NeverMultiple", JsonUtil.GetFloatValue("DynDOLOD_Worlds", "NeverMultiple", 1.75))
				elseif MyFirstbornState || MyAttached || (StorageUtil.GetIntValue(akActionRef, "CellState") == 1)
					MyMultiple = StorageUtil.GetFloatValue(none, "DynDOLOD_NearMultiple", JsonUtil.GetFloatValue("DynDOLOD_Worlds", "NearMultiple", 1.25))
				else
					MyMultiple = StorageUtil.GetFloatValue(none, "DynDOLOD_FarMultiple", JsonUtil.GetFloatValue("DynDOLOD_Worlds", "FarMultiple", 1.5))
				endIf
			endIf

			; is there an enable parent form id and is its mod loaded
			if JsonUtil.StringListGet(MyImportFileName, MyFormID, 5) && Game.GetModByName(JsonUtil.StringListGet(MyImportFileName, MyFormID, 6)) != 255
		        	; enable parent may not be persistant, so do this tricky thing
				ObjectReference MyEnableParent = Game.GetFormFromFile(JsonUtil.StringListGet(MyImportFileName, MyFormID, 5) as int, JsonUtil.StringListGet(MyImportFileName, MyFormID, 6)) As ObjectReference
				int OpenState = 0
				; enabled or disabled that is the question
				if MyEnableParent && MyEnableParent != self
					MyEnabled = !MyEnableParent.IsDisabled()
					if JsonUtil.StringListGet(MyImportFileName, MyFormID, 3) && (JsonUtil.StringListGet(MyImportFileName, MyFormID, 7) As int == -2 || (self.GetBaseObject().GetType() == 24 || self.GetBaseObject().GetType() == 36 || self.GetBaseObject().GetType() == 25))
						ObjectReference MyObject = Game.GetFormFromFile(JsonUtil.StringListGet(MyImportFileName, MyFormID, 12) As int, JsonUtil.StringListGet(MyImportFileName, MyFormID, 13)) As ObjectReference
						if MyObject && !MyObject.IsDisabled()
							self.SetAngle(MyObject.GetAngleX(), MyObject.GetAngleY(), MyObject.GetAngleZ())
							self.SetPosition(MyObject.GetPositionX(), MyObject.GetPositionY(), MyObject.GetPositionZ())
							self.SetScale(MyObject.GetScale())
						endIf
						MyObject = None
					endIf
					if self.GetBaseObject().GetType() == 29
						OpenState = MyEnableParent.GetOpenState()
					endIf
					MyEnableParent = None
					if JsonUtil.StringListGet(MyImportFileName, MyFormID, 8) As int > -1
						ObjectReference MyObject = Game.GetFormFromFile(JsonUtil.StringListGet(MyImportFileName, MyFormID, 12) As int, JsonUtil.StringListGet(MyImportFileName, MyFormID, 13)) As ObjectReference
						if MyObject && MyObject.GetCurrentDestructionStage()
							; destruction model
							if JsonUtil.StringListGet(MyImportFileName, MyFormID, 8) As int == 1 && MyObject.GetCurrentDestructionStage() >= JsonUtil.StringListGet(MyImportFileName, MyFormID, 7) As int
								MyEnabled = TRUE
							endif
							; default model
							if JsonUtil.StringListGet(MyImportFileName, MyFormID, 8) As int == 0 && MyObject.GetCurrentDestructionStage() >= JsonUtil.StringListGet(MyImportFileName, MyFormID, 7) As int
								MyEnabled = FALSE
							endif
						endIf
						MyObject = None
					endIf
				else
					MyEnabled = JsonUtil.StringListGet(MyImportFileName, MyFormID, 2)
				endIf
				MyEnableParent = None
				if JsonUtil.StringListGet(MyImportFileName, MyFormID, 4)
					MyEnabled = !MyEnabled
				endIf
				if akActionRef
					if StorageUtil.GetIntValue(akActionRef, "GridState") == 0 && JsonUtil.StringListGet(MyImportFileName, MyFormID, 0)
						MyFirstbornState = FALSE
					else
						MyFirstbornState = TRUE
					endIf
					if StorageUtil.GetIntValue(akActionRef, "CellState") == 0
						MyAttached = FALSE
					else
						if (JsonUtil.StringListGet(MyImportFileName, MyFormID, 3) && akActionWorldspace == PlayerWorldspace) || (JsonUtil.StringListGet(MyImportFileName, MyFormID, 10) && akActionWorldspace != PlayerWorldspace)
							MyAttached = TRUE
						else
							MyAttached = FALSE
						endIf
					endIf
				endIf
				; change visibility
				if MyEnabled && !MyAttached && MyFirstbornState
					if self && self.IsDisabled()
						if JsonUtil.GetStringValue("DynDOLOD_Worlds", "debug", "false") == "true" || JsonUtil.GetStringValue("DynDOLOD_Worlds", "debug", "false") == MyFormID
							debug.trace(self + " " + akActionRef + " Enable #2 " + self.GetBaseObject() + " using " + self.GetBaseObject().GetWorldModelPath() + " " + MyEnabled + " " + MyAttached + " " + MyFirstbornState)
						endIf
						self.EnableNoWait(FALSE)
					endIf
				elseif !self.IsDisabled()
					if self && StorageUtil.GetIntValue(MyMaster, "DynDOLOD_MyCurrentDistance", 0)
						if MyAttached && JsonUtil.StringListGet(MyImportFileName, MyFormID, 1) && (akActionWorldspace == PlayerWorldspace)
							Utility.Wait(1)
						endIf
						if MyFirstbornState && JsonUtil.StringListGet(MyImportFileName, MyFormID, 9) && ((StorageUtil.GetFormValue(MyMaster, "DynDOLOD_MyActiveFirstborn", self) As ObjectReference).GetWorldSpace() == PlayerWorldspace)
							Utility.Wait(0.333)
							;if JsonUtil.GetStringValue("DynDOLOD_Worlds", "debug", "false") == "true" || JsonUtil.GetStringValue("DynDOLOD_Worlds", "debug", "false") == MyFormID
							;	debug.trace(self + " " + akActionRef + " Disable #2 " + self.GetBaseObject() + " using " + self.GetBaseObject().GetWorldModelPath())
							;endIf
							self.Disable(TRUE)
							Utility.Wait(0.1)
						endIf
					endIf
					SafetyCounter = 10
					while self && !self.IsDisabled() && SafetyCounter
						if MyEnabled && !MyAttached && MyFirstbornState
							SafetyCounter = 0
						else
							;if JsonUtil.GetStringValue("DynDOLOD_Worlds", "debug", "false") == "true" || JsonUtil.GetStringValue("DynDOLOD_Worlds", "debug", "false") == MyFormID
							;	debug.trace(self + " " + akActionRef + " Disable #3 " + SafetyCounter + " " + self.GetBaseObject() + " using " + self.GetBaseObject().GetWorldModelPath())
							;endIf
							self.DisableNoWait(FALSE)
							SafetyCounter -= 1
							if self && (SafetyCounter > 0)
								Utility.Wait(3)
							EndIf
						endIf
					endWhile
				endIf
				if self.GetBaseObject().GetType() == 29
					SafetyCounter = 10
					while self && SafetyCounter && (OpenState != self.GetOpenState())
						if OpenState == 1 || OpenState == 2
							self.SetOpen(TRUE)
						else
							self.SetOpen(FALSE)
						endIf
						Utility.Wait(1)
						SafetyCounter -= 1
					endWhile
				else
					self.SetOpen(FALSE)
				endIf
			else
				if !self.IsDisabled()
					;if JsonUtil.GetStringValue("DynDOLOD_Worlds", "debug", "false") == "true" || JsonUtil.GetStringValue("DynDOLOD_Worlds", "debug", "false") == MyFormID
					;	debug.trace(self + " " + akActionRef + " Disable #4 " + self.GetBaseObject() + " using " + self.GetBaseObject().GetWorldModelPath())
					;endIf
					self.DisableNoWait(FALSE)
				endIf
			endIf
		endIf
		if JsonUtil.StringListGet(MyImportFileName, MyFormID, 11) && StorageUtil.GetIntValue(none, "DynDOLOD_UseNiOverride", 0) != 0
			SafetyCounter = 10
			while self && !self.IsDisabled() && !self.Is3DLoaded() && SafetyCounter
				Utility.Wait(0.333)
				SafetyCounter -= 1
			endWhile
			Int Index = StringUtil.Split(JsonUtil.StringListGet(MyImportFileName, MyFormID, 11), ";").Length
			While self && !self.IsDisabled() && self.Is3DLoaded() && Index
				Index -= 1
				if NiOverride.GetNodePropertyBool(self, FALSE, StringUtil.Split(JsonUtil.StringListGet(MyImportFileName, MyFormID, 11), ";")[Index], 1, -1)
					if !StorageUtil.HasFloatValue(self, Index)
						StorageUtil.SetFloatValue(self, Index, NiOverride.GetNodePropertyFloat(self, FALSE, StringUtil.Split(JsonUtil.StringListGet(MyImportFileName, MyFormID, 11), ";")[Index], 1, -1))
					endIf
					NiOverride.AddNodeOverrideFloat(self, FALSE, StringUtil.Split(JsonUtil.StringListGet(MyImportFileName, MyFormID, 11), ";")[Index], 1, -1, StorageUtil.GetFloatValue(self, Index, 1.0) * MyMultiple, FALSE)
				endIf
			endWhile
		endIf
	endIf
EndEvent

Event OnCellAttach()
	if !MyDeBounce
		MyDeBounce = TRUE
		if !MyMaster
			PlayerRef = Game.GetForm(0x00000014) As Actor
			if MyWorldspace == None
				MyWorldspace = self.GetWorldspace()
			endIf
			if StorageUtil.GetIntValue(None, "DynDOLOD_Active", 0) == 0
				Utility.Wait(3)
			endif
			MyWorld = JsonUtil.GetStringValue("DynDOLOD_Worlds", StringUtil.SubString(MyWorldspace As String, 13, StringUtil.Find(MyWorldspace As String, "(") - 14), StringUtil.SubString(MyWorldspace As String, 13, StringUtil.Find(MyWorldspace As String, "(") - 14))
			MyMaster = Game.GetFormFromFile(JsonUtil.IntListGet("DynDOLOD_" + MyWorld, "master", 0), "DynDOLOD.esp") As ObjectReference
			MyFormID = Math.LogicalAnd(0x00FFFFFF, self.GetFormID()) As String
			MyImportFileName = "DynDOLOD_" + MyWorld + "_Objects"
		endIf
		if MyMaster
			if MySelfDisable && MyEnabled
				if JsonUtil.GetStringValue("DynDOLOD_Worlds", "debug", "false") == "true" || JsonUtil.GetStringValue("DynDOLOD_Worlds", "debug", "false") == MyFormID
					debug.trace(self + " Enable #3 " + self.GetBaseObject() + " using " + self.GetBaseObject().GetWorldModelPath())
				endIf
				self.EnableNoWait(FALSE)
				MySelfDisable = FALSE
			else
				if self && !self.IsDisabled()
					if self.GetBaseObject().GetType() == 29
						self.SetOpen(FALSE)
					endIf
					if StorageUtil.GetIntValue(none, "DynDOLOD_UseNiOverride", 0) != 0
						if JsonUtil.StringListGet(MyImportFileName, MyFormID, 11) && math.abs(self.GetPositionX() - PlayerRef.GetPositionX()) > (JsonUtil.GetFloatValue("DynDOLOD_Worlds", "FarGrid", 43008)) || math.abs(self.GetPositionY() - PlayerRef.GetPositionY()) > JsonUtil.GetFloatValue("DynDOLOD_Worlds", "FarGrid", 43008)
							SafetyCounter = 10
							while self && !self.IsDisabled() && !self.Is3DLoaded() && SafetyCounter
								Utility.Wait(0.333)
								SafetyCounter -= 1
							endWhile
							Int Index = StringUtil.Split(JsonUtil.StringListGet(MyImportFileName, MyFormID, 11), ";").Length
							While self && !self.IsDisabled() && self.Is3DLoaded() && Index
								Index -= 1
								if NiOverride.GetNodePropertyBool(self, FALSE, StringUtil.Split(JsonUtil.StringListGet(MyImportFileName, MyFormID, 11), ";")[Index], 1, -1)
									if !StorageUtil.HasFloatValue(self, Index)
										StorageUtil.SetFloatValue(self, Index, NiOverride.GetNodePropertyFloat(self, FALSE, StringUtil.Split(JsonUtil.StringListGet(MyImportFileName, MyFormID, 11), ";")[Index], 1, -1))
									endIf
									NiOverride.AddNodeOverrideFloat(self, FALSE, StringUtil.Split(JsonUtil.StringListGet(MyImportFileName, MyFormID, 11), ";")[Index], 1, -1, StorageUtil.GetFloatValue(self, Index, 1.0) * StorageUtil.GetFloatValue(none, "DynDOLOD_NeverMultiple", JsonUtil.GetFloatValue("DynDOLOD_Worlds", "NeverMultiple", 1.75)), FALSE)
								endIf
							endWhile
						endIf
					endIf
				endIf
			endIf
		endIf
	endIf
endEvent

Event OnCellDetach()
	if !self.IsDisabled() && !(Game.GetForm(0x00000014) As Actor).GetWorldspace()
		MyDeBounce = FALSE
		;if JsonUtil.GetStringValue("DynDOLOD_Worlds", "debug", "false") == "true" || JsonUtil.GetStringValue("DynDOLOD_Worlds", "debug", "false") == MyFormID
		;	debug.trace(self + " Disable #5 " + self.GetBaseObject() + " using " + self.GetBaseObject().GetWorldModelPath())
		;endIf
		self.DisableNoWait(FALSE)
		MySelfDisable = TRUE
	endIf
endEvent

Worldspace Property MyWorldspace Auto
