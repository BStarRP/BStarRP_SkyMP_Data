Scriptname MAG_GourmetController_Script extends ReferenceAlias  

Faction Property CastleCookFaction Auto
Faction Property CollegeCookFaction Auto
Faction Property MerchantFaction Auto
Actor Property CastleCookActor Auto
Actor Property CollegeCookActor Auto
Potion Property MeadItem01 Auto
Potion Property MeadItem02 Auto 
Book Property Cookbook01 Auto
Book Property Cookbook02 Auto
Book Property Cookbook03 Auto
GlobalVariable Property MeadPurchased01 Auto
GlobalVariable Property MeadPurchased02 Auto
GlobalVariable Property BookPurchased01 Auto
GlobalVariable Property BookPurchased02 Auto
GlobalVariable Property BookPurchased03 Auto
Keyword Property DrugsKeyword Auto
FormList Property MerchantList01 Auto

Event OnInit()

	RegisterForSingleUpdate(5)

EndEvent

Event OnUpdate() 

	CastleCookActor.AddToFaction(MerchantFaction)
	CastleCookActor.AddToFaction(CastleCookFaction)

	CollegeCookActor.AddToFaction(MerchantFaction)
	CollegeCookActor.AddToFaction(CollegeCookFaction)

	AddInventoryEventFilter(MeadItem01)
	AddInventoryEventFilter(MeadItem02)
	AddInventoryEventFilter(Cookbook01)
	AddInventoryEventFilter(Cookbook02)
	AddInventoryEventFilter(Cookbook03)


	MerchantList01.AddForm(MerchantList01)

EndEvent

Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)

    	If akBaseItem == MeadItem01
		MeadPurchased01.SetValue(100)
	ElseIf akBaseItem == MeadItem02
       	MeadPurchased02.SetValue(100)
	ElseIf akBaseItem == Cookbook01
		BookPurchased01.SetValue(100)
	ElseIf akBaseItem == Cookbook02
		BookPurchased02.SetValue(100)
	ElseIf akBaseItem == Cookbook03
		BookPurchased03.SetValue(100)
	EndIf 

EndEvent
