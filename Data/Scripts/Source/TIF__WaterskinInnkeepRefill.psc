;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname TIF__WaterskinInnkeepRefill Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
int count = PlayerRef.GetItemCount(WaterskinEmpty)
PlayerRef.RemoveItem(WaterskinEmpty, count, true)
PlayerRef.AddItem(WaterskinFilled, count)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

MiscObject Property WaterskinEmpty  Auto  

Potion Property WaterskinFilled  Auto  

Actor Property PlayerRef  Auto  
