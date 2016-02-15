//---------------------------------------------------------------------------------------
//  FILE:    X2StrategyElement_DefaultStaffSlots.uc
//  AUTHOR:  Mark Nauta
//           
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------
class X2StrategyElement_DefaultStaffSlots_SF extends X2StrategyElement_DefaultStaffSlots;

//---------------------------------------------------------------------------------------
static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> StaffSlots;

	StaffSlots.AddItem(CreateBuildStaffSlotTemplate());
	StaffSlots.AddItem(CreateEngineeringStaffSlotTemplate());
	StaffSlots.AddItem(CreateResearchStaffSlotTemplate());
	StaffSlots.AddItem(CreateWorkshopStaffSlotTemplate());
	StaffSlots.AddItem(CreateWorkshopScientistStaffSlotTemplate());
	StaffSlots.AddItem(CreateLaboratoryStaffSlotTemplate());
	StaffSlots.AddItem(CreateProvingGroundStaffSlotTemplate());
	StaffSlots.AddItem(CreateProvingGroundSciStaffSlotTemplate());
	StaffSlots.AddItem(CreateResCommsStaffSlotTemplate());
	StaffSlots.AddItem(CreateResCommsBetterStaffSlotTemplate());
	StaffSlots.AddItem(CreateCommsScientistStaffSlotTemplate());
	StaffSlots.AddItem(CreatePowerRelayStaffSlotTemplate());
	StaffSlots.AddItem(CreatePsiChamberEngineerStaffSlotTemplate());
	StaffSlots.AddItem(CreatePsiChamberSoldierStaffSlotTemplate());
	StaffSlots.AddItem(CreateUFODefenseStaffSlotTemplate());
	StaffSlots.AddItem(CreateOTSStaffSlotTemplate());
	StaffSlots.AddItem(CreateAWCEngineerStaffSlotTemplate());
	StaffSlots.AddItem(CreateAWCSoldierStaffSlotTemplate());
	StaffSlots.AddItem(CreateShadowChamberShenStaffSlotTemplate());
	StaffSlots.AddItem(CreateShadowChamberTyganStaffSlotTemplate());
	
	return StaffSlots;
}


//#############################################################################################
//----------------  New code for Resistance Comms ---------------------------------------------
//#############################################################################################

static function X2DataTemplate CreateCommsScientistStaffSlotTemplate()
{
	local X2StaffSlotTemplate Template;

	`CREATE_X2TEMPLATE(class'X2StaffSlotTemplate', Template, 'CommsScientistStaffSlot');
	Template.bScientistSlot = true;
	Template.FillFn = FillCommsScientistSlot;
	Template.EmptyFn = EmptyCommsScientistSlot;
	Template.GetNameDisplayStringFn = GetNameDisplayStringDefault;
	Template.GetSkillDisplayStringFn = GetSkillDisplayStringDefault;
	Template.GetBonusDisplayStringFn = GetBonusDisplayStringDefault;
	Template.GetLocationDisplayStringFn = GetLocationDisplayStringDefault;
	Template.IsUnitValidForSlotFn = IsUnitValidForSlotDefault;
	Template.IsStaffSlotBusyFn = IsStaffSlotBusyDefault;
	Template.MatineeSlotName = "Scientist";

	return Template;
}

static function FillCommsScientistSlot(XComGameState NewGameState, StateObjectReference SlotRef, StaffUnitInfo UnitInfo)
{
	local XComGameState_HeadquartersXCom NewXComHQ;
	local XComGameState_Unit NewUnitState;
	local XComGameState_StaffSlot NewSlotState;
	local float NewScanRate;
	local array<XComGameState_ScanningSite> PossibleScanningSites;
	local XComGameState_ScanningSite ScaningSiteState;


	FillSlot(NewGameState, SlotRef, UnitInfo, NewSlotState, NewUnitState);

	//Halts bonus to research
	NewUnitState.SkillLevelBonus += -1;

	NewXComHQ = GetNewXComHQState(NewGameState);

	NewScanRate = NewXComHQ.CurrentScanRate * 0.5;
	NewXComHQ.CurrentScanRate = NewScanRate;

	PossibleScanningSites = NewXComHQ.GetAvailableScanningSites();
	foreach PossibleScanningSites(ScaningSiteState)
	{
		ScaningSiteState = XComGameState_ScanningSite(NewGameState.CreateStateObject(class'XComGameState_ScanningSite', ScaningSiteState.ObjectID));
		NewGameState.AddStateObject(ScaningSiteState);

		ScaningSiteState.ModifyRemainingScanTime(0.5);
	}

}

static function EmptyCommsScientistSlot(XComGameState NewGameState, StateObjectReference SlotRef)
{
	local XComGameState_HeadquartersXCom NewXComHQ;
	local XComGameState_StaffSlot NewSlotState;
	local XComGameState_Unit NewUnitState;
	local float NewScanRate;
	local array<XComGameState_ScanningSite> PossibleScanningSites;
	local XComGameState_ScanningSite ScaningSiteState;

	EmptySlot(NewGameState, SlotRef, NewSlotState, NewUnitState);

	//Resumes bonus to research
	NewUnitState.SkillLevelBonus += -1;

	NewXComHQ = GetNewXComHQState(NewGameState);

	NewScanRate = NewXComHQ.CurrentScanRate * 2;
	NewXComHQ.CurrentScanRate = NewScanRate;

	PossibleScanningSites = NewXComHQ.GetAvailableScanningSites();
	foreach PossibleScanningSites(ScaningSiteState)
	{
		ScaningSiteState = XComGameState_ScanningSite(NewGameState.CreateStateObject(class'XComGameState_ScanningSite', ScaningSiteState.ObjectID));
		NewGameState.AddStateObject(ScaningSiteState);

		ScaningSiteState.ModifyRemainingScanTime(2);
	}
}

//#############################################################################################
//----------------  New code for Workshop -----------------------------------------------------
//#############################################################################################

static function X2DataTemplate CreateWorkshopScientistStaffSlotTemplate()
{
	local X2StaffSlotTemplate Template;
	
	`CREATE_X2TEMPLATE(class'X2StaffSlotTemplate', Template, 'WorkshopScientistStaffSlot');
	Template.bScientistSlot = true;
	Template.FillFn = FillScientistWorkshopSlot;
	Template.EmptyFn = EmptyScientistWorkshopSlot;
	Template.CanStaffBeMovedFn = CanStaffBeMovedWorkshop;
	Template.GetContributionFromSkillFn = GetWorkshopContribution;
	Template.GetAvengerBonusAmountFn = GetAvengerBonusDefault;
	Template.GetNameDisplayStringFn = GetNameDisplayStringDefault;
	Template.GetSkillDisplayStringFn = GetSkillDisplayStringDefault;
	Template.GetBonusDisplayStringFn = GetWorkshopBonusDisplayString;
	Template.GetLocationDisplayStringFn = GetLocationDisplayStringDefault;
	Template.IsUnitValidForSlotFn = IsUnitValidForSlotDefault;
	Template.IsStaffSlotBusyFn = IsWorkshopBusy;
	Template.MatineeSlotName = "Scientist";

	Template.CreatesGhosts = true;
	
	return Template;
}

