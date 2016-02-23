//---------------------------------------------------------------------------------------
//  FILE:    X2StrategyElement_DefaultStaffSlots.uc
//  AUTHOR:  Mark Nauta
//           
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------
class X2StrategyElement_DefaultStaffSlots_SF extends X2StrategyElement_DefaultStaffSlots config(ScientistStaffSlots);

var config float ScanRateMod;

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

//
//Utility funcs
//

static function fillSciSlot(XComGameState_Unit NewUnitState, StaffUnitInfo UnitInfo){
	//Halts bonus to research
	if(!UnitInfo.bGhostUnit){
		NewUnitState.SkillLevelBonus -= GetContributionDefault(NewUnitState);
	}
}

static function emptySciSlot(XComGameState_Unit NewUnitState){
	//Resumes bonus to research

	if(NewUnitState.SkillLevelBonus < 0){
		NewUnitState.SkillLevelBonus = 0;
	}
}

//#############################################################################################
//----------------  Override of laboratory funcs ---------------------------------------------
//#############################################################################################

static function X2DataTemplate CreateLaboratoryStaffSlotTemplate()
{
	local X2StaffSlotTemplate Template;

	`CREATE_X2TEMPLATE(class'X2StaffSlotTemplate', Template, 'LaboratoryStaffSlot');
	Template.bScientistSlot = true;
	Template.FillFn = FillLaboratorySlot;
	Template.EmptyFn = EmptyLaboratorySlot;
	Template.GetContributionFromSkillFn = GetContributionDefault;
	Template.GetAvengerBonusAmountFn = GetAvengerBonusDefault;
	Template.GetNameDisplayStringFn = GetNameDisplayStringDefault;
	Template.GetSkillDisplayStringFn = GetSkillDisplayStringDefault;
	Template.GetBonusDisplayStringFn = GetLaboratoryBonusDisplayString;
	Template.GetLocationDisplayStringFn = GetLocationDisplayStringDefault;
	Template.IsUnitValidForSlotFn = IsUnitValidForSlotDefault;
	Template.IsStaffSlotBusyFn = IsStaffSlotBusyDefault;
	Template.MatineeSlotName = "Scientist";

	return Template;
}

static function FillLaboratorySlot(XComGameState NewGameState, StateObjectReference SlotRef, StaffUnitInfo UnitInfo)
{
	local XComGameState_Unit NewUnitState;
	local XComGameState_StaffSlot NewSlotState;

	FillSlot(NewGameState, SlotRef, UnitInfo, NewSlotState, NewUnitState);

	NewUnitState.SkillLevelBonus += NewSlotState.GetMyTemplate().GetContributionFromSkillFn(NewUnitState);
	`Redscreen("Test" $NewUnitState.SkillLevelBonus);
}

static function EmptyLaboratorySlot(XComGameState NewGameState, StateObjectReference SlotRef)
{
	local XComGameState_StaffSlot NewSlotState;
	local XComGameState_Unit NewUnitState;

	EmptySlot(NewGameState, SlotRef, NewSlotState, NewUnitState);

	NewUnitState.SkillLevelBonus -= NewSlotState.GetMyTemplate().GetContributionFromSkillFn(NewUnitState);
	`Redscreen("Test2" $NewUnitState.SkillLevelBonus);


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
	Template.GetAvengerBonusAmountFn = GetAvengerBonusCommSci;
	Template.GetSkillDisplayStringFn = GetSkillDisplayStringDefault;
	Template.GetBonusDisplayStringFn = GetCommSciBonusDisplayString;
	Template.GetLocationDisplayStringFn = GetLocationDisplayStringDefault;
	Template.IsUnitValidForSlotFn = IsUnitValidForSlotDefault;
	Template.IsStaffSlotBusyFn = IsStaffSlotBusyDefault;
	Template.MatineeSlotName = "Scientist";

	return Template;
}

static function string GetCommSciBonusDisplayString(XComGameState_StaffSlot SlotState, optional bool bPreview)
{
	local string Contribution;

	if (SlotState.IsSlotFilled())
	{
		Contribution = string(GetAvengerBonusCommSci(SlotState.GetAssignedStaff(), bPreview));
	}

	return GetBonusDisplayString(SlotState, "%AVENGERBONUS", Contribution);
}

static function int GetAvengerBonusCommSci(XComGameState_Unit Unit, optional bool bPreview)
{
	local float PercentIncrease;

	PercentIncrease = (1 - default.ScanRateMod)*100;

	return Round(PercentIncrease);
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

	fillSciSlot(NewUnitState, UnitInfo);

	NewXComHQ = GetNewXComHQState(NewGameState);

	NewScanRate = NewXComHQ.CurrentScanRate * default.ScanRateMod;
	NewXComHQ.CurrentScanRate = NewScanRate;

	PossibleScanningSites = NewXComHQ.GetAvailableScanningSites();
	foreach PossibleScanningSites(ScaningSiteState)
	{
		ScaningSiteState = XComGameState_ScanningSite(NewGameState.CreateStateObject(class'XComGameState_ScanningSite', ScaningSiteState.ObjectID));
		NewGameState.AddStateObject(ScaningSiteState);

		ScaningSiteState.ModifyRemainingScanTime(default.ScanRateMod);
	}

}

static function EmptyCommsScientistSlot(XComGameState NewGameState, StateObjectReference SlotRef)
{
	local XComGameState_HeadquartersXCom NewXComHQ;
	local XComGameState_StaffSlot NewSlotState;
	local XComGameState_Unit NewUnitState;
	local float NewScanRate;
	local float ModRate;
	local array<XComGameState_ScanningSite> PossibleScanningSites;
	local XComGameState_ScanningSite ScaningSiteState;

	EmptySlot(NewGameState, SlotRef, NewSlotState, NewUnitState);

	emptySciSlot(NewUnitState);

	NewXComHQ = GetNewXComHQState(NewGameState);

	ModRate = 1 / default.ScanRateMod;
	NewScanRate = NewXComHQ.CurrentScanRate * ModRate;
	NewXComHQ.CurrentScanRate = NewScanRate;

	PossibleScanningSites = NewXComHQ.GetAvailableScanningSites();
	foreach PossibleScanningSites(ScaningSiteState)
	{
		ScaningSiteState = XComGameState_ScanningSite(NewGameState.CreateStateObject(class'XComGameState_ScanningSite', ScaningSiteState.ObjectID));
		NewGameState.AddStateObject(ScaningSiteState);

		ScaningSiteState.ModifyRemainingScanTime(ModRate);
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

	fillSciSlot(NewUnitState, UnitInfo);
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

	emptySciSlot(NewUnitState);
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

	fillSciSlot(NewUnitState, UnitInfo);
}

static function EmptyProvingGroundSciSlot(XComGameState NewGameState, StateObjectReference SlotRef)
{
	local XComGameState_StaffSlot NewSlotState;
	local XComGameState_Unit NewUnitState;
	
	EmptySlot(NewGameState, SlotRef, NewSlotState, NewUnitState);

	emptySciSlot(NewUnitState);
}