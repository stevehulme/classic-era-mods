-- **************************************************************************
-- * TitanClassicRegen.lua
-- *
-- * By: TitanMod, Dark Imakuni, Adsertor and the Titan Panel Development Team
-- **************************************************************************

-- ******************************** Constants *******************************
local TITAN_REGEN_ID = "Regen"
local TITAN_REGEN_HP_FORMAT = "%d";
local TITAN_REGEN_HP_FORMAT_PERCENT = "%.2f";
local TITAN_REGEN_MP_FORMAT = "%d";
local TITAN_REGEN_MP_FORMAT_PERCENT = "%.2f";
local updateTable = {TITAN_REGEN_ID, TITAN_PANEL_UPDATE_ALL};
-- ******************************** Variables *******************************
local TITAN_RegenCurrHealth = 0;
local TITAN_RegenCurrMana = 0;
local TITAN_RegenMP         = 0;
local TITAN_RegenHP         = 0;
local TITAN_RegenCheckedManaState = 0;
local TITAN_RegenMaxHPRate = 0;
local TITAN_RegenMinHPRate = 9999;
local TITAN_RegenMaxMPRate = 0;
local TITAN_RegenMinMPRate = 9999;
local TITAN_RegenMPDuringCombat = 0;
local TITAN_RegenMPCombatTrack = 0;
local L = LibStub("AceLocale-3.0"):GetLocale("TitanClassic", true)
-- ******************************** Functions *******************************

-- **************************************************************************
-- NAME : TitanRegenTemp_GetColoredTextRGB(text, r, g, b)
-- DESC : Define colors for colored text and display
-- VARS : text = text to display, r = red value, g = green value, b = blue value
-- **************************************************************************
local function TitanRegenTemp_GetColoredTextRGB(text, r, g, b)
     if (text and r and g and b) then
          local redColorCode = format("%02x", r * 255);          
          local greenColorCode = format("%02x", g * 255);
          local blueColorCode = format("%02x", b * 255);          
          local colorCode = "|cff"..redColorCode..greenColorCode..blueColorCode;
          return colorCode..text..FONT_COLOR_CODE_CLOSE;
     end
end

-- **************************************************************************
-- NAME : TitanPanelRegenButton_OnLoad()
-- DESC : Registers the plugin upon it loading
-- **************************************************************************
function TitanPanelRegenButton_OnLoad(self)
     self.registry = { 
          id = TITAN_REGEN_ID,
		  category = "Built-ins",
          version = TITAN_VERSION,
          menuText = L["TITAN_REGEN_MENU_TEXT"],
          buttonTextFunction = "TitanPanelRegenButton_GetButtonText",
          tooltipTitle = L["TITAN_REGEN_MENU_TOOLTIP_TITLE"],
          tooltipTextFunction = "TitanPanelRegenButton_GetTooltipText",
		  controlVariables = {
			  ShowIcon = false,
			  ShowLabelText = true,
			  ShowRegularText = false,
			  ShowColoredText = false,
			  DisplayOnRightSide = true,
		  },
          savedVariables = {
              ShowLabelText = 1,
              ShowHPRegen = 1,
              ShowPercentage = false,
              ShowColoredText = false,
 			  DisplayOnRightSide = false,
         }
     };

     self:RegisterEvent("UNIT_HEALTH");
     self:RegisterEvent("UNIT_POWER_UPDATE");
     self:RegisterEvent("PLAYER_ENTERING_WORLD");
     self:RegisterEvent("PLAYER_REGEN_DISABLED");
     self:RegisterEvent("PLAYER_REGEN_ENABLED");
end

