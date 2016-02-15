//---------------------------------------------------------------------------------------
//  FILE:   XComDownloadableContentInfo_ScientistFacilitySlots.uc                                    
//           
//	Use the X2DownloadableContentInfo class to specify unique mod behavior when the 
//  player creates a new campaign or loads a saved game.
//  
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------

class X2DownloadableContentInfo_ScientistFacilitySlots extends X2DownloadableContentInfo;

/// <summary>
/// This method is run if the player loads a saved game that was created prior to this DLC / Mod being installed, and allows the 
/// DLC / Mod to perform custom processing in response. This will only be called once the first time a player loads a save that was
/// create without the content installed. Subsequent saves will record that the content was installed.
/// </summary>

//This was a first attempt at getting it to load on existing campaigns, failed entirely.
static event OnLoadedSavedGame()
{
	//UpdateTemplates(none,'Workshop');
	//UpdateTemplates(none,'ProvingGround');
	//UpdateTemplates(none,'ResistanceComms');
//	UpdateFacility('ProvingGround');
//	UpdateFacility('Workshop');
//	UpdateFacility('ResistanceComms');
}

/// <summary>
/// Called when the player starts a new campaign while this DLC / Mod is installed
/// </summary>
static event InstallNewCampaign(XComGameState StartState)
{}


//These functions shamelessly stolen from the long war studios leader mod

static function UpdateTemplates(XComGameState StartState, name TemplateName)
{
	local X2StrategyElementTemplateManager TemplateManager;
	local X2FacilityTemplate Template;
	local int DifficultyIndex, OriginalDifficulty, OriginalLowestDifficulty;
	local XComGameState_CampaignSettings Settings;
	local XComGameStateHistory History;

	`Log("LW OfficerPack : Updating OTS Templates");

	if (StartState == none)
	{
		History = `XCOMHISTORY;
		Settings = XComGameState_CampaignSettings(History.GetSingleGameStateObjectForClass(class'XComGameState_CampaignSettings'));
	}
	else
	{
		History = `XCOMHISTORY;
		// The CampaignSettings are initialized in CreateStrategyGameStart, so we can pull it from the history here
		Settings = XComGameState_CampaignSettings(History.GetSingleGameStateObjectForClass(class'XComGameState_CampaignSettings'));
	}

	OriginalDifficulty = Settings.DifficultySetting;
	OriginalLowestDifficulty = Settings.LowestDifficultySetting;

	//get access to strategy element template manager
	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	for( DifficultyIndex = `MIN_DIFFICULTY_INDEX; DifficultyIndex <= `MAX_DIFFICULTY_INDEX; ++DifficultyIndex )
	{
		Settings.SetDifficulty(DifficultyIndex, true);

		Template = X2FacilityTemplate(TemplateManager.FindStrategyElementTemplate(TemplateName));
		if(Template == none) 
		{
			`Redscreen("LW OfficerPack: Failed to find facility template OfficerTrainingSchool, difficult=" $ DifficultyIndex);
			continue;
		}

		`log("LW OfficerPack: Number of Pre-existing StaffSlots=" $ Template.StaffSlots.Length $ TemplateName);
		//check to see if extra slot is required
		if(Template.StaffSlots.Length == 2 && TemplateName == 'Workshop')
		{
			Template.StaffSlots.AddItem('WorkshopScientistStaffSlot');
			`log("LW OfficerPack: Added WorkshopScientistSlot to facility template WorkshopScientist");

			//for testing purposes of difficulty-variant defect 
			//Template.PointsToComplete = class'X2StrategyElement_DefaultFacilities'.static.GetFacilityBuildDays(1);

			// need to do this to update any native data caches ?
			TemplateManager.AddStrategyElementTemplate(Template, true);
		}

		if(Template.StaffSlots.Length == 1 && TemplateName == 'ProvingGround')
		{
			Template.StaffSlots.AddItem('ProvingGroundScientistStaffSlot');
			`log("LW OfficerPack: Added ProvingGroundScientistSlot to facility template Proving Ground");

			//for testing purposes of difficulty-variant defect 
			//Template.PointsToComplete = class'X2StrategyElement_DefaultFacilities'.static.GetFacilityBuildDays(1);

			// need to do this to update any native data caches ?
			TemplateManager.AddStrategyElementTemplate(Template, true);
		}

		if(Template.StaffSlots.Length == 2 && TemplateName == 'ResistanceComms')
		{
			Template.StaffSlots.AddItem('CommsScientistStaffSlot');
			`log("LW OfficerPack: Added ommsScientistSlot to facility template Comms Scientist");

			//for testing purposes of difficulty-variant defect 
			//Template.PointsToComplete = class'X2StrategyElement_DefaultFacilities'.static.GetFacilityBuildDays(1);

			// need to do this to update any native data caches ?
			TemplateManager.AddStrategyElementTemplate(Template, true);
		}
	}

	//restore difficulty settings
	Settings.SetDifficulty(OriginalLowestDifficulty, true);
	Settings.SetDifficulty(OriginalDifficulty, false);
}

// ******** HANDLE UPDATING OTS FACILITY ************* //
// This handles updating the OTS facility, in case facility is already built or is being built
// Upgrades are dynamically pulled from templates even for already-completed facilities, so don't have to be updated
static function UpdateFacility(name TemplateName)
{
	local XComGameState NewGameState;
	local XComGameStateHistory History;
	local XComGameState_FacilityXCom FacilityState, OTSState;

	`Log("LW OfficerPack : Searching for existing OTS Facility");
	History = `XCOMHISTORY;
	foreach History.IterateByClassType(class'XComGameState_FacilityXCom', FacilityState)
	{
		if( FacilityState.GetMyTemplateName() == TemplateName )
		{
			OTSState = FacilityState; 
			break;
		}
	}

	if(OTSState == none) 
	{
		`log("LW OfficerPack: No existing OTS facility, update aborted");
		return;
	}

	`Log("LW OfficerPack: Found existing OTS, Attempting to update StaffSlots");
	`log("LW OfficerPack: OTS had only single staff slot, attempting to update facility"); 
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Updating OTS Facility for LW_OfficerPack");
	CreateStaffSlots(OTSState, NewGameState);
	NewGameState.AddStateObject(OTSState);
	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
}


//---------------------------------------------------------------------------------------
static function CreateStaffSlots(XComGameState_FacilityXCom FacilityState, XComGameState NewGameState)
{
	local X2FacilityTemplate FacilityTemplate;
	local X2StaffSlotTemplate StaffSlotTemplate;
	local XComGameState_StaffSlot StaffSlotState;
	local int i, LockThreshold;
	
	FacilityTemplate = FacilityState.GetMyTemplate();

	LockThreshold = FacilityTemplate.StaffSlots.Length - FacilityTemplate.StaffSlotsLocked;

	for (i = FacilityState.StaffSlots.Length ; i < FacilityTemplate.StaffSlots.Length; i++)
	{
		StaffSlotTemplate = X2StaffSlotTemplate(class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager().FindStrategyElementTemplate(FacilityTemplate.StaffSlots[i]));

		if (StaffSlotTemplate != none)
		{
			StaffSlotState = StaffSlotTemplate.CreateInstanceFromTemplate(NewGameState);
			StaffSlotState.Facility = FacilityState.GetReference(); //make sure the staff slot knows what facility it is in
			if (i >= LockThreshold)
			{
				StaffSlotState.LockSlot();
			}
			
			NewGameState.AddStateObject(StaffSlotState);

			FacilityState.StaffSlots.AddItem(StaffSlotState.GetReference());
		}
	}
}
