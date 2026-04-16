;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 0
Scriptname QF_ccBGSSSE001_FishingFollow_050D1017 Extends Quest Hidden

;BEGIN ALIAS PROPERTY Follower08
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Follower08 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Follower07
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Follower07 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Follower03
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Follower03 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Follower10
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Follower10 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Follower05
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Follower05 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Follower06
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Follower06 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY DogMarker
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_DogMarker Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Follower02
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Follower02 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Follower09
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Follower09 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Follower01
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Follower01 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Dog
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Dog Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY FollowerMarker
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_FollowerMarker Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Follower04
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Follower04 Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_1
Function Fragment_1()
;BEGIN CODE
		int n = followers.Length
		while n
			n -= 1
			ccbgssse001_sandboxfollowerscript follower = followers[n]
			if follower.GetActorRef()
				follower.SetFollowerIdleWhenFishing()
			endIf
		endWhile
	if Dog.GetActorRef()
		Dog.SetFollowerIdleWhenFishing()
	endIf
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

ccbgssse001_sandboxfollowerscript[] property Followers auto
ccbgssse001_sandboxfollowerscript property Dog auto