-- **************************************************************************
-- NAME : TitanPanelXPButton_OnEvent
-- DESC : Parse events registered to addon and act on them
-- **************************************************************************
function TitanPanelRegenButton_OnEvent(self, event, a1, a2, ...)
	if ( event == "PLAYER_ENTERING_WORLD") then
	end
     
     if ( event == "PLAYER_REGEN_DISABLED") then
          TITAN_RegenMPDuringCombat = 0;
          TITAN_RegenMPCombatTrack = 1;
     end

     if ( event == "PLAYER_REGEN_ENABLED") then
          TITAN_RegenMPCombatTrack = 0;
     end
     
     local currHealth = 0;
     local currMana = 0;
     local runUpdate = 0;
     
     if (TitanGetVar(TITAN_REGEN_ID,"ShowHPRegen") == 1) then
          if ( event == "UNIT_HEALTH" and a1 == "player") then
               currHealth = UnitHealth("player");
               runUpdate = 1;
               if ( currHealth > TITAN_RegenCurrHealth and TITAN_RegenCurrHealth ~= 0 ) then
                    TITAN_RegenHP = currHealth-TITAN_RegenCurrHealth;
                    
                    if (TITAN_RegenHP > TITAN_RegenMaxHPRate) then 
                         TITAN_RegenMaxHPRate = TITAN_RegenHP;
                    end
                    if (TITAN_RegenHP < TITAN_RegenMinHPRate or TITAN_RegenMinHPRate == 9999) then 
                         TITAN_RegenMinHPRate = TITAN_RegenHP;
                    end                    
               end
               TITAN_RegenCurrHealth = currHealth;
          end
     end

	local pval, ptype = UnitPowerType("player")
	if (pval == 0) then -- Mana
		if ( event == "UNIT_POWER_UPDATE" and a1 == "player" and a2 == "MANA") then
			currMana = UnitPower("player");
			runUpdate = 1;
			if ( currMana  > TITAN_RegenCurrMana and TITAN_RegenCurrMana ~= 0 ) then
				TITAN_RegenMP = currMana-TITAN_RegenCurrMana;

				if (TITAN_RegenMPCombatTrack == 1) then
					TITAN_RegenMPDuringCombat = TITAN_RegenMPDuringCombat + TITAN_RegenMP;
				end 

				if (TITAN_RegenMP > TITAN_RegenMaxMPRate) then 
					TITAN_RegenMaxMPRate = TITAN_RegenMP;
				end
				if (TITAN_RegenMP < TITAN_RegenMinMPRate or TITAN_RegenMinMPRate == 9999) then 
					TITAN_RegenMinMPRate = TITAN_RegenMP;
				end                                        
			end
			TITAN_RegenCurrMana = currMana;
		end
	end               

	if (runUpdate == 1) then
		TitanPanelPluginHandle_OnUpdate(updateTable)
	end
end

-- **************************************************************************
-- NAME : TitanPanelRegenButton_GetButtonText(id)
-- DESC : Calculate regeneration logic for button text
-- VARS : id = button ID
-- **************************************************************************
function TitanPanelRegenButton_GetButtonText(id)
	local labelTextHP = "";
	local valueTextHP = "";
	local labelTextMP = "";
	local valueTextMP = "";
	local OutputStr = "";

	if UnitHealth("player") == UnitHealthMax("player") then
		TITAN_RegenHP = 0;
	end
	if UnitPower("player") == UnitPowerMax("player", 0) then
		TITAN_RegenMP = 0;
	end     
               
	-- safety in case both are off, then cant ever turn em on
	if (TitanGetVar(TITAN_REGEN_ID,"ShowHPRegen") == nil) then
		TitanSetVar(TITAN_REGEN_ID,"ShowHPRegen",1);
	end

	if (TitanGetVar(TITAN_REGEN_ID,"ShowHPRegen") == 1) then
		labelTextHP = L["TITAN_REGEN_BUTTON_TEXT_HP"];
		if (TitanGetVar(TITAN_REGEN_ID,"ShowPercentage") == 1) then
			valueTextHP = format(TITAN_REGEN_HP_FORMAT_PERCENT, (TITAN_RegenHP/UnitHealthMax("player"))*100);
		else
			valueTextHP = format(TITAN_REGEN_HP_FORMAT, TITAN_RegenHP);     
		end
		if (TitanGetVar(TITAN_REGEN_ID, "ShowColoredText")) then
			valueTextHP = TitanUtils_GetGreenText(valueTextHP);
		else
			valueTextHP = TitanUtils_GetHighlightText(valueTextHP);
		end          
	end
     
	local pval, ptype = UnitPowerType("player")
	if (pval == 0) then -- Mana only
		labelTextMP = L["TITAN_REGEN_BUTTON_TEXT_MP"];
		if (TitanGetVar(TITAN_REGEN_ID,"ShowPercentage") == 1) then
			valueTextMP = format(TITAN_REGEN_MP_FORMAT_PERCENT, (TITAN_RegenMP/UnitPowerMax("player", 0))*100);
		else
			valueTextMP = format(TITAN_REGEN_MP_FORMAT, TITAN_RegenMP);               
		end
		if (TitanGetVar(TITAN_REGEN_ID, "ShowColoredText")) then
			valueTextMP = TitanRegenTemp_GetColoredTextRGB(valueTextMP, 0.0, 0.0, 1.0);
		else
			valueTextMP = TitanUtils_GetHighlightText(valueTextMP);
		end               
	end

	-- supports turning off labels
	return labelTextHP, valueTextHP, labelTextMP, valueTextMP;
end

