local ADDON_NAME = ...;
local DEFAULT_SAVED_VARS = { ShowPreciseValues = false };
local SAVED_VARS_VERSION = 1;

function ConfigFrame_OnLoad(frame)
	frame.name = "EZ Coordinates";

	frame.savedVars = EZCoordinates_SavedVars;

	frame:SetScript("OnEvent", ConfigFrame_OnEvent);

	frame:RegisterEvent("ADDON_LOADED");
	frame:RegisterEvent("VARIABLES_LOADED");

	InterfaceOptions_AddCategory(frame);
end

function ConfigFrame_OnEvent(frame, event, ...)
	if (event == "ADDON_LOADED") then
		if (ADDON_NAME == ...) then
			if not EZCoordinates_SavedVars or not EZCoordinates_SavedVars.version then
				EZCoordinates_SavedVars = CopyTable(DEFAULT_SAVED_VARS);
			end
			EZCoordinates_SavedVars.version = SAVED_VARS_VERSION;
			
			frame.savedVars = EZCoordinates_SavedVars;

			EZJunkConfigFrameShowPreciseValues:SetChecked(frame.savedVars.ShowPreciseValues);
		end
	end
end

function ShowPreciseValuesButton_OnShow(checkButton)
	getglobal(checkButton:GetName() .. 'Text'):SetText("Show Precise Values?");
end

function ShowPreciseValuesButton_OnClick(checkButton)
	EZCoordinates_SavedVars.ShowPreciseValues = checkButton:GetChecked();
end

SLASH_EZCoordinates1 = "/ezcoordinates";
SLASH_EZCoordinates2 = "/ezc";
SlashCmdList["EZCoordinates"] = function(option)
	local comparableOption = string.lower(option);
	
	if (comparableOption == "") then
		InterfaceOptionsFrame_OpenToCategory("EZ Coordinates");
		InterfaceOptionsFrame_OpenToCategory("EZ Coordinates");
	end
end