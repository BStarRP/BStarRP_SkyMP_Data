Scriptname SHESON_DynDOLOD_ObjectEnabler extends ObjectReference

Event OnInit()
	Int index = MyWorldspaces.GetSize()
	bool off = true
	While index > 0 && off
		index -= 1
		if self.GetWorldSpace() == MyWorldspaces.GetAt(index)
			off = false
		endIf
	endWhile
	if off
		self.DisableNoWait(FALSE)
	else
		self.EnableNoWait(FALSE)
	endIf
endEvent

Event OnCellAttach()
	Int index = MyWorldspaces.GetSize()
	bool off = true
	While index > 0 && off
		index -= 1
		if self.GetWorldSpace() == MyWorldspaces.GetAt(index)
			off = false
		endIf
	endWhile
	if off
		self.DisableNoWait(FALSE)
	else
		self.EnableNoWait(FALSE)
	endIf
endEvent

Event OnCellDetach()
	Int index = MyWorldspaces.GetSize()
	bool off = true
	While index > 0 && off
		index -= 1
		if self.GetWorldSpace() == MyWorldspaces.GetAt(index)
			off = false
		endIf
	endWhile
	if off
		self.DisableNoWait(FALSE)
	endIf
endEvent

FormList Property MyWorldspaces Auto
