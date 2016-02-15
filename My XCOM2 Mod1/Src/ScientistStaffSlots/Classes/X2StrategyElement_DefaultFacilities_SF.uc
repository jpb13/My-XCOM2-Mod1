//---------------------------------------------------------------------------------------
//  FILE:    X2StrategyElement_DefaultFacilities.uc
//  AUTHOR:  Mark Nauta
//           
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------
class X2StrategyElement_DefaultFacilities_SF extends X2StrategyElement_DefaultFacilities;

//---------------------------------------------------------------------------------------
// PROVING GROUND
//---------------------------------------------------------------------------------------

//Adds an additional engineer slot
static function X2DataTemplate CreateProvingGroundTemplate()
{
	local X2FacilityTemplate Template;
	local ArtifactCost Resources;

	`CREATE_X2TEMPLATE(class'X2FacilityTemplate', Template, 'ProvingGround');
	Template.bIsCoreFacility = false;
	Template.bIsUniqueFacility = true;
	Template.bIsIndestructible = false;
	Template.MapName = "AVG_ProvingGrounds_A";
	Template.AnimMapName = "AVG_ProvingGrounds_A_Anim";
	Template.FlyInRemoteEvent = '';
	Template.strImage = "img:///UILibrary_StrategyImages.FacilityIcons.ChooseFacility_ProvingGrounds";
	Template.StaffSlots.addItem('ProvingGroundScientistStaffSlot');
	Template.StaffSlots.AddItem('ProvingGroundStaffSlot');
	Template.SelectFacilityFn = SelectFacility;
	Template.OnFacilityRemovedFn = OnProvingGroundRemoved;
	Template.IsFacilityProjectActiveFn = IsProvingGroundProjectActive;
	Template.GetQueueMessageFn = GetProvingGroundQueueMessage;
	Template.FillerSlots.AddItem('Engineer');
	Template.FillerSlots.AddItem('Engineer');
	Template.FillerSlots.AddItem('Engineer');
	Template.FillerSlots.AddItem('Engineer');
	Template.FillerSlots.AddItem('Engineer');
	Template.bHideStaffSlotOpenPopup = true;

	Template.BaseMinFillerCrew = 1;

	Template.UIFacilityClass = class'UIFacility_ProvingGround';
	Template.FacilityEnteredAkEvent = "Play_AvengerProvingGround_Unoccupied";
	Template.FacilityCompleteNarrative = "X2NarrativeMoments.Strategy.Avenger_ProvingGrounds_Complete";
	Template.ConstructionStartedNarrative = "X2NarrativeMoments.Strategy.Avenger_Tutorial_ProvingGrounds_Construction";

	Template.MaxFillerCrew = 4;

	// Requirements
	Template.Requirements.RequiredTechs.AddItem('AutopsyAdventOfficer');
	Template.Requirements.bVisibleIfPersonnelGatesNotMet = false;

	// Stats
	Template.PointsToComplete = GetFacilityBuildDays(14);
	Template.iPower = -3;
	Template.UpkeepCost = 25;
	
	// Cost
	Resources.ItemTemplateName = 'Supplies';
	Resources.Quantity = 100;
	Template.Cost.ResourceCosts.AddItem(Resources);
	
	// this is a GP priority facility
	Template.bPriority = true;

	return Template;
}

//---------------------------------------------------------------------------------------
// WORKSHOP
//---------------------------------------------------------------------------------------
static function X2DataTemplate CreateWorkshopTemplate()
{
	local X2FacilityTemplate Template;
	local ArtifactCost Resources;

	`CREATE_X2TEMPLATE(class'X2FacilityTemplate', Template, 'Workshop');
	Template.EngineeringBonus = 0;
	Template.bIsCoreFacility = false;
	Template.bIsUniqueFacility = true;
	Template.bIsIndestructible = false;
	Template.MapName = "AVG_Workshop_A";
	Template.AnimMapName = "AVG_Workshop_A_Anim";
	Template.FlyInRemoteEvent = '';
	Template.strImage = "img:///UILibrary_StrategyImages.FacilityIcons.ChooseFacility_Workshop";
	Template.StaffSlots.AddItem('WorkshopScientistStaffSlot');
	Template.StaffSlots.AddItem('WorkshopStaffSlot');
	Template.StaffSlots.AddItem('WorkshopStaffSlot');
	Template.StaffSlotsLocked = 1;
	Template.CalculateStaffingRequirementFn = CalculateWorkshopStaffingRequirement;
	Template.SelectFacilityFn = SelectFacility;
	Template.OnFacilityRemovedFn = OnFacilityRemovedDefault;
	Template.CanFacilityBeRemovedFn = CanWorkshopBeRemoved;
	Template.IsFacilityProjectActiveFn = IsWorkshopProjectActive;
	Template.Upgrades.AddItem('Workshop_AdditionalWorkbench');
	Template.FillerSlots.AddItem('Engineer');
	Template.FillerSlots.AddItem('Engineer');
	Template.FillerSlots.AddItem('Engineer');

	Template.MatineeSlotsForUpgrades.AddItem('EngineerSlot1');	

	Template.UIFacilityClass = class'UIFacility_Workshop';
	Template.FacilityEnteredAkEvent = "Play_AvengerWorkshop_Unoccupied";
	Template.FacilityCompleteNarrative = "X2NarrativeMoments.Strategy.Avenger_Workshop_Complete";
	Template.FacilityUpgradedNarrative = "X2NarrativeMoments.Strategy.Avenger_Workshop_Upgraded";
	Template.ConstructionStartedNarrative = "X2NarrativeMoments.Strategy.Avenger_Tutorial_Workshop_Construction";

	Template.BaseMinFillerCrew = 0;
	Template.MaxFillerCrew = 4;

	// Stats
	Template.PointsToComplete = GetFacilityBuildDays(20);
	Template.iPower = -1;
	Template.UpkeepCost = 35;

	// Cost
	Resources.ItemTemplateName = 'Supplies';
	Resources.Quantity = 125;
	Template.Cost.ResourceCosts.AddItem(Resources);

	return Template;
}


