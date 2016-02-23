class UIPersonnel_DropDownToolTip_SF extends UIPersonnel_DropDownToolTip;

simulated function AS_RefreshData()
{
	local XComGameStateHistory History;
	local XComGameState_StaffSlot SlotState;
	local XComGameState TempState;
	local string StaffLocation, StatusString, TimeStr, BonusStr;
	local EStaffStatus Status;
	local bool bPreview;
	local int TimeValue, StatusState;

	History = `XCOMHISTORY;

	Status = class'X2StrategyGameRulesetDataStructures'.static.GetStafferStatus(UnitInfo, StaffLocation, TimeValue, StatusState);
	StatusString = class'UIUtilities_Text'.static.GetColoredText(class'UIUtilities_Strategy'.default.m_strStaffStatus[Status], StatusState);
	TimeStr = class'UIUtilities_Text'.static.GetTimeRemainingString(TimeValue);	
	SlotState = XComGameState_StaffSlot(History.GetGameStateForObjectID(SlotRef.ObjectID));
	bPreview = SlotState.IsSlotEmpty(); // only show the preview stats if the slot is currently empty

	TempState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Temporarily assigning staffer to StaffSlot to preview bonus");
	SlotState.GetMyTemplate().FillFn(TempState, SlotRef, UnitInfo);
	SlotState = XComGameState_StaffSlot(TempState.GetGameStateForObjectID(SlotRef.ObjectID));
	BonusStr = Caps(SlotState.GetBonusDisplayString(bPreview));
	SlotState.GetMyTemplate().EmptyFn(TempState, SlotRef);
	History.CleanupPendingGameState(TempState);
		
	MC.BeginFunctionOp("update");
	MC.QueueString( StatusString );
	MC.QueueString( TimeValue > 0 ? TimeStr : "" );
	MC.QueueString( StaffLocation );
	MC.QueueString( BonusStr );
	MC.EndOp();

}