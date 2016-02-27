class SF_Utilities extends XComGameState_BaseObject;

struct ProvingGroundCompletion {
	var int TimesCompletedWithSci;
	var name TemplateName;
};

var array<ProvingGroundCompletion> ProvingGroundCompletions;

function int getProvingGroundCompletions(XComGameState_Tech TechState) {
	local ProvingGroundCompletion PGCompletions;
	
	foreach ProvingGroundCompletions(PGCompletions) {
		if(PGCompletions.TemplateName == TechState.GetMyTemplateName()){
			return PGCompletions.TimesCompletedWithSci;
		}
	}

	return 0;
}

function incrementTimesCompletedWithSci(XComGameState_Tech TechState) {
	local ProvingGroundCompletion PGCompletions;
	local bool hasBeenUpdated;
	local ProvingGroundCompletion NewCompletion;
	
	hasBeenUpdated = false;
	foreach ProvingGroundCompletions(PGCompletions) {
		if(PGCompletions.TemplateName == TechState.GetMyTemplateName()){
			PGCompletions.TimesCompletedWithSci ++;
		}
	}

	if(!hasBeenUpdated){
		NewCompletion.TemplateName = TechState.GetMyTemplateName();
		NewCompletion.TimesCompletedWithSci = 1;
		ProvingGroundCompletions.AddItem(NewCompletion);
	}

}

static function SF_Utilities GetSF_Utilities()
{
	local SF_Utilities SF_Utils;
	local XComGameStateHistory History;
	local XComGameState NewGameState;

	History = `XCOMHISTORY;
	SF_Utils = SF_Utilities(History.GetSingleGameStateObjectForClass(class'SF_Utilities', true));

	if(SF_Utils == none) {
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Creating SF_Utils");
		SF_Utils = SF_Utilities(NewGameState.CreateStateObject(class'SF_Utilities'));
		NewGameState.AddStateObject(SF_Utils);
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	}

	return SF_Utils;	
}