//---------------------------------------------------------------------------------------
// ADVANCED WARFARE CENTER
//---------------------------------------------------------------------------------------
static function X2DataTemplate CreateAdvancedWarfareCenterTemplate()
{
	local X2FacilityTemplate Template;
	local ArtifactCost Resources;

	`CREATE_X2TEMPLATE(class'X2FacilityTemplate_Infirmary', Template, 'AdvancedWarfareCenter');
	Template.bIsCoreFacility = false;
	Template.bIsUniqueFacility = true;
	Template.bIsIndestructible = false;
	Template.MapName = "AVG_Infirmary_A";
	Template.AnimMapName = "AVG_Infirmary_A_Anim";
	Template.FlyInRemoteEvent = 'CIN_Flyin_Infirmary';
	Template.strImage = "img:///UILibrary_StrategyImages.FacilityIcons.ChooseFacility_AdvancedWarCenter";
	Template.StaffSlots.AddItem('AWCScientistStaffSlot');
	Template.StaffSlots.AddItem('AWCSoldierStaffSlot');
	Template.SelectFacilityFn = SelectFacility;
	Template.OnFacilityBuiltFn = OnAdvancedWarfareCenterBuilt;
	Template.OnFacilityRemovedFn = OnAdvancedWarfareCenterRemoved;
	Template.IsFacilityProjectActiveFn = IsAdvancedWarfareCenterProjectActive;
	Template.GetQueueMessageFn = GetAdvancedWarfareCenterQueueMessage;
	Template.BaseMinFillerCrew = 1;
	
	//Medics, Patients and Visitors are handled in a custom fashion
	Template.FillerSlots.AddItem('Scientist');
	Template.FillerSlots.AddItem('Scientist');
	Template.FillerSlots.AddItem('Scientist');
	Template.FillerSlots.AddItem('Scientist');	

	Template.UIFacilityClass = class'UIFacility_AdvancedWarfareCenter';
	Template.FacilityEnteredAkEvent = "Play_AvengerAdvancedWarfareCenter_Occupied";
	Template.FacilityCompleteNarrative = "X2NarrativeMoments.Avenger_Advanced_Warfare_Center_now_operational";
	Template.FacilityUpgradedNarrative = "X2NarrativeMoments.Avenger_Advanced_Warfare_Center_upgraded";
	Template.ConstructionStartedNarrative = "X2NarrativeMoments.Avenger_Advanced_Warfare_Center_construction_initiated";

	// Requirements
	Template.Requirements.RequiredTechs.AddItem('AlienBiotech');
	
	// Stats
	Template.PointsToComplete = GetFacilityBuildDays(21);
	Template.iPower = -3;
	Template.UpkeepCost = 35;

	// Cost
	Resources.ItemTemplateName = 'Supplies';
	Resources.Quantity = 115;
	Template.Cost.ResourceCosts.AddItem(Resources);

	return Template;
}

static function OnAdvancedWarfareCenterBuilt(StateObjectReference FacilityRef)
{
	local XComGameStateHistory History;
	local XComGameState NewGameState;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_Unit UnitState;
	local int idx;

	History = `XCOMHISTORY;
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("On AWC Built");

	for(idx = 0; idx < XComHQ.Crew.Length; idx++)
	{
		UnitState = XComGameState_Unit(History.GetGameStateForObjectID(XComHQ.Crew[idx].ObjectID));

		if(UnitState != none && UnitState.IsASoldier() && UnitState.GetRank() >= 1)
		{
			UnitState = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', UnitState.ObjectID));
			NewGameState.AddStateObject(UnitState);
			UnitState.RollForAWCAbility();
		}
	}

	if(NewGameState.GetNumGameStateObjects() > 0)
	{
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	}
	else
	{
		History.CleanupPendingGameState(NewGameState);
	}
}

