class X2StrategyElement_DefaultTechs_SF extends X2StrategyElement_DefaultTechs config(ScientistStaffSlots);

var config array<float>					ProvingGroundReductionScalar;

function GiveItemReward(XComGameState NewGameState, XComGameState_Tech TechState, X2ItemTemplate ItemTemplate)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersXCom XComHQ;
	local X2ItemTemplateManager ItemTemplateManager;
	local XComGameState_Item ItemState;
	local XComGameState_Tech CompletedTechState;
	local array<XComGameState_Tech> CompletedTechs;
	local XComGameState_FacilityXCom ProvingGround;

	
	ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();

	foreach NewGameState.IterateByClassType(class'XComGameState_HeadquartersXCom', XComHQ)
	{
		break;
	}

	if (XComHQ == none)
	{
		History = `XCOMHISTORY;
		XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
		XComHQ = XComGameState_HeadquartersXCom(NewGameState.CreateStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
		NewGameState.AddStateObject(XComHQ);
	}

	// If it is possible for this item to be upgraded, check to see if the upgrade has already been researched
	if (ItemTemplate.UpgradeItem != '')
	{
		CompletedTechs = XComHQ.GetCompletedProvingGroundTechStates();
		foreach CompletedTechs(CompletedTechState)
		{
			if (CompletedTechState.GetMyTemplate().ItemsToUpgrade.Find(ItemTemplate.DataName) != INDEX_NONE)
			{
				// A tech has already been completed which has upgraded this item, so replace the template with the upgraded version
				ItemTemplate = ItemTemplateManager.FindItemTemplate(ItemTemplate.UpgradeItem);
				break;
			}
		}
	}

	ItemState = ItemTemplate.CreateInstanceFromTemplate(NewGameState);
	NewGameState.AddStateObject(ItemState);

	// Act as though it was just built, and immediately add it to the inventory
	ItemState.OnItemBuilt(NewGameState);

	//Modded code to set project to instant in future if an instance is completed
	//Should make adjustments in the future so that they can't just bung a scientist in at the last minute
	ProvingGround = XComHQ.GetFacilityByName('ProvingGround');
	if (ProvingGround.HasFilledScientistSlot()){
		TechState.TimeReductionScalar = TechState.TimeReductionScalar * GetProvingGroundReductionScalar();
	}

	TechState.ItemReward = ItemTemplate; // Needed for UI Alert display info
	TechState.bSeenResearchCompleteScreen = false; // Reset the research report for techs that are repeatable

	XComHQ.PutItemInInventory(NewGameState, ItemState);

	`XEVENTMGR.TriggerEvent('ItemConstructionCompleted', ItemState, ItemState, NewGameState);
}

function float GetProvingGroundReductionScalar()
{
	return default.ProvingGroundReductionScalar[`DifficultySetting];
}