static function FillScientistWorkshopSlot(XComGameState NewGameState, StateObjectReference SlotRef, StaffUnitInfo UnitInfo)
{
	local XComGameState_StaffSlot NewSlotState;
	local XComGameState_Unit NewUnitState;
	
	FillSlot(NewGameState, SlotRef, UnitInfo, NewSlotState, NewUnitState);

	// Add special staffing gremlins
	NewSlotState.MaxAdjacentGhostStaff = GetWorkshopContribution(NewUnitState);
	NewSlotState.AvailableGhostStaff = NewSlotState.MaxAdjacentGhostStaff;

	//Halts bonus to research
	NewUnitState.SkillLevelBonus += -1;
}

static function EmptyScientistWorkshopSlot(XComGameState NewGameState, StateObjectReference SlotRef)
{
	local XComGameState_StaffSlot NewSlotState;
	local XComGameState_Unit NewUnitState;
	
	EmptySlot(NewGameState, SlotRef, NewSlotState, NewUnitState);

	// Should never enter this function if special staffing gremlins are still active
	// Set the number of available staffing gremlins to 0
	NewSlotState.MaxAdjacentGhostStaff = 0;
	NewSlotState.AvailableGhostStaff = 0;

	//Resumes bonus to research
	NewUnitState.SkillLevelBonus += 1;
}

//#############################################################################################
//----------------  New code for Proving Ground -----------------------------------------------
//#############################################################################################


//Handling of the bonuses from this slot is done in the XComGameState_HeadquartersProjectResearch_SF class
static function X2DataTemplate CreateProvingGroundSciStaffSlotTemplate()
{
	local X2StaffSlotTemplate Template;

	`CREATE_X2TEMPLATE(class'X2StaffSlotTemplate', Template, 'ProvingGroundScientistStaffSlot');
	Template.bScientistSlot = true;
	Template.FillFn = FillProvingGroundSciSlot;
	Template.EmptyFn = EmptyProvingGroundSciSlot;
	Template.ShouldDisplayToDoWarningFn = ShouldDisplayProvingGroundToDoWarning;
	Template.GetContributionFromSkillFn = GetContributionDefault;
	Template.GetAvengerBonusAmountFn = GetProvingGroundAvengerBonus;
	Template.GetNameDisplayStringFn = GetNameDisplayStringDefault;
	Template.GetSkillDisplayStringFn = GetSkillDisplayStringDefault;
	Template.GetBonusDisplayStringFn = GetProvingGroundBonusDisplayString;
	Template.GetLocationDisplayStringFn = GetLocationDisplayStringDefault;
	Template.IsUnitValidForSlotFn = IsUnitValidForSlotDefault;
	Template.IsStaffSlotBusyFn = IsStaffSlotBusyDefault;
	Template.MatineeSlotName = "Scientist";

	return Template;
}

static function FillProvingGroundSciSlot(XComGameState NewGameState, StateObjectReference SlotRef, StaffUnitInfo UnitInfo)
{
	local XComGameState_StaffSlot NewSlotState;
	local XComGameState_Unit NewUnitState;
	
	FillSlot(NewGameState, SlotRef, UnitInfo, NewSlotState, NewUnitState);

	//Halts bonus to research
	NewUnitState.SkillLevelBonus += -1;
}

static function EmptyProvingGroundSciSlot(XComGameState NewGameState, StateObjectReference SlotRef)
{
	local XComGameState_StaffSlot NewSlotState;
	local XComGameState_Unit NewUnitState;
	
	EmptySlot(NewGameState, SlotRef, NewSlotState, NewUnitState);

	//Resumes bonus to research
	NewUnitState.SkillLevelBonus += 1;
}