static function OnAdvancedWarfareCenterRemoved(StateObjectReference FacilityRef)
{
	local XComGameState NewGameState;
	local XComGameState_HeadquartersXCom NewXComHQ;

	EmptyFacilityProjectStaffSlots(FacilityRef);
	
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("On Advanced Warfare Center Removed");

	RemoveFacility(NewGameState, FacilityRef, NewXComHQ);

	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
}

static function bool IsAdvancedWarfareCenterProjectActive(StateObjectReference FacilityRef)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_FacilityXCom FacilityState;
	local XComGameState_StaffSlot StaffSlot;
	local XComGameState_HeadquartersProjectRespecSoldier RespecProject;
	local int i;

	History = `XCOMHISTORY;
	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();
	FacilityState = XComGameState_FacilityXCom(History.GetGameStateForObjectID(FacilityRef.ObjectID));
	
	if (XComHQ.GetNumberOfInjuredSoldiers() > 0)
	{
		return true;
	}

	for (i = 0; i < FacilityState.StaffSlots.Length; i++)
	{
		StaffSlot = FacilityState.GetStaffSlot(i);
		if (StaffSlot.IsSlotFilled())
		{
			RespecProject = XComHQ.GetRespecSoldierProject(StaffSlot.GetAssignedStaffRef());
			if (RespecProject != none)
			{
				return true;
			}
		}
	}
	return false;
}

static function string GetAdvancedWarfareCenterQueueMessage(StateObjectReference FacilityRef)
{
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_FacilityXCom FacilityState;
	local XComGameState_StaffSlot StaffSlot;
	local XComGameState_HeadquartersProjectRespecSoldier RespecProject;
	local string strStatus, Message;
	local int i;

	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();
	FacilityState = XComGameState_FacilityXCom(`XCOMHISTORY.GetGameStateForObjectID(FacilityRef.ObjectID));

	for (i = 0; i < FacilityState.StaffSlots.Length; i++)
	{
		StaffSlot = FacilityState.GetStaffSlot(i);
		if (StaffSlot.IsSlotFilled())
		{
			RespecProject = XComHQ.GetRespecSoldierProject(StaffSlot.GetAssignedStaffRef());
			if (RespecProject != none)
			{
				if (RespecProject.GetCurrentNumHoursRemaining() < 0)
					Message = class'UIUtilities_Text'.static.GetColoredText(class'UIFacility_Powercore'.default.m_strStalledResearch, eUIState_Warning);
				else
					Message = class'UIUtilities_Text'.static.GetTimeRemainingString(RespecProject.GetCurrentNumHoursRemaining());

				strStatus = StaffSlot.GetBonusDisplayString() $ ":" @ Message;
				break;
			}
		}
	}

	return strStatus;
}

//Private helpers

