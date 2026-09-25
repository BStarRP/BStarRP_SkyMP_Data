Scriptname WaterskinRefiilActivatorScript Extends ObjectReference

MiscObject Property WaterskinEmpty  Auto
Potion Property WaterskinFilled  Auto
Message Property NoEmptyWaterskinMSG Auto
Bool Property ShowNoEmptyWaterskinMSG Auto
Actor Property PlayerRef Auto

Auto State Waiting
	Event OnActivate(ObjectReference akActionRef)
		Actor actorRef = akActionRef as Actor
		If actorRef
			GoToState("Busy")
			int count = actorRef.GetItemCount(WaterskinEmpty)
			If count > 0
				actorRef.RemoveItem(WaterskinEmpty, count, true)
				actorRef.AddItem(WaterskinFilled, count)
			ElseIf ShowNoEmptyWaterskinMSG && actorRef == PlayerRef
				NoEmptyWaterskinMSG.Show()
			EndIf
			GoToState("Waiting")
		EndIf
	EndEvent
EndState

State Busy
	Event OnActivate(ObjectReference akActivator)
		;Do nothing.
	EndEvent
EndState