-- **************************************************************************
-- NAME : TitanPanelRegenButton_GetTooltipText()
-- DESC : Display tooltip text
-- **************************************************************************
function TitanPanelRegenButton_GetTooltipText()
	local minHP = TITAN_RegenMinHPRate;
	local minMP = TITAN_RegenMinMPRate;

	if minHP == 9999 then minHP = 0 end;
	if minMP == 9999 then minMP = 0 end;

	local txt = ""

	txt = txt..
		format(L["TITAN_REGEN_TOOLTIP1"], UnitHealth("player"),UnitHealthMax("player"),UnitHealthMax("player")-UnitHealth("player")).."\n"..
		format(L["TITAN_REGEN_TOOLTIP3"], TITAN_RegenMaxHPRate).."\n"..
		format(L["TITAN_REGEN_TOOLTIP4"], minHP).."\n"
	
	local pval, ptype = UnitPowerType("player")
	if (pval == 0) then
		local regenPercent = 0  
		regenPercent = (TITAN_RegenMPDuringCombat/UnitPowerMax("player", 0))*100;

		txt = txt.."\n"..
			format(L["TITAN_REGEN_TOOLTIP2"], UnitPower("player"),UnitPowerMax("player", 0),UnitPowerMax("player", 0)-UnitPower("player")).."\n"..
			format(L["TITAN_REGEN_TOOLTIP5"], TITAN_RegenMaxMPRate).."\n"..
			format(L["TITAN_REGEN_TOOLTIP6"], minMP).."\n"..
			format(L["TITAN_REGEN_TOOLTIP7"], TITAN_RegenMPDuringCombat, regenPercent).."\n"               
	else
		-- L["TITAN_REGEN_TOOLTIP2"] = "Mana: \t"..GREEN_FONT_COLOR_CODE.."%d"..FONT_COLOR_CODE_CLOSE.." / " ..HIGHLIGHT_FONT_COLOR_CODE.."%d"..FONT_COLOR_CODE_CLOSE.." ("..RED_FONT_COLOR_CODE.."%d"..FONT_COLOR_CODE_CLOSE..")";
		POWER = GREEN_FONT_COLOR_CODE.."%d"..FONT_COLOR_CODE_CLOSE.." / " ..HIGHLIGHT_FONT_COLOR_CODE.."%d"..FONT_COLOR_CODE_CLOSE
		txt = txt.."\n"..
			ptype.." \t"..
			format(POWER, UnitPower("player"),UnitPowerMax("player", pval)).."\n"
			-- Energy : The formula is (energyRegen)*(1+hastePercent)
	end
	
	return txt
end

-- **************************************************************************
-- NAME : TitanPanelRightClickMenu_PrepareTitanRegenMenu()
-- DESC : Display rightclick menu options
-- **************************************************************************
function TitanPanelRightClickMenu_PrepareRegenMenu()
	local id = TITAN_REGEN_ID;
	local info;

	TitanPanelRightClickMenu_AddTitle(TitanPlugins[id].menuText);
		   
	info = {};
	info.text = L["TITAN_REGEN_MENU_SHOW2"];
	info.func = TitanRegen_ShowHPRegen;
	info.checked = TitanGetVar(TITAN_REGEN_ID,"ShowHPRegen");
	L_UIDropDownMenu_AddButton(info);

	info = {};
	info.text = L["TITAN_REGEN_MENU_SHOW4"];
	info.func = TitanRegen_ShowPercentage;
	info.checked = TitanGetVar(TITAN_REGEN_ID,"ShowPercentage");
	L_UIDropDownMenu_AddButton(info);

	TitanPanelRightClickMenu_AddSpacer();

	info = {};
	info.text = L["TITAN_PANEL_MENU_SHOW_COLORED_TEXT"];
	info.func = TitanRegen_ShowColoredText;
	info.checked = TitanGetVar(TITAN_REGEN_ID, "ShowColoredText");
	L_UIDropDownMenu_AddButton(info);          
	TitanPanelRightClickMenu_AddToggleLabelText("TitanRegen");
	TitanPanelRightClickMenu_AddToggleRightSide(TITAN_REGEN_ID);
	TitanPanelRightClickMenu_AddCommand(L["TITAN_PANEL_MENU_HIDE"], id, TITAN_PANEL_MENU_FUNC_HIDE);     
end

-- **************************************************************************
-- NAME : TitanRegen_UpdateSettings() 
-- DESC : Update button text on setting change
-- **************************************************************************
function TitanRegen_UpdateSettings()     
     -- safety in case both are off, then cant ever turn em on
     if (TitanGetVar(TITAN_REGEN_ID,"ShowHPRegen") == nil) then
          TitanSetVar(TITAN_REGEN_ID,"ShowHPRegen",1);
     end
     TitanPanelButton_UpdateButton(TITAN_REGEN_ID);
end

-- **************************************************************************
-- NAME : TitanRegen_ShowHPRegen()
-- DESC : Show HP regeneration option on button
-- **************************************************************************
function TitanRegen_ShowHPRegen()
     TitanToggleVar(TITAN_REGEN_ID, "ShowHPRegen");
     TitanRegen_UpdateSettings();
end

-- **************************************************************************
-- NAME : TitanRegen_ShowPercentage()
-- DESC : Show values as percentage option on button
-- **************************************************************************
function TitanRegen_ShowPercentage()
     TitanToggleVar(TITAN_REGEN_ID, "ShowPercentage");
     TitanRegen_UpdateSettings();
end

-- **************************************************************************
-- NAME : TitanRegen_ShowColoredText()
-- DESC : Show colored text option on button
-- **************************************************************************
function TitanRegen_ShowColoredText()
     TitanToggleVar(TITAN_REGEN_ID, "ShowColoredText");
     TitanRegen_UpdateSettings();
end