// All of the Remove Facility functionality that needs to be completed every time
private static function RemoveFacility(XComGameState NewGameState, StateObjectReference FacilityRef, optional out XComGameState_HeadquartersXCom NewXComHQ)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_FacilityXCom FacilityState;
	local XComGameState_HeadquartersRoom Room;
	local StateObjectReference EmptyRef;

	History = `XCOMHISTORY;
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	FacilityState = XComGameState_FacilityXCom(History.GetGameStateForObjectID(FacilityRef.ObjectID));
	Room = FacilityState.GetRoom();
	
	// Remove the facility from XComHQ's list
	NewXComHQ = XComGameState_HeadquartersXCom(NewGameState.CreateStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
	NewGameState.AddStateObject(NewXComHQ);
	NewXComHQ.Facilities.RemoveItem(FacilityRef);

	// Clear the reference from the room it is located in and flag it to update the 3D map
	Room = XComGameState_HeadquartersRoom(NewGameState.CreateStateObject(class'XComGameState_HeadquartersRoom', Room.ObjectID));
	NewGameState.AddStateObject(Room);
	Room.Facility = EmptyRef;
	Room.UpdateRoomMap = true;

	// Empty all of the staff slots
	FacilityState.EmptyAllStaffSlots(NewGameState);

	// Remove the facility game state	
	NewGameState.RemoveStateObject(FacilityRef.ObjectID);
}

// For staff slots that have special functions to stop HQ projects along with emptying the slot
private static function EmptyFacilityProjectStaffSlots(StateObjectReference FacilityRef)
{
	local XComGameState_FacilityXCom FacilityState;
	local XComGameState_StaffSlot SlotState;
	local int idx;

	FacilityState = XComGameState_FacilityXCom(`XCOMHISTORY.GetGameStateForObjectID(FacilityRef.ObjectID));
	for (idx = 0; idx < FacilityState.StaffSlots.Length; idx++)
	{
		SlotState = FacilityState.GetStaffSlot(idx);
		if (SlotState.GetMyTemplate().EmptyStopProjectFn != none)
		{
			SlotState.EmptySlotStopProject();
		}
	}
}

//---------------------------------------------------------------------------------------
// RESISTANCE COMMS
//---------------------------------------------------------------------------------------
static function X2DataTemplate CreateResistanceCommsTemplate()
{
	local X2FacilityTemplate Template;
	local ArtifactCost Resources;

	`CREATE_X2TEMPLATE(class'X2FacilityTemplate', Template, 'ResistanceComms');
	Template.CommCapacity = 1;
	Template.bIsCoreFacility = false;
	Template.bIsUniqueFacility = false;
	Template.bIsIndestructible = false;
	Template.MapName = "AVG_ResistanceComms_A";
	Template.AnimMapName = "AVG_ResistanceComms_A_Anim";
	Template.FlyInRemoteEvent = '';
	Template.strImage = "img:///UILibrary_StrategyImages.FacilityIcons.ChooseFacility_ResistanceComms";
	Template.StaffSlots.AddItem('CommsScientistStaffSlot');
	Template.StaffSlots.AddItem('ResCommsStaffSlot');
	Template.StaffSlots.AddItem('ResCommsBetterStaffSlot');
	Template.StaffSlotsLocked = 1;
	Template.GetFacilityInherentValueFn = GetResistanceCommsInherentValue;
	Template.SelectFacilityFn = SelectFacility;
	Template.OnFacilityRemovedFn = OnFacilityRemovedDefault;
	Template.CanFacilityBeRemovedFn = CanResistanceCommsBeRemoved;
	Template.Upgrades.AddItem('ResistanceComms_AdditionalCommStation');
	Template.FillerSlots.AddItem('Engineer');

	Template.MatineeSlotsForUpgrades.AddItem('EngineerSlot1');
	Template.MatineeSlotsForUpgrades.AddItem('EngineerSlot2');

	Template.UIFacilityClass = class'UIFacility_ResistanceComms';
	Template.FacilityEnteredAkEvent = "Play_AvengerResistanceComms_Unoccupied";
	Template.FacilityCompleteNarrative = "X2NarrativeMoments.Strategy.Avenger_ResistanceComm_Complete";
	Template.FacilityUpgradedNarrative = "X2NarrativeMoments.Strategy.Avenger_ResistanceComm_Upgraded";
	Template.ConstructionStartedNarrative = "X2NarrativeMoments.Strategy.Avenger_Tutorial_Resistance_Comm_Construction";

	Template.BaseMinFillerCrew = 0;
	Template.MaxFillerCrew = 4;

	// Requirements
	Template.Requirements.RequiredTechs.AddItem('ResistanceCommunications');

	// Stats
	Template.PointsToComplete = GetFacilityBuildDays(16);
	Template.iPower = -3;
	Template.UpkeepCost = 25;

	// Cost
	Resources.ItemTemplateName = 'Supplies';
	Resources.Quantity = 110;
	Template.Cost.ResourceCosts.AddItem(Resources);

	return Template;
}