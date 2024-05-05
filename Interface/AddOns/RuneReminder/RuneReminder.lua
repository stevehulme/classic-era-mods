local addonName, _ns = ...
local RuneReminder = _G[addonName]
local initialX = 0
local initialY = 0
local spellIDMap = {}
local isEngravingRune = false 
local setToApply = nil
local settingRuneID = 0
local characterID = nil
local RuneSetsButton = nil
local RuneSetsDropdownMenu = nil
local currentProfile = nil

local CreateRuneButton, CreateOrUpdateRuneSelectionButtons, RefreshRuneSelectionButtons, toggleKeepOpen, UpdateButtonBehaviors, ApplyRuneSet, LoadRuneSet, UpdateRuneSetsButtonState, SaveRuneSet, ResetAllButtons, InitializeRRSettings, SetShownSlots, UpdateRunes
local UpdateSettingsFromProfile, SaveProfile, ApplyProfile, ResetSettings, ShowResetSettingsConfirmation, InitializeCharacterSettings, LoadProfileSettings, UpdateActiveProfileSettings
local ResetSettingsToDefault, DeleteProfile, OnSettingChanged
local Masque, MSQ_Version = LibStub("Masque", true)
local group
local L = LibStub("AceLocale-3.0"):GetLocale("RuneReminder", false)


-- Define frame 
local frame = CreateFrame("Frame", "RR_DragHandle", UIParent, "BackdropTemplate")
frame:SetParent(UIParent)
frame.Name = L["Rune Reminder"]


local text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
text:SetPoint("CENTER")
text:SetText("RR")
text:SetTextColor(0.67, 0.85, 0.92)  -- RGB for Blue
frame.text = text

-- LibStub initialization
local lib = LibStub:NewLibrary("RuneReminder", 1)

if not lib then
  return
end

if Masque then
	group = Masque:Group("RuneReminder", "RuneWidget")
end

local glowTextures = {
["CheckButtonHilight"] = "Buttons/CheckButtonHilight",
["ButtonHilight-Square"] ="Buttons/ButtonHilight-Square",
["UI-Icon-QuestBorder"] = "ContainerFrame/UI-Icon-QuestBorder",
}

local runeTextures = {
["INV_MISC_RUNE_01"] = "Interface/Icons/INV_MISC_RUNE_01",
["INV_MISC_RUNE_02"] = "Interface/Icons/INV_MISC_RUNE_02",
["INV_MISC_RUNE_03"] = "Interface/Icons/INV_MISC_RUNE_03",
["INV_MISC_RUNE_04"] = "Interface/Icons/INV_MISC_RUNE_04",
["INV_MISC_RUNE_05"] = "Interface/Icons/INV_MISC_RUNE_05",
["INV_MISC_RUNE_06"] = "Interface/Icons/INV_MISC_RUNE_06",
["INV_MISC_RUNE_07"] = "Interface/Icons/INV_MISC_RUNE_07",
["INV_MISC_RUNE_08"] = "Interface/Icons/INV_MISC_RUNE_08",
["INV_MISC_RUNE_09"] = "Interface/Icons/INV_MISC_RUNE_09",
["INV_MISC_RUNE_10"] = "Interface/Icons/INV_MISC_RUNE_10",
["INV_MISC_RUNE_11"] = "Interface/Icons/INV_MISC_RUNE_11",
["INV_MISC_RUNE_12"] = "Interface/Icons/INV_MISC_RUNE_12",
["INV_MISC_RUNE_13"] = "Interface/Icons/INV_MISC_RUNE_13",
["INV_MISC_RUNE_14"] = "Interface/Icons/INV_MISC_RUNE_14",
["INV_Misc_RUNEDORB_01"] = "Interface/Icons/INV_MISC_RUNEDORB_01",
["SPELL_SHADOW_RUNE"] = "Interface/Icons/SPELL_SHADOW_RUNE",
["SPELL_ICE_RUNE"] = "Interface/Icons/SPELL_ICE_RUNE",
["SPELL_HOLY_RUNE"] = "Interface/Icons/SPELL_HOLY_RUNE",
["SPELL_FIRE_RUNE"] = "Interface/Icons/SPELL_FIRE_RUNE",
["SPELL_ARCANE_RUNE"] = "Interface/Icons/SPELL_ARCANE_RUNE",
}

local runeTextureOrder = { }
for k in pairs(runeTextures) do
    tinsert(runeTextureOrder, k)
end
table.sort(runeTextureOrder)


-- Default settings
local defaults = {
    enabled = true,
    soundNotification = false,
    alternateLoad = false,
    hideReapplyButton = false,
    hideViewRunesButton = true,
	displayRunes = true,
	hideUnknownRunes = false,
	simpleTooltips = false,
    xOffset = 0,
    yOffset = 0,
	runeAlignment = "Horizontal",
	runeDirection = "Standard",
	disableGlow = false,
	enableChecked = false,
	keepOpen = false,
	disableSwapNotify = true,
	disableRemoveNotify = false,
	disableLeftClickKeepOpen = false,
	autoToggleOnHover = false,
	displayCooldown = true,
	displayCooldownText = false,
	tooltipAnchor = "ANCHOR_RIGHT",
	glowTexture = "Buttons/CheckButtonHilight",
	glowOpacity = 0.3,
	collapseRunesPanel = true,
	engravingMode = "TOGGLE",
	anchorPosition = "Normal",
	anchorVisible = true,
	anchorLocked = false,
	displayRuneSets = true,
	location = nil,
	charLocation = nil,
	toggleSets = true,
	runeSetsIcon = "Interface/Icons/INV_MISC_RUNE_06",
	toggleSetsTogglesAll = false,
	setEngraveOnLoad = true,
	hideHeadSlot = false,
	hideNeckSlot = false,
	hideShoulderSlot = false,
	hideChestSlot = false,
	hideWaistSlot = false,
	hideLegsSlot = false,
	hideFeetSlot = false,
	hideWristsSlot = false,
	hideHandsSlot = false,
	hideUnknownSlots = true,
	showSlotLabels = true,
	showSetsLabel = false,
	buttonLabelSize = 1.0
}



local validSlots = {
	[1] = "Head",
	[2] = "Neck",
	[3] = "Shoulder",
	[5] = "Chest",
	[6] = "Waist",
	[7] = "Legs",
	[8] = "Feet",
	[9] = "Wrists",
	[10] = "Hands"
}


local allSlots = {
	[1] = "Head",
	[2] = "Neck",
	[3] = "Shoulder",
	[4] = "Shirt",
	[5] = "Chest",
	[6] = "Waist",
	[7] = "Legs",
	[8] = "Feet",
	[9] = "Wrists",
	[10] = "Hands"
}

local invalidRunes = {
 [48274] = "Shadowfiend",
 [48859] = "Aspect of the Viper",
 [48164] = "Shadowstep",
 [48334] = "Commanding Shout"
}

local shownSlots = {
}

local currentRunes = {}
local currentGear = {}
local slotButtons = {}
local runeSelectionButtons = {}
local version = GetAddOnMetadata("RuneReminder", "Version")
local runeDetailsMap = {} 
local learnedRunes = {}
local knownSlots = {}

-- Function to deep copy tables
local function DeepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[DeepCopy(orig_key)] = DeepCopy(orig_value)
        end
        setmetatable(copy, DeepCopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end


local function collect_keys(t, sort)
	local _k = {}
	for k in pairs(t) do
		_k[#_k+1] = k
	end
	table.sort(_k, sort)
	return _k
end

local function sortedPairs(t, sort)
	local keys = collect_keys(t, sort)
	local i = 0
	return function()
		i = i+1
		if keys[i] then
			return keys[i], t[keys[i]]
		end
	end
end

local function initFrame(reset) 

	local buttonSize = RuneReminder_CurrentSettings.buttonSize or 25
	local dragsize = buttonSize/2
    frame:SetSize(dragsize,dragsize)
	
	if reset then
		RuneReminder_CurrentSettings.displayRunes = true
		RuneReminder_CurrentSettings.anchorVisible = true
		RuneReminder_CurrentSettings.anchorLocked = false
		frame:ClearAllPoints()
		frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
		RuneReminder_CurrentSettings.charLocation= {} 
		RuneReminder_CurrentSettings.charLocation["xOfs"]= 0
		RuneReminder_CurrentSettings.charLocation["yOfs"]= 0
		RuneReminder_CurrentSettings.charLocation["relativePoint"] = "CENTER"
	else
			frame:ClearAllPoints()
		if RuneReminder_CurrentSettings.charLocation and RuneReminder_CurrentSettings.charLocation ~= {} and RuneReminder_CurrentSettings.charLocation["relativePoint"] then
			frame:SetPoint(RuneReminder_CurrentSettings.charLocation["relativePoint"], UIParent, RuneReminder_CurrentSettings.charLocation["relativePoint"], RuneReminder_CurrentSettings.charLocation["xOfs"], RuneReminder_CurrentSettings.charLocation["yOfs"])
		else 
			-- re-center
			frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
			if not RuneReminder_CurrentSettings.charLocation then
				RuneReminder_CurrentSettings.charLocation = {}
			end
			RuneReminder_CurrentSettings.charLocation["xOfs"] = 0
			RuneReminder_CurrentSettings.charLocation["yOfs"] = 0
			RuneReminder_CurrentSettings.charLocation["relativePoint"] = "CENTER"
		end
	end
	
	if RuneReminder_CurrentSettings.displayRunes or RuneReminder_CurrentSettings.displayRuneSets then
	
		if not frame.texture then
			frame.texture = frame:CreateTexture(nil,"BACKGROUND")
			frame.texture:SetAllPoints(frame)
			frame.texture:SetColorTexture(0, 0, 0)
		end
		
		if RuneReminder_CurrentSettings.anchorVisible then
			frame.texture:SetAlpha(0.5)
			frame.text:SetAlpha(0.5)
		else
			frame.texture:SetAlpha(0)
			frame.text:SetAlpha(0)
		end
		
		if RuneReminder_CurrentSettings.anchorVisible then
		
			frame:SetScript("OnEnter", function(self)
		
				GameTooltip:SetOwner(self, RuneReminder_CurrentSettings.tooltipAnchor)
				
				-- Define the text based on settings
				local lockStatus = RuneReminder_CurrentSettings.anchorLocked and "locked" or "unlocked"
				local lockAction = RuneReminder_CurrentSettings.anchorLocked and "unlock" or "lock"
				local visibilityAction = RuneReminder_CurrentSettings.anchorVisible and "hide" or "show"

				GameTooltip:SetText(string.format("|cff2da3cf[%s]|r|cffabdaeb\n%s|r %s |cffabdaeb%s|r.\n|cffabdaeb%s |r+ |cffabdaeb%s|r %s |cffabdaeb%s|r.\n|cffabdaeb%s |r+ |cffabdaeb%s |r%s |cffabdaeb%s|r.\n|cffabdaeb%s |r%s |cffabdaeb%s|r.", 
				L["Rune Reminder"], 
				L["Left Click"], L["to"], L["Drag"],
				L["Left Click"], L["Ctrl"], L["to"], L["lock/unlock"],
				L["Left Click"], L["Shift"], L["to"], L["open the Options Panel"],
				L["Right Click"], L["to"], L["hide the anchor"]), 1, 1, 1, 1, true)

				GameTooltip:Show()
			end)
			frame:SetScript("OnLeave", function(self)
				GameTooltip:Hide()
			end)
		else
			frame:SetScript("OnEnter", nil)
			frame:SetScript("OnLeave", nil)
		end
		frame:Show()
	else 
		frame:Hide()
	end
	

	if RuneReminderOptionsPanel and RuneReminderOptionsPanel:IsVisible() then
		RuneReminderOptionsPanel:UpdateControls()
	end
	
end

local function setRunesPanelVisibility()
	if not RuneReminder_CurrentSettings then
		InitializeRRSettings()
	end
	
	local eMode = RuneReminder_CurrentSettings.engravingMode
	local showRunesPanel
	
	if eMode == "SHOW" then
		showRunesPanel = true
	elseif eMode == "HIDE" then
		showRunesPanel = false
	elseif eMode == "TOGGLE" then
		showRunesPanel = not RuneReminder_CurrentSettings.collapseRunesPanel
	end
	if showRunesPanel == true then
		if EngravingFrame and not EngravingFrame:IsVisible() then
			EngravingFrame:Show()
		end
	elseif EngravingFrame then
		EngravingFrame:Hide()
	end
end


local function InitializeRuneDetails()

	C_Engraving.ClearExclusiveCategoryFilter()
	C_Engraving.SetSearchFilter("")

	runeDetailsMap = {}
	learnedRunes = {}
	knownSlots = {}
	
    local categories = C_Engraving.GetRuneCategories(false, false)
    for _, category in ipairs(categories) do
        C_Engraving.ClearCategoryFilter(category)
        
        -- Fetch all runes for this category and populate runeDetailsMap
        local allRunes = C_Engraving.GetRunesForCategory(category, false)
        for _, rune in ipairs(allRunes) do
			if not invalidRunes[rune.skillLineAbilityID] then
				runeDetailsMap[rune.skillLineAbilityID] = {
					name = rune.name,
					category = category,
					iconTexture = rune.iconTexture 
				}
			end
        end
        -- Fetch only learned runes for this category and populate learnedRunes
        local learnedRunesInCategory = C_Engraving.GetRunesForCategory(category, true)
        for _, rune in ipairs(learnedRunesInCategory) do
			if not invalidRunes[rune.skillLineAbilityID] then
				learnedRunes[rune.skillLineAbilityID] = true
				knownSlots[category] = true
			end
        end
    end
end

local function GetSlotName(Identifier)
	return allSlots[Identifier]
end
local function GetSlotID(Name)
	return allSlots[Name]
end
local debugging = false;

-- Helper function to get the length of a table
local function tableLength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

-- Create a unique character ID
local function GetCharacterUniqueID()
    local name, realm = UnitFullName("player")
    return name .. "-" .. realm
end

-- Helper function to check if rune buttons for a slot are visible
local function AreRuneButtonsVisible(slotID)
    if runeSelectionButtons[slotID] then
        for _, button in ipairs(runeSelectionButtons[slotID]) do
            if button:IsVisible() then
                return true
            end
        end
    end
    return false
end

local function AreAnyRunesVisible()
	 for sID in pairs(validSlots) do
	  if AreRuneButtonsVisible(sID) then
		return true
	  end
	 end
	return false
end



local function GetRuneVisibilityState()
    local totalWithRunes = 0 
    local visibleCount = 0 

    -- Iterate through the rune selection buttons to count total and visible runes
    for slotID, buttons in pairs(runeSelectionButtons) do
        -- If this slot has one or more runes (buttons)
        if buttons and #buttons > 0 then
            totalWithRunes = totalWithRunes + 1 -- Increment the count of slots with runes

            -- Check if any button in this slot is visible
            if AreRuneButtonsVisible(slotID) then
                visibleCount = visibleCount + 1
            end
        end
    end

    -- Determine visibility state based on counts
    if visibleCount == 0 then
        return "None"
    elseif visibleCount == totalWithRunes then
        return "All"
    else
        return "Some"
    end
end

function IsRuneSpell(spellName)
    -- Check against runeDetailsMap to see if the spell name matches a known rune
    for _, runeDetails in pairs(runeDetailsMap) do
        if runeDetails.name == spellName then
            return true
        end
    end
    return false
end

function RefreshSpellIDMap()
    spellIDMap = {}  -- Clear the existing map to rebuild it

    local i = 1
    while true do
        local spellName = GetSpellBookItemName(i, BOOKTYPE_SPELL)

		if not spellName then
			break  -- No more spells
		end

		-- If already added, move on
		if not spellIDMap[spellName] then
			local name, rank, icon, castTime, minRange, maxRange, spellID, originalIcon = GetSpellInfo(spellName)
			
			-- If the spell name matches one of the known rune names, store it
			if IsRuneSpell(spellName) then 
				spellIDMap[spellName] = spellID
			end
		end

        i = i + 1
    end
end


function HideRuneSelectionButtons(slotID)
    if slotID and runeSelectionButtons[slotID] then
        -- Hide only the buttons for the specified slot
        for _, button in ipairs(runeSelectionButtons[slotID]) do
            button:Hide()
        end
    elseif not slotID then
        -- Hide all rune selection buttons across all slots
        for _, buttons in pairs(runeSelectionButtons) do
            for _, button in ipairs(buttons) do
                button:Hide()
            end
        end
    end
end


local function EngraveRune(slot, skillLineAbilityID)
	ClearCursor()
	 if skillLineAbilityID then
		C_Engraving.CastRune(skillLineAbilityID)
		if slot == "Hands" then
			CharacterHandsSlot:Click()
		elseif slot == "Chest" then
			CharacterChestSlot:Click()
		elseif slot == "Legs" then
			CharacterLegsSlot:Click()
		elseif slot == "Head" then
			CharacterHeadSlot:Click()
		elseif slot == "Neck" then
			CharacterNeckSlot:Click()
		elseif slot == "Feet" then
			CharacterFeetSlot:Click()
		elseif slot == "Shoulder" or slot == "Shoulders" then
			CharacterShoulderSlot:Click()
		elseif slot == "Wrists" or slot == "Wrist" then
			CharacterWristSlot:Click()
		elseif slot == "Waist" or slot == "Belt" then
			CharacterWaistSlot:Click()
		end

		ReplaceEnchant()
		StaticPopup_Hide("REPLACE_ENCHANT")
		
		ClearCursor()
	end
end

	PaperDollFrame:HookScript("OnShow", function(self)
		setRunesPanelVisibility()
	end)


function toggleKeepOpen()
	-- Grab the alternate value and update settings/options
	RuneReminder_CurrentSettings.keepOpen = not RuneReminder_CurrentSettings.keepOpen 
	RuneReminderOptionsPanel:UpdateControls()
	
	-- Then show/hide
	if RuneReminder_CurrentSettings.keepOpen then 
		RefreshRuneSelectionButtons(nil, true)
	else
		HideRuneSelectionButtons()
	end
end

local function ToggleOptionsPanel()
	if debugging then 
		print(InterfaceOptionsFrame:IsVisible())
		print(InterfaceOptionsFramePanelContainer.displayedPanel)
		print(RuneReminderOptionsPanel:IsVisible())
	end
    -- Check if the RuneReminderOptionsPanel is the currently open panel
    if RuneReminderOptionsPanel:IsVisible() then
        HideUIPanel(SettingsPanel)
		HideUIPanel(GameMenuFrame)
    else
        InterfaceOptionsFrame_OpenToCategory(RuneReminderOptionsPanel)
        InterfaceOptionsFrame_OpenToCategory(RuneReminderOptionsPanel) -- Twice due to Blizzard bug
    end
end


function ShowSlotButtonTooltip(button)
    -- Existing code for setting the tooltip owner, etc.
    GameTooltip:SetOwner(button, RuneReminder_CurrentSettings.tooltipAnchor)
    
    if button.runeInfo and button.runeInfo.skillLineAbilityID and not RuneReminder_CurrentSettings.simpleTooltips then
        -- Fetch the spell name from the runeInfo
        local spellName = button.runeInfo.name  -- Assuming this is the same as the spell's name
        
        -- Find the spell ID using the spell name
        local spellID = spellIDMap[button.runeInfo.name]
		
        if spellID then
            GameTooltip:SetSpellByID(spellID)
        else
            -- Fallback to normal tooltip
			if button.runeInfo and button.runeInfo.skillLineAbilityID and not RuneReminder_CurrentSettings.simpleTooltips then
				GameTooltip:SetEngravingRune(button.runeInfo.skillLineAbilityID) -- Show detailed tooltip for the rune
			else
				GameTooltip:ClearLines()
			   local runeName = button.runeInfo and button.runeInfo.name or L["No Rune"]
				GameTooltip:AddLine(runeName, 0.67, 0.85, 0.92) 
			   GameTooltip:AddLine(button.slotName .. (button.runeInfo and L[" Engraved"] or L[": No Rune"]), 0, 0.55, 0)
		   end
        end
    elseif RuneReminder_CurrentSettings.simpleTooltips then
		GameTooltip:ClearLines()
		local runeName = button.runeInfo and button.runeInfo.name or L["No Rune"]
		GameTooltip:AddLine(runeName, 0.67, 0.85, 0.92) 
		GameTooltip:AddLine(button.slotName .. (button.runeInfo and L[" Engraved"] or L[" Not Engraved"]), 0, 0.55, 0)
	else 
        -- Fallback for no runeInfo scenario
        GameTooltip:ClearLines()
        GameTooltip:AddLine(button.slotName..L[": No Rune Engraved"])
    end
    GameTooltip:Show()
end

-- Function to show tooltip for rune buttons
function ShowRuneButtonTooltip(button)
    GameTooltip:SetOwner(button, RuneReminder_CurrentSettings.tooltipAnchor)
    if button.skillLineAbilityID and not RuneReminder_CurrentSettings.simpleTooltips then
        GameTooltip:SetEngravingRune(button.skillLineAbilityID) -- Show detailed tooltip for the rune
    else
        GameTooltip:ClearLines() -- Clear existing lines
        GameTooltip:AddLine(button.runeInfo.name, 0.67, 0.85, 0.92)
		if learnedRunes[button.runeInfo.skillLineAbilityID] then
			GameTooltip:AddLine(L["Click to Engrave "] .. button.slotName, 0, 1, 0)
		else
			GameTooltip:AddLine(L["Not Collected"], 1.0, 0.5, 0.0)
		end
    end
    GameTooltip:Show()
end

function HideRuneButtonTooltip()
    GameTooltip:Hide()
end

function ShowRuneWarning(message, sound)
	local r, g, b = 1.0, 0.5, 0.0  -- RGB for orange color
	sound = sound or true
	
	UIErrorsFrame:AddMessage(message, r, g, b, 1.0)  
	if sound then
		PlaySound(846) 
	end
end


function CreateRuneButton(slotID, rune, index)
	local button 
	
	--CreateFrame("Button", nil, frame, "SecureActionButtonTemplate")
	button = CreateFrame("Button", "RuneReminder_"..slotID.."_"..index.."Button", frame, "ActionButtonTemplate")
	
	local size = RuneReminder_CurrentSettings.buttonSize or 25
    button:SetSize(size, size) 
    button:SetPoint("TOPLEFT", frame, "TOPRIGHT", ((index * 2) - 1), -100) -- Position next to the main button
    
    button.skillLineAbilityID = rune.skillLineAbilityID
	local slotName = GetSlotName(slotID)
	
	
	if debugging then
		print("|cff2da3cf[Rune Reminder]|r CreateRuneButton(" .. slotName .. "," .. rune.name .. "," .. index .. ")")
	end

	-- 0.18, 0.64, 0.81  -- RGB for color code 'cff2da3cf'
	button:SetScript("OnMouseDown", function(self, mouseButton)
		
		
		local spell = UnitCastingInfo("player")

		if mouseButton == "RightButton" then 
			local runeState = GetRuneVisibilityState()
			PlaySound(867)
			if runeState == "All" then
				HideRuneSelectionButtons()	
			else
				RefreshRuneSelectionButtons(nil, true)
			end
		elseif IsShiftKeyDown() and mouseButton == "LeftButton" then
			ToggleOptionsPanel()
	   elseif UnitIsDeadOrGhost("player") then
			ShowRuneWarning(L["Runes cannot be applied while dead"]) 
		elseif InCombatLockdown() then
			ShowRuneWarning(L["Runes cannot be applied during combat"])
		elseif IsPlayerMoving() or IsFlying() or IsFalling() then
			ShowRuneWarning(L["Runes cannot be applied while moving"])
		--elseif IsMounted() then
		--	Dismount();
			--ShowRuneWarning(L["Runes cannot be applied while mounted"])
		elseif spell then
			ShowRuneWarning(L["Runes cannot be applied while casting"])
		elseif not learnedRunes[rune.skillLineAbilityID] then
			ShowRuneWarning(L["Rune must be collected first"])
		else
			if IsMounted() then
				Dismount();
			end
			if not RuneReminder_CurrentSettings.keepOpen then
				HideRuneSelectionButtons(slotID)
			end
			EngraveRune(slotName, rune.skillLineAbilityID)
		end
	end)
	

    button:SetScript("OnEnter", function()
        GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
			if rune.skillLineAbilityID and not RuneReminder_CurrentSettings.simpleTooltips then
				GameTooltip:SetEngravingRune(rune.skillLineAbilityID) -- Show detailed tooltip for the rune
			else
				GameTooltip:ClearLines()
				GameTooltip:AddLine(rune.name, 0.67, 0.85, 0.92) -- Rune name in custom color
				if learnedRunes[rune.skillLineAbilityID] then
					GameTooltip:AddLine(L["Click to Engrave "] .. slotName, 0, 1, 0) -- Instructions in green
				end
			end
        GameTooltip:Show()
    end)

    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
	if debugging then
		print("End of Create Rune Button"..rune.iconTexture)
	end
	button.runeInfo = rune
	button.slotName = slotName
	--button:SetTexture(rune.iconTexture)
	
		local texture = button:CreateTexture("Texture", "Background")
		texture:SetTexture(rune.iconTexture) -- Default texture for visibility
		texture:SetAllPoints(button)
		
		button:SetNormalTexture(texture)
		
		local size = RuneReminder_CurrentSettings.buttonSize
		
		if not learnedRunes[rune.skillLineAbilityID] then
			if Masque then
				texture:SetTexCoord(.08, .92, .08, .92)
				texture:SetDesaturated(true) 
			else
				local shaderSupported = texture:SetDesaturated(1);
				if (not shaderSupported) then
					texture:SetVertexColor(0.5, 0.5, 0.5);
				end
				--button:SetDisabledTexture(rune.iconTexture)
				--button.texture = button:GetDisabledTexture()
				--button.texture:SetDesaturated(true)
			end
		else 
			if Masque then
				texture:SetTexCoord(.08, .92, .08, .92)
				--button.texture:SetSize(size * 0.85, size * 0.85)
			end
		end

    return button
end
local function CreateOrUpdateRuneSelectionButtons(slotID, showRunes)
    local buttonSize = RuneReminder_CurrentSettings.buttonSize or 25
    local padding = RuneReminder_CurrentSettings.buttonPadding or 1
    local alignment = RuneReminder_CurrentSettings.runeAlignment or "Horizontal"
    local direction = RuneReminder_CurrentSettings.runeDirection or "Standard"
	
	local slotName = GetSlotName(slotID)
	
	if debugging then
		print("CreateOrUpdateRuneSelectionButtons"..slotID)
	end

	
		C_Engraving.ClearCategoryFilter(slotID)
		C_Engraving.ClearExclusiveCategoryFilter()
		C_Engraving.SetSearchFilter("")

		if not learnedRunes then
			InitializeRuneDetails()
		end

        local allRunes = C_Engraving.GetRunesForCategory(slotID, RuneReminder_CurrentSettings.hideUnknownRunes)
        local filteredRunes = {}
        for _, rune in ipairs(allRunes) do
			if debugging then
				print("rune: ".. rune.name)
				print(rune.skillLineAbilityID)
			end

			if not invalidRunes[rune.skillLineAbilityID] then
						if not (currentRunes[slotID] and rune.skillLineAbilityID == currentRunes[slotID].skillLineAbilityID) then
							table.insert(filteredRunes, rune)
						end
			end

        end

        runeSelectionButtons[slotID] = runeSelectionButtons[slotID] or {}

        for i, rune in ipairs(filteredRunes) do
            local button = runeSelectionButtons[slotID][i]
            if not button then
                button = CreateRuneButton(slotID, rune, i)
                runeSelectionButtons[slotID][i] = button
					if debugging then
						--print ("In create or update"..button.iconTexture)
						--print("pt2"..rune.iconTexture)
					end
				if Masque then
					button:SetFrameLevel(0)
					group:AddButton(button)
				end
					
            else
				if Masque then
					button:SetFrameLevel(0)
					group:AddButton(button)
				end
                button.skillLineAbilityID = rune.skillLineAbilityID
				
            end
			
			local texture = button.texture
			
			if not texture then
				texture = button:CreateTexture("Texture", "Background")
				texture:SetTexture(rune.iconTexture) 
				texture:SetAllPoints(button)
			end
			

		
			if not learnedRunes[rune.skillLineAbilityID] then
				if Masque then
					texture:SetDesaturated(true) 
					texture:SetTexCoord(.08, .92, .08, .92)
					button.texture = texture
					button:SetFrameLevel(0)
					--button.texture:SetSize(buttonSize * 0.85, buttonSize * 0.85)
				else
					local shaderSupported = texture:SetDesaturated(1);
					if (not shaderSupported) then
						texture:SetVertexColor(0.5, 0.5, 0.5);
					end
				
					button:SetDisabledTexture(rune.iconTexture)
					button.texture = button:GetDisabledTexture()
					button.texture:SetDesaturated(true)
					
				end
			else
				if Masque then
					texture:SetTexCoord(.08, .92, .08, .92)
					--button.texture:SetSize(buttonSize * 0.85, buttonSize * 0.85)
				end
				button.texture = texture
			end
			
			
			button.runeInfo = rune
			button.slotName = slotName

            -- Update button position
            local xPos, yPos = 0, 0
            if alignment == "Horizontal" then
                yPos = (direction == "Standard" and -1 or 1) * (i * (buttonSize + padding))
            else
                xPos = (direction == "Standard" and 1 or -1) * (i * (buttonSize + padding))
            end

            button:SetPoint("TOPLEFT", slotButtons[slotID], "TOPLEFT", xPos, yPos)

            if showRunes and shownSlots[slotID] then
                button:Show()
            else
                button:Hide()
            end
        end

		

        -- Remove extra buttons if any
        for i = #filteredRunes + 1, #runeSelectionButtons[slotID] do
            local extraButton = runeSelectionButtons[slotID][i]
            if extraButton then
                extraButton:Hide()
                extraButton:SetParent(nil)
                runeSelectionButtons[slotID][i] = nil
            end
        end
		
		if not shownSlots[slotID] then
			runeSelectionButtons[slotID] = nil
		end
	UpdateButtonBehaviors()
end

function RefreshRuneSelectionButtons(slotID, forceshow)

    -- Determine if buttons were previously visible
    local wereButtonsVisible = false
	
	  for sID in pairs(validSlots) do	
	    local learnedRunesInCategory = C_Engraving.GetRunesForCategory(sID, true)
        for _, rune in ipairs(learnedRunesInCategory) do
            learnedRunes[rune.skillLineAbilityID] = true
			knownSlots[sID] = true
        end
		
		
		
		if slotID == nil or slotID == sID then
			if runeSelectionButtons[sID] then
				for _, button in ipairs(runeSelectionButtons[sID]) do
					if button:IsVisible() then
						wereButtonsVisible = true
						button:Hide()

					end
				end

				runeSelectionButtons[sID] = {}	
			end
			-- KeepOpen
			if RuneReminder_CurrentSettings.keepOpen and RuneReminder_CurrentSettings.disableLeftClickKeepOpen or forceshow then  
				wereButtonsVisible = true
			end
			
			if not shownSlots[sID] then
				wereButtonsVisible = false
			end
		-- Always refresh the buttons with correct data
		CreateOrUpdateRuneSelectionButtons(sID, wereButtonsVisible)
		end

    end
	
	UpdateButtonBehaviors()
end


-- Function to get detailed rune information by its ID
local function GetRuneDetailsFromID(runeID)

	if not runeDetailsMap or not learnedRunes then
		InitializeRuneDetails()
	end

    local runeDetails = runeDetailsMap[runeID]
    if runeDetails then
        return runeDetails
    else
        return nil 
    end
end

-- Function to identify differences between two sets of runes
local function GetDifferencesBetweenSets(currentSet, setToLoad)
    local differences = {}

    -- Check for runes in setToLoad that are different from or not present in currentSet
    for slotID, newRuneID in pairs(setToLoad) do
        if not currentSet[slotID] or currentSet[slotID].skillLineAbilityID ~= newRuneID then
            differences[slotID] = newRuneID
        end
    end
    return differences
end

local function SaveCurrentRuneSet()
    StaticPopup_Show("SAVE_RUNE_SET")
end

RuneSetsDropdownMenu = CreateFrame("Frame", "RR_RuneSetsDropdownMenu", Frame, "UIDropDownMenuTemplate")
RuneSetsDropdownMenu.displayMode = "MENU"
RuneSetsDropdownMenu:SetParent(UIParent)

RuneSetsDropdownMenu = CreateFrame("Frame", "RR_RuneSetsDropdownDelMenu", Frame, "UIDropDownMenuTemplate")
RuneSetsDropdownMenu.displayMode = "MENU"
RuneSetsDropdownMenu:SetParent(UIParent)
		
local function HideDropdownMenu()
    if UIDropDownMenu_GetCurrentDropDown() == RuneSetsDropdownMenu or UIDropDownMenu_GetCurrentDropDown() == RuneSetsDropdownMenu   then
        CloseDropDownMenus()
    end
end
local hideDropdownTimer

local function CreateMenuItem(setName, setDetails)
    local info = UIDropDownMenu_CreateInfo()
    info.text = L["Load Set: "]..setName
    info.notCheckable = true
    info.func = function(_, setName) UpdateRuneSetsButtonState(setName, RuneReminder_CurrentSettings.setEngraveOnLoad) end
    info.arg1 = setName
	
	
	local different = false
	local toolTip = ""
	local equipped = 0
	local total = 0
	
    for slotID, runeID in pairs(setDetails) do
		local runeDetails = GetRuneDetailsFromID(runeID)
		local slotName = GetSlotName(slotID)
		local currentRune = currentRunes[slotID]
		local runeName = runeDetails and "|cffabdaeb"..runeDetails.name or L["Unknown"]
		if currentRune and currentRune.skillLineAbilityID == runeID then
			runeName = string.format("%s |cff008500(%s)|r", runeName, L["active"])
			equipped = equipped + 1
		else
			different = true
		end
		toolTip = toolTip..slotName .. ": " .. runeName .. "|r\n"
		total = total + 1
	end

	if different then
		info.tooltipTitle = L["Rune Set"] .. ": " .. setName .. " (" .. equipped .. "/" .. total .. " " .. L["active"] .. ")"
	else
		info.tooltipTitle = L["Rune Set"] .. ": " .. setName .. " |cff007500(" .. equipped .. "/" .. total .. " " .. L["active"] .. ")"

	end
	info.tooltipText = toolTip

    return info
end

local function DisplayRuneSetsMenu()
    local runeSets = RR_RuneSets[characterID] or {}
    UIDropDownMenu_Initialize(RuneSetsDropdownMenu, function(self, level, menuList)
        local info = UIDropDownMenu_CreateInfo()
        info.notCheckable = true

        -- Cancel button
        info.text = L["Cancel"]
        info.func = HideDropdownMenu
        UIDropDownMenu_AddButton(info)

        -- Load set options
        for setName, setDetails in pairs(runeSets) do
            local menuItem = CreateMenuItem(setName, setDetails)
            UIDropDownMenu_AddButton(menuItem)
        end

        -- Save runes as new set
        info.text = L["Save Current Runes as Set"]
        info.func = SaveCurrentRuneSet
        UIDropDownMenu_AddButton(info)
    end, "MENU")

    ToggleDropDownMenu(1, nil, RuneSetsDropdownMenu, "cursor", -20, 20)
end

local function PrepDeleteRuneSet(setName)

 StaticPopupDialogs["CONFIRM_DELETE_RUNE_SET"] = {
    text = string.format("|cff2da3cf[%s]|r\n%s '%s'?",
            L["Rune Reminder"],
            L["Are you sure you want to delete the Rune Set"],
            setName or L["Invalid Set Name"]
        )
    ,
    button1 = L["Yes"],
    button2 = L["No"],
    enterClicksFirstButton = true,
    OnAccept = function(self)  
        DeleteRuneSet(setName, true)  
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    hasEditBox = false,
    preferredIndex = 3, -- avoid taint from UIParent dialogs
}

 StaticPopup_Show("CONFIRM_DELETE_RUNE_SET")
 

end

local function DisplayRuneSetsDelMenu()

    local runeSets = RR_RuneSets[characterID] or {}

    UIDropDownMenu_Initialize(RuneSetsDropdownMenu, function(self, level, menuList)
        local info = UIDropDownMenu_CreateInfo()
        info.notCheckable = true

		info.text = L["Cancel"]
        info.func = HideDropdownMenu
        UIDropDownMenu_AddButton(info)

        for setName, _ in pairs(runeSets) do
            info.text = L["Delete Set: "]..setName
            info.func = function(_, setName) PrepDeleteRuneSet(setName) end
            info.arg1 = setName
            UIDropDownMenu_AddButton(info)
        end

    end, "MENU")

    ToggleDropDownMenu(1, nil, RuneSetsDropdownMenu, "cursor", -20, 20)

end
local function CreateRuneSetsButton()

	if RuneReminder_CurrentSettings.displayRuneSets then
		local alignment = RuneReminder_CurrentSettings.runeAlignment or "Horizontal"
		local size = RuneReminder_CurrentSettings.buttonSize or 25
		local padding = RuneReminder_CurrentSettings.buttonPadding or 1
		local button = RuneSetsButton
		
		local cooldownFont = "Fonts\\FRIZQT__.TTF" 
		local cooldownFontSize = size/2 
		local slotFontSize = (cooldownFontSize/2.28) * (RuneReminder_CurrentSettings.buttonLabelSize or 1.0)
		
		if not button then
			button = CreateFrame("Button", "RuneReminder_SetButton", frame, "ActionButtonTemplate")
		elseif RuneReminder_CurrentSettings.displayRuneSets then
			button:Show()
		else
			button:Hide()
		end
		
		button:SetSize(size, size)

		if not button.texture then
			local texture = button:CreateTexture("Texture", "Background")
			texture:SetTexture(RuneReminder_CurrentSettings.runeSetsIcon)
			texture:SetAllPoints(button)
			
			if Masque then
				texture:SetTexCoord(.08, .92, .08, .92)
				button.texture = button:GetNormalTexture()
				group:AddButton(button)
			else
				button:SetPushedTexture(texture)
				button:SetNormalTexture(texture)
				button.texture = texture--button:GetNormalTexture()
			end
		end
		

		--local text = button:CreateFontString(nil, "OVERLAY")
		--text:SetPoint("BOTTOM", 0, 1)
		--text:SetFont(cooldownFont, slotFontSize, "OUTLINE")
		--text:SetText(L["Sets"])
		--button.text = text
		
		--if RuneReminder_CurrentSettings.showSetsLabel then
		--	button.text:Show()
		--else
		--	button.text:Hide()
		--end

		button:SetScript("OnEnter", function()
		
		 GameTooltip:SetOwner(button, RuneReminder_CurrentSettings.tooltipAnchor)
				GameTooltip:ClearLines()
				GameTooltip:AddLine(string.format("|cff2da3cf%s|r %s\n", L["Rune Reminder"], L["Rune Sets"]), 1, 1, 1)
				GameTooltip:AddLine(string.format("|cffabdaeb%s |r%s |cffabdaeb%s |r%s \n|cffabdaeb%s %s|r %s |cffabdaeb%s|r %s", L["Left Click"], L["to"], L["Save or Load"], L["Rune Sets"], L["Alt"], L["Click"], L["to"], L["Delete"], L["Rune Sets"]), 1, 1, 1)

				if RuneReminder_CurrentSettings.toggleSets then
					GameTooltip:AddLine(string.format("|cffabdaeb%s|r %s |cffabdaeb%s|r %s", L["Right Click"], L["to"], L["Toggle"], L["Rune Slots"]), 1, 1, 1)
				end
			GameTooltip:Show()
		end)
		button:SetScript("OnLeave", function()
			GameTooltip:Hide()
			if debugging then
				print("|cff2da3cf[Rune Reminder]|r Run OnLeave - RuneSets")
			end
		end)
		
		
		-- Update position based on alignment
		if alignment == "Horizontal" then
			button:SetPoint("TOPLEFT", frame, "TOPRIGHT", 0, 0)
		else
			button:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, 0)
		end
		
		button:SetScript("OnMouseUp", function(self, mouseButton)
			if mouseButton == "LeftButton" then
				if IsShiftKeyDown() then
					ToggleOptionsPanel()
				elseif IsAltKeyDown() then
					DisplayRuneSetsDelMenu()
				else
					DisplayRuneSetsMenu()
				end
			elseif mouseButton == "RightButton" then
				if RuneReminder_CurrentSettings.toggleSets then
					RuneReminder_CurrentSettings.displayRunes = not RuneReminder_CurrentSettings.displayRunes
					if RuneReminderOptionsPanel:IsVisible() then
						RuneReminderOptionsPanel:UpdateControls()
					end
					if RuneReminder_CurrentSettings.displayRunes and RuneReminder_CurrentSettings.toggleSetsTogglesAll then
						RefreshRuneSelectionButtons(nil, true)
					else
						HideRuneSelectionButtons()
					end
					
					ResetAllButtons()
					UpdateActiveProfileSettings()
				else 
				
				end
			end
		
		end)
		
		RuneSetsButton = button
			
	elseif RuneSetsButton then
			RuneSetsButton:Hide()
			RuneSetsButton = nil
	end


end

function UpdateRuneSetsButtonState(set, beginImmediately)
	if set then
		setToApply = set
	end

	InitializeRuneDetails()

    if setToApply and RuneSetsButton then

        local setToLoad = RR_RuneSets[characterID] and RR_RuneSets[characterID][setToApply]
        local differences = GetDifferencesBetweenSets(currentRunes, setToLoad)

		if differences then
			local slotID, nextRuneID = next(differences)
			local slotName = GetSlotName(slotID)

			if nextRuneID then
				-- Update to the icon of the next rune to be applied
				RuneSetsButton.texture:Hide()
				RuneSetsButton.texture = nil
				local runeDetails = GetRuneDetailsFromID(nextRuneID)
				local texture = RuneSetsButton:CreateTexture("Texture", "Artwork")
				texture:SetTexture(runeDetails.iconTexture)
				texture:SetAllPoints(RuneSetsButton)
				
				if Masque then
					group:RemoveButton(RuneSetsButton)
					texture:SetTexCoord(.08, .92, .08, .92)
					RuneSetsButton.texture = RuneSetsButton:GetNormalTexture()
					group:AddButton(RuneSetsButton)
				else
					RuneSetsButton:SetPushedTexture(texture)
					RuneSetsButton:SetNormalTexture(texture)
					RuneSetsButton.texture = texture--button:GetNormalTexture()
				end				
				
				RuneSetsButton:SetScript("OnMouseUp", function(self, mouseButton)
				

					if mouseButton == "RightButton" then
						setToApply = nil
						RuneSetsButton:Hide()
						RuneSetsButton = nil
						CreateRuneSetsButton()
				
					elseif mouseButton == "LeftButton" then
					
						if UnitIsDeadOrGhost("player") then
							ShowRuneWarning(L["Runes cannot be applied while dead"])
						elseif InCombatLockdown() then
							ShowRuneWarning(L["Runes cannot be applied during combat"])
						elseif IsPlayerMoving() or IsFlying() or IsFalling() then
							ShowRuneWarning(L["Runes cannot be applied while moving"])
						--elseif IsMounted() then
							--ShowRuneWarning(L["Runes cannot be applied while mounted"])
						elseif spell then
							ShowRuneWarning(L["Runes cannot be applied while casting"])
						else
							if IsMounted() then
								Dismount();
							end
							ApplyRuneSet(setToLoad, setToApply)
						end
					end
					
				end)
				
				ActionButton_ShowOverlayGlow(RuneSetsButton)
				
					RuneSetsButton:SetScript("OnEnter", function()
					 GameTooltip:SetOwner(RuneSetsButton, RuneReminder_CurrentSettings.tooltipAnchor)
							GameTooltip:ClearLines() -- Clear existing lines
							GameTooltip:AddLine(string.format("|cff2da3cf%s|r\n%s: %s\n%s |cffabdaeb%s|r %s %s", L["Rune Reminder"], L["Rune Set"], setToApply, L["Apply"], runeDetails.name, L["to"], slotName), 1, 1, 1)
						GameTooltip:Show()
					end)
					RuneSetsButton:SetScript("OnLeave", function()
						GameTooltip:Hide()
						if debugging then
							print("|cff2da3cf[Rune Reminder]|r Run OnLeave - " .. slotName)
						end
					end)
			elseif not set then
				-- Revert to default 
				print(string.format("|cff2da3cf[%s]|r %s |cffabdaeb%s|r %s.", L["Rune Reminder"], L["Rune Set"], setToApply, L["is now active"]))

				setToApply = nil -- Clear the currently applying set
					if RuneSetsButton then
						RuneSetsButton:SetScript("OnMouseUp", function(self, mouseButton)
								if mouseButton == "LeftButton" then
									if IsShiftKeyDown() then
										ToggleOptionsPanel()
									elseif IsAltKeyDown() then
										DisplayRuneSetsDelMenu()
									else
										DisplayRuneSetsMenu()
									end
								elseif mouseButton == "RightButton" then
									if RuneReminder_CurrentSettings.toggleSets then
										RuneReminder_CurrentSettings.displayRunes = not RuneReminder_CurrentSettings.displayRunes
										if RuneReminderOptionsPanel:IsVisible() then
											RuneReminderOptionsPanel:UpdateControls()
										else 
											UpdateActiveProfileSettings()
										end
										
										if RuneReminder_CurrentSettings.displayRunes and RuneReminder_CurrentSettings.toggleSetsTogglesAll then
											RefreshRuneSelectionButtons(nil, true)
										else
											HideRuneSelectionButtons()
										end
										
										ResetAllButtons()
									else 
									
									end
								end
							
							end)
							
					ActionButton_HideOverlayGlow(RuneSetsButton)
					
					
				end
			else 
				ShowRuneWarning(string.format("%s %s %s.", L["Rune Set"], setToApply, L["is already active"]), sound)
				print(string.format("|cff2da3cf[%s]|r %s |cffabdaeb%s|r %s.", L["Rune Reminder"], L["Rune Set"], setToApply, L["is already active"]))
				setToApply = nil -- Clear the currently applying set
				ActionButton_HideOverlayGlow(RuneSetsButton)
			end
		else
			-- Default state
			RuneSetsButton:SetScript("OnMouseUp", DisplayRuneSetsMenu)
			print(string.format("|cff2da3cf[%s]|r %s |cffabdaeb%s|r %s", L["Rune Reminder"], L["Rune Set"], setToApply, L["is already active"]))
		end
		
		if beginImmediately then
			local setToLoad = RR_RuneSets[characterID] and RR_RuneSets[characterID][setToApply]
			ApplyRuneSet(setToLoad, setToApply)
		end
    end
end






local function CreateSlotButtons(forcereset)
    if debugging then
        print("Creating or updating slot buttons")
    end
	
	local size = RuneReminder_CurrentSettings.buttonSize or 25
	local padding = RuneReminder_CurrentSettings.buttonPadding or 1

    -- Check if displayRunes is enabled
    local displayRunes = RuneReminder_CurrentSettings.displayRunes or false
	
    if not displayRunes then
        HideRuneSelectionButtons()
    end
	
	if forcereset then
		-- Clear existing buttons or reset their positions
		for _, button in pairs(slotButtons) do
			button:Hide() 
			if Masque then
				group:RemoveButton(button)
			end
			
		end
		
	end

	local count = 0
	
	if RuneReminder_CurrentSettings.displayRuneSets then
		if not RuneSetsButton then
			CreateRuneSetsButton()
		end
		count = 1
	end

	local alignment = RuneReminder_CurrentSettings.runeAlignment or "Horizontal"
	local buttonSpacing = size + padding

	-- Define a font for cooldown text
	local cooldownFont = "Fonts\\FRIZQT__.TTF" 
	local buttonSize = RuneReminder_CurrentSettings.buttonSize or 25
	local cooldownFontSize = buttonSize/2 
	local slotFontSize = (cooldownFontSize/2.28) * (RuneReminder_CurrentSettings.buttonLabelSize or 1.0)


    for slotID, slotName in sortedPairs(shownSlots) do
        local button = slotButtons[slotID]
		
		if debugging then
			print("Button for:"..slotID)
		end
        if not button then
            -- Create button if it doesn't exist
			button = CreateFrame("CheckButton", "RuneReminder_"..slotName.."Button", frame, "ActionButtonTemplate")

			button:SetSize(size, size)
			button.slotID = slotID
			button.slotName = slotName

			-- Create a cooldown frame if it doesn't exist
			button.cooldown = CreateFrame("Cooldown", "$parentCooldown", button, "CooldownFrameTemplate")
			button.cooldown:SetAllPoints()  -- Make the cooldown cover the entire button
			
			button.cooldownText = button.cooldown:CreateFontString(nil, "OVERLAY")
			button.cooldownText:SetFont(cooldownFont, cooldownFontSize, "OUTLINE")
			button.cooldownText:SetPoint("CENTER", 0, 0)

			button:SetChecked(false)

			local text = button:CreateFontString(nil, "OVERLAY")
			text:SetPoint("BOTTOM", 0, 2)
			text:SetFont(cooldownFont, slotFontSize, "OUTLINE")
			text:SetText(L[slotName])
			button.text = text

			if debugging then
				print("not button")
			end
			
			if Masque then
				group:AddButton(button)
			end
			
            button:SetScript("OnMouseDown", function(self, mouseButton)
			local r, g, b = 1.0, 0.5, 0.0  -- RGB for orange color
			C_Engraving.ClearCategoryFilter(slotID)
			C_Engraving.ClearExclusiveCategoryFilter()
			C_Engraving.SetSearchFilter("")
			
		
			local runes = C_Engraving.GetRunesForCategory(slotID, RuneReminder_CurrentSettings.hideUnknownRunes)

			if mouseButton == "RightButton" then 
				local runeState = GetRuneVisibilityState()
				PlaySound(867)
				if runeState == "All" then
					HideRuneSelectionButtons()	
				else
					RefreshRuneSelectionButtons(nil, true)
				end
			elseif IsShiftKeyDown() and mouseButton == "LeftButton" then
				-- Logic to open the options panel
				ToggleOptionsPanel()
			elseif RuneReminder_CurrentSettings.keepOpen and RuneReminder_CurrentSettings.disableLeftClickKeepOpen then
					CreateOrUpdateRuneSelectionButtons(slotID, true)
			else
				   if #runes == 0 or (currentRunes[slotID] and #runes == 1) then
				  
						UIErrorsFrame:AddMessage(L["No runes available for "].. slotName..".", r, g, b, 1.0)
						PlaySound(846) 
					else
						PlaySound(867)
						local shouldShowRunes = not AreRuneButtonsVisible(slotID)
						if debugging then
							print("inc create or update?:"..slotID)
						end
						--RefreshRuneSelectionButtons(slotID, shouldShowRunes)
						CreateOrUpdateRuneSelectionButtons(slotID, shouldShowRunes)
						RefreshRuneSelectionButtons(slotID, shouldShowRunes)
					end
				end

			end)
			
			button:SetScript("OnClick", function(self, mouseButton)
					if not currentRunes[slotID] or not RuneReminder_CurrentSettings.enableChecked then
						button:SetChecked(false)
					elseif RuneReminder_CurrentSettings.enableChecked then 
						button:SetChecked(true)
					end
			end)

		slotButtons[slotID] = button
	else -- if button exists, check if it should glow, and adjust as necessary
		if debugging then
			print("else:"..slotID)
		end
		if Masque then
			group:AddButton(button)
		end
		if not currentRunes[slotID] then
			button:SetChecked(false)
		elseif RuneReminder_CurrentSettings.enableChecked then
			button:SetChecked(true)
		end
	end
	

		
		if RuneReminder_CurrentSettings.showSlotLabels then
			button.text:Show()
		else
			button.text:Hide()
		end
	
        -- Update position based on alignment
        if alignment == "Horizontal" then
            button:SetPoint("TOPLEFT", frame, "TOPRIGHT", (count * buttonSpacing), 0)
        else
            button:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, -(count * buttonSpacing))
        end
		
		if debugging then
			print("Button created for slotID:", slotID)
		end

        
        if displayRunes then
            button:Show()
        else
            button:Hide()
        end

        if debugging then
            print("Button updated for slotID:", slotID, "at position:", count * 26, 0)
        end
        count = count + 1
    end

	UpdateButtonBehaviors()
end

-- Helper Function: Get cooldown information for an ability associated with a rune
local function GetRuneCooldown(spellName)
    local start, duration, enabled = GetSpellCooldown(spellName)
    return start, duration, enabled 
end

-- Update the Rune Slot Button with Cooldown Information
local function UpdateRuneSlotCooldown(button, spellName)
    local start, duration, enabled = GetRuneCooldown(spellName)

    -- Check if the cooldown is significant (more than just the GCD)
    if start and duration and duration > 1.5 then
        button.cooldown:SetCooldown(start, duration)

        -- Update the cooldown text periodically
        button:SetScript("OnUpdate", function(self, elapsed)
            if RuneReminder_CurrentSettings.displayCooldown then
                local remaining = duration - (GetTime() - start)

                if remaining > 0 then
                    -- Display tenths when under 5 seconds
					if RuneReminder_CurrentSettings.displayCooldownText then
						if remaining < 5 then
							self.cooldownText:SetText(string.format("%.1f", remaining))
						else
							self.cooldownText:SetText(math.floor(remaining))
						end
					else
						self.cooldownText:SetText("")
					end

                else
                    self.cooldownText:SetText("")
					self.cooldown:Clear()
                end

                -- Clear the script when cooldown is done
                if remaining <= 0.1 then
                    self:SetScript("OnUpdate", nil)
                    self.cooldownText:SetText("") -- Clear the text when cooldown is done
                end
            else
                -- Clear text and stop updating if cooldown display is disabled
                self.cooldownText:SetText("")
				self.cooldown:Clear()
                self:SetScript("OnUpdate", nil)
            end
        end)
    else
	
		if button.cooldownText then
			button.cooldownText:SetText("")
		end
	
		if button.cooldown then
			button.cooldown:Clear()
		end
	
        button:SetScript("OnUpdate", nil) -- Stop updating when no cooldown or negligible cooldown
    end
end


-- Update the Cooldown for a specific slot if it matches the cast spell
local function UpdateCooldownForSpellCast(spellName)
    for slotID, runeInfo in pairs(currentRunes) do
        local button = slotButtons[slotID]
        if runeInfo and runeDetailsMap[runeInfo.skillLineAbilityID] and runeDetailsMap[runeInfo.skillLineAbilityID].name == spellName and button and button.cooldown then
            UpdateRuneSlotCooldown(button, runeInfo.skillLineAbilityID)
        end
    end
end


local function UpdateRuneSlotButton(slotID)

	if not shownSlots[slotID] then
		slotButtons[slotID] = nil
	end

    local button = slotButtons[slotID]
    local runeInfo = currentRunes[slotID]
    local slotName = validSlots[slotID]

    if button then
    if debugging then
        print("|cff2da3cf[Rune Reminder]|r UpdateRuneSlotButton(" .. slotID .. ") - " .. (runeInfo and "|cffabdaeb" .. runeInfo.name or "None"))
    end
    
    if runeInfo then
        if debugging then
            print("|cff2da3cf[Rune Reminder]|r UpdateRuneSlotButton(" .. slotID .. ") - runeInfo exists")
        end
		if Masque then
			group:AddButton(button)	
		end
		
		-- Fetch cooldown data for the rune's ability
		local start, duration, enabled = GetRuneCooldown(runeInfo.skillLineAbilityID)

		-- Define a font for cooldown text
		local cooldownFont = "Fonts\\FRIZQT__.TTF" 
		local bSize = RuneReminder_CurrentSettings.buttonSize or 25
		local cooldownFontSize = bSize/2 

		
		if not button.cooldown then
			-- Create a cooldown frame if it doesn't exist
			button.cooldown = CreateFrame("Cooldown", "$parentCooldown", button, "CooldownFrameTemplate")
			button.cooldown:SetAllPoints()  -- Make the cooldown cover the entire button
			
			button.cooldownText = button.cooldown:CreateFontString(nil, "OVERLAY")
			button.cooldownText:SetFont(cooldownFont, cooldownFontSize, "OUTLINE")
			button.cooldownText:SetPoint("CENTER", 0, 0)
			
		end
		
		-- Set the cooldown using the fetched data
		if start and duration then
			button.cooldown:SetCooldown(start, duration)
			button.cooldown:SetDrawEdge(enabled)
			
			if not currentRunes[slotID] then
				button:SetChecked(false)
			elseif RuneReminder_CurrentSettings.enableChecked then 
				button:SetChecked(true)
			end

		else
			-- Clear cooldown display if there's no active cooldown (or no rune)
			button.cooldown:Clear() 
		end
		
		local texture = button:CreateTexture("Texture", "Background")
		texture:SetTexture(runeInfo.iconTexture)
		texture:SetAllPoints(button)
		
		
		if Masque then
			texture:SetTexCoord(.08, .92, .08, .92)
			button.texture = button:GetNormalTexture()
		else
			button:SetPushedTexture(texture)
			button:SetNormalTexture(texture)
			button.texture = texture--button:GetNormalTexture()
		end

		

        button:SetScript("OnEnter", function()
            if debugging then
                print("|cff2da3cf[Rune Reminder]|r Run OnEnter - " .. slotName)
            end
            GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
			if runeInfo.skillLineAbilityID and not RuneReminder_CurrentSettings.simpleTooltips then
				GameTooltip:SetEngravingRune(runeInfo.skillLineAbilityID) -- Show detailed tooltip for the rune
			else
				GameTooltip:ClearLines() -- Clear existing lines
				GameTooltip:AddLine(runeInfo.name, 0.67, 0.85, 0.92) -- Rune name in custom color
				GameTooltip:AddLine(slotName .. L[" Engraved"], 0, 0.55, 0) -- Slot engraving in green
			end
            GameTooltip:Show()
        end)
        button:SetScript("OnLeave", function()
            GameTooltip:Hide()
            if debugging then
                print("|cff2da3cf[Rune Reminder]|r Run OnLeave - " .. slotName)
            end
        end)
		
		if not RuneReminder_CurrentSettings.disableGlow then
			-- Add a glow or outline effect
			if not button.glow then
				button.glow = button:CreateTexture(nil, "OVERLAY")
				button.glow:SetTexture("Interface/"..RuneReminder_CurrentSettings.glowTexture) 
				button.glow:SetBlendMode("ADD")
				button.glow:SetAlpha(RuneReminder_CurrentSettings.glowOpacity)  -- Adjust the alpha for faint effect
			end
			local buttonSize = RuneReminder_CurrentSettings.buttonSize or 25
			
			button.glow:SetSize(buttonSize, buttonSize) -- Adjust the size to fit around the button
			button.glow:SetPoint("CENTER", button, "CENTER")  -- Center the glow on the button
			button.glow:Show()
		else
	        if button.glow then
                button.glow:Hide()
            end
		end
		
		button:SetChecked(RuneReminder_CurrentSettings.enableChecked)
		
		button.runeInfo = runeInfo
    else
		
			local texture = button:CreateTexture("Texture", "Background")
			texture:SetTexture("Interface/Icons/INV_Misc_QuestionMark") 

			button:SetChecked(false)
			
			if slotName == "Chest" then
				texture:SetTexture("Interface/PaperDoll/UI-PaperDoll-Slot-Chest") 
			elseif slotName == "Legs" then 
				texture:SetTexture("Interface/PaperDoll/UI-PaperDoll-Slot-Legs") 
			elseif slotName == "Hands" then 
				texture:SetTexture("Interface/PaperDoll/UI-PaperDoll-Slot-Hands") 
			elseif slotName == "Feet" then 
				texture:SetTexture("Interface/PaperDoll/UI-PaperDoll-Slot-Feet") 
			elseif slotName == "Waist" or slotName == "Belt" then 
				texture:SetTexture("Interface/PaperDoll/UI-PaperDoll-Slot-Waist") 
			elseif slotName == "Head" then 
				texture:SetTexture("Interface/PaperDoll/UI-PaperDoll-Slot-Head") 
			elseif slotName == "Neck" then 
				texture:SetTexture("Interface/PaperDoll/UI-PaperDoll-Slot-Neck") 
			elseif slotName == "Shoulder" then 
				texture:SetTexture("Interface/PaperDoll/UI-PaperDoll-Slot-Shoulder") 
			elseif slotName == "Wrists" or slotName == "Wrist" then 
				texture:SetTexture("Interface/PaperDoll/UI-PaperDoll-Slot-Wrists") 
			else
				texture:SetTexture("Interface/Icons/INV_Misc_QuestionMark") 
			end
			
			texture:SetAllPoints(button)
				
			if Masque then
				group:AddButton(button)
				texture:SetTexCoord(.08, .92, .08, .92)
				button.texture = button:GetNormalTexture()
			else
				button:SetPushedTexture(texture)
				button:SetNormalTexture(texture)
				button.texture = texture--button:GetNormalTexture()
			end
			



		if debugging then
			print("|cff2da3cf[Rune Reminder]|r UpdateRuneSlotButton Default Texture - " .. slotName)
		end
		
        button:SetScript("OnEnter", function()
            if debugging then
                print("|cff2da3cf[Rune Reminder]|r Run OnEnter - " .. slotName)
            end
            GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
            GameTooltip:SetText(slotName .. L[": No Engraving"]) 
            GameTooltip:Show()
        end)
        button:SetScript("OnLeave", function()
            GameTooltip:Hide()
            if debugging then
                print("|cff2da3cf[Rune Reminder]|r Run OnLeave - " .. slotName)
            end
        end)
		
    end

    if RuneReminder_CurrentSettings.displayRunes then
        button:Show()
    else
        button:Hide()
    end
	
   end
   
   UpdateButtonBehaviors()
end


-- Function to apply button sizes
local function ApplyButtonSizes()

    local buttonSize = RuneReminder_CurrentSettings.buttonSize or 25
	local dragsize = buttonSize/2
	frame:SetSize(dragsize,dragsize)
	
	if RuneSetsButton then
		RuneSetsButton:SetSize(buttonSize, buttonSize)
		if masque then
			group:AddButton(RuneSetsButton)
		end
	end
	
    for _, button in pairs(slotButtons) do
        button:SetSize(buttonSize, buttonSize)
		if Masque then
			group:AddButton(button)
		end
    end
    for _, buttons in pairs(runeSelectionButtons) do
        for _, runeButton in pairs(buttons) do
            runeButton:SetSize(buttonSize, buttonSize)
        end
    end
    

	
end


local function redrawWidget()

	if frame then
		if RuneReminder_CurrentSettings.charLocation and RuneReminder_CurrentSettings.charLocation ~= {} and RuneReminder_CurrentSettings.charLocation["relativePoint"] then
			frame:ClearAllPoints()
			frame:SetPoint(RuneReminder_CurrentSettings.charLocation["relativePoint"], UIParent, RuneReminder_CurrentSettings.charLocation["relativePoint"], RuneReminder_CurrentSettings.charLocation["xOfs"], RuneReminder_CurrentSettings.charLocation["yOfs"])
		elseif RuneReminder_CurrentSettings.location and RuneReminder_CurrentSettings.location[characterID] and RuneReminder_CurrentSettings.location[characterID] ~= {} and RuneReminder_CurrentSettings.location[characterID].relativePoint then
			frame:ClearAllPoints()
			frame:SetPoint(RuneReminder_CurrentSettings.location[characterID].relativePoint, UIParent, RuneReminder_CurrentSettings.location[characterID].relativePoint, RuneReminder_CurrentSettings.location[characterID].xOfs, RuneReminder_CurrentSettings.location[characterID].yOfs)
		end
	else
		initFrame()
	end

	CreateRuneSetsButton()
	HideRuneSelectionButtons()
	CreateSlotButtons(true)
	RefreshRuneSelectionButtons();
end
-- Function to handle alignment setting
local function SetRuneAlignment(alignment)
    RuneReminder_CurrentSettings.runeAlignment = alignment
	redrawWidget()
end

-- Function to handle direction setting
local function SetRuneDirection(direction)
    RuneReminder_CurrentSettings.runeDirection = direction
	redrawWidget()
end

function ResetAllButtons()
    -- Store the visibility state of rune selections
    local visibleRuneSelections = {}
    for slotID in pairs(validSlots) do
        visibleRuneSelections[slotID] = AreRuneButtonsVisible(slotID)
    end

    -- Remove existing buttons
    for _, button in pairs(slotButtons) do
        if button then
            if Masque then
                group:RemoveButton(button)
            end
            button:Hide()
           button:SetParent(nil)
        end
    end
    slotButtons = {}

    -- Remove existing rune selection buttons
    for _, buttons in pairs(runeSelectionButtons) do
        for _, button in pairs(buttons) do
            if button then
                if Masque then
                    group:RemoveButton(button)
                end
                button:Hide()
                button:SetParent(nil)
            end
        end
    end
    runeSelectionButtons = {} 
	
	if RuneSetsButton then
		if Masque then
			group:RemoveButton(RuneSetsButton)
		end
		RuneSetsButton:Hide()
		RuneSetsButton:SetParent(nil)
	end
	
	RuneSetsButton = nil
	
	local buttonSize = RuneReminder_CurrentSettings.buttonSize or 25
	local dragsize = buttonSize/2
	frame:SetSize(dragsize,dragsize)
	
    -- Recreate the buttons
    CreateSlotButtons(true)

    -- Update slot buttons with current rune information
    for slotID in pairs(validSlots) do
        UpdateRuneSlotButton(slotID)
    end

    -- Recreate and update rune selection buttons based on stored visibility state
    for slotID, isVisible in pairs(visibleRuneSelections) do
        CreateOrUpdateRuneSelectionButtons(slotID, isVisible)
    end
	
end

function UpdateButtonBehaviors()

    RuneReminder_CurrentSettings = RuneReminder_CurrentSettings or defaults

    local function any(func, tbl)
        for _, v in pairs(tbl) do
            if func(v) then
                return true
            end
        end
        return false
    end

    local function HideRuneButtonsIfAppropriate(slotID)
        local function checkAndHide()
            if not RuneReminder_CurrentSettings.autoToggleOnHover then return end

            local hovered = MouseIsOver(slotButtons[slotID]) or
                            any(MouseIsOver, runeSelectionButtons[slotID])

            if not hovered then
				if debugging then
				print("Debug: Hiding Rune Buttons for slotID", slotID) 
				end
                HideRuneSelectionButtons(slotID)
            elseif debugging then
                print("Debug: Mouse is still over the Rune or Slot Button for slotID", slotID)
            end
        end

        C_Timer.After(0.05, checkAndHide)
    end

    -- Update behaviors for each slot button
    for _, button in pairs(slotButtons) do
        button:SetScript("OnEnter", function(self) 
            if debugging then
                print("Debug: Entered slot button", self.slotID) 
            end
            
            -- Show the tooltip
            ShowSlotButtonTooltip(button)
            
            -- Auto-toggle handling
            if RuneReminder_CurrentSettings.autoToggleOnHover then
                RefreshRuneSelectionButtons(self.slotID, true)
            end
        end)

        button:SetScript("OnLeave", function()
            if debugging then
                print("Debug: Leaving slot button", button.slotID)
            end
            
            -- Hide the tooltip
            HideRuneButtonTooltip()
            
            if RuneReminder_CurrentSettings.autoToggleOnHover then
                HideRuneButtonsIfAppropriate(button.slotID)
            end
        end)
    end

    -- Update behaviors for each rune button
    if runeSelectionButtons then
        for slotID, buttons in pairs(runeSelectionButtons) do
            for _, runeButton in ipairs(buttons) do
                runeButton:SetScript("OnEnter", function()
                    if debugging then
                        print("Debug: Entered rune button for slotID", slotID)
                    end
                    -- Show the rune tooltip
                    ShowRuneButtonTooltip(runeButton, slotID) 
                end)

                runeButton:SetScript("OnLeave", function()
                    if debugging then
                        print("Debug: Leaving rune button for slotID", slotID)
                    end
                    -- Hide the rune tooltip
                    HideRuneButtonTooltip()
                    
                    if RuneReminder_CurrentSettings.autoToggleOnHover then
                        HideRuneButtonsIfAppropriate(slotID)
                    end
                end)
            end
        end
    end
end

-- Function to update character settings or shared settings based on profile selection
function UpdateSettingsFromProfile(profileName)
    if profileName == "SharedSettings" then
        RuneReminder_CurrentSettings = RuneReminderSharedSettings
    elseif RR_Profiles[profileName] then
        RuneReminder_CurrentSettings = RR_Profiles[profileName]
    elseif RuneReminderCharacterSettings then
        RuneReminder_CurrentSettings = RuneReminderCharacterSettings
	else 
		RuneReminder_CurrentSettings = RuneReminderSettings
    end
end

-- Function to save current settings to a named profile
function SaveProfile(profileName)
    RR_Profiles[profileName] = DeepCopy(RuneReminder_CurrentSettings)
    print("Profile " .. profileName .. " saved.")
end

-- Function to apply settings from a profile
function ApplyProfile(profileName)
    local characterID = GetCharacterUniqueID()
    RR_CharacterProfiles[characterID] = profileName
    UpdateSettingsFromProfile(profileName)
    print("Profile " .. profileName .. " applied.")
end

-- Function to reset settings to default
function ResetSettings()
    RuneReminder_CurrentSettings = DeepCopy(defaults)
    print(L["Settings reset to default."])
	UpdateActiveProfileSettings()
end

-- Initialize settings for a character
function InitializeCharacterSettings()
    if not RuneReminderCharacterSettings then
        -- First time setup, default to shared settings
        RuneReminderCharacterSettings = DeepCopy(RuneReminder_CurrentSettings)
    end
	
	if not RR_CharacterProfiles[characterID] then
		RR_CharacterProfiles[characterID] = currentProfile
	end

end

-- Load profile settings into the active settings
function LoadProfileSettings(profile)
    if profile == "SharedSettings" then
        RuneReminder_CurrentSettings = RuneReminderSharedSettings
    elseif profile == characterID then
		if RuneReminderCharacterSettings then
			RuneReminder_CurrentSettings = RuneReminderCharacterSettings
		elseif RR_Profiles[profile] then
			RuneReminder_CurrentSettings = DeepCopy(RR_Profiles[profile])
		else
			RuneReminder_CurrentSettings = RuneReminderSharedSettings
		end
	elseif profile and RR_Profiles[profile] then
		RuneReminder_CurrentSettings = DeepCopy(RR_Profiles[profile])
    end
	RR_CharacterProfiles[characterID] = profile
	currentProfile = profile
	if RuneReminderOptionsPanel then
		if RuneReminderOptionsPanel:IsVisible() then
			RuneReminderOptionsPanel:UpdateControls()
		end
	end
	
	if not frame then
		initFrame()
	elseif not frame.texture then
		initFrame()
	end
	
	ResetAllButtons()
	redrawWidget()
	ShowHideAnchor()
end

-- Update active profile settings
function UpdateActiveProfileSettings()
    if curentProfile == "SharedSettings" then
        RuneReminderSharedSettings = DeepCopy(RuneReminder_CurrentSettings)
    elseif currentProfile == characterID then
        RuneReminderCharacterSettings = DeepCopy(RuneReminder_CurrentSettings)
		
		--RR_AllowCopy = RR_AllowCopy or false
        --if RR_AllowCopy == true and currentProfile then
            --RR_Profiles[currentProfile] = DeepCopy(RuneReminder_CurrentSettings)
        --end
    end
end

-- Reset settings to default
function ResetSettingsToDefault()
    -- Show warning dialog before resetting
    StaticPopup_Show("CONFIRM_RESET_SETTINGS")
end

-- Delete a profile
function DeleteProfile(profileName)
    -- Show warning dialog before deleting
    StaticPopup_Show("CONFIRM_DELETE_PROFILE", profileName)
end

function OnSettingChanged()
    -- Update active profile settings
    UpdateActiveProfileSettings()
end


-- Initialize settings with defaults if necessary
function InitializeRRSettings()

	RuneReminderSharedSettings = RuneReminderSharedSettings or RuneReminderSettings or defaults
	RuneReminder_CurrentSettings = RuneReminder_CurrentSettings or RuneReminderSharedSettings
	
	RR_CharacterProfiles = RR_CharacterProfiles or {}
	RR_Profiles = RR_Profiles or {}
	RR_RuneSets = RR_RuneSets or {}
	
	characterID = GetCharacterUniqueID()
	local profile = RR_CharacterProfiles[characterID]
	
	if not profile then
		if RuneReminderSharedSettings.location and RuneReminderSharedSettings.location[characterID] then
			RuneReminderCharacterSettings = DeepCopy(RuneReminderSharedSettings)
			RuneReminderCharacterSettings.charLocation = RuneReminderSharedSettings.location[characterID]
			RR_CharacterProfiles[characterID] = characterID
			currentProfile = characterID
		else 
			currentProfile = "SharedSettings"
		end

	elseif profile == "SharedSettings" then
		currentProfile = "SharedSettings"
	elseif profile == characterID then
		currentProfile = characterID
	else 
		currentProfile = profile --characterID
	end

	LoadProfileSettings(currentProfile)

	InitializeRuneDetails()
	RefreshSpellIDMap()
	
	for key, value in pairs(defaults) do
        if RuneReminder_CurrentSettings[key] == nil then
            RuneReminder_CurrentSettings[key] = value
        end
    end
	
	SetShownSlots()
	
	if not RuneReminder_CurrentSettings.charLocation then
		if RuneReminderSharedSettings.location and RuneReminderSharedSettings.location[characterID] then
			RuneReminder_CurrentSettings.charLocation = RuneReminderSharedSettings.location[characterID]
		else
			RuneReminder_CurrentSettings.charLocation = {}
		end
		
	end
	
    debugging = RuneReminder_CurrentSettings.debugging or false
	
    ApplyButtonSizes() -- Ensure button sizes are applied immediately after settings initialization
	UpdateButtonBehaviors()

	InitializeCharacterSettings()
	
end

function SetShownSlots(redraw) 
	shownSlots = {}

	for slotID, slotName in pairs(validSlots) do
		if knownSlots[slotID] == true or not RuneReminder_CurrentSettings.hideUnknownSlots then
			if RuneReminder_CurrentSettings["hide"..slotName.."Slot"] == false then
				shownSlots[slotID] = slotName
			end
		end
    end
	
	if redraw then
		UpdateRunes(false, false)
		redrawWidget()
	end
end


-- Create Options Panel
local function CreateOptionsPanel()
    local panel = CreateFrame("Frame", "RuneReminderOptionsPanel", InterfaceOptionsFramePanelContainer)
    panel.name = L["Rune Reminder"]
    panel:Hide()
	
	
	-- Dropdown for Current Profile
	local profileDropdown = CreateFrame("Frame", "RuneReminderProfileDropdown", panel, "UIDropDownMenuTemplate")
	profileDropdown:SetPoint("TOPLEFT", panel, "TOPLEFT", 460, -10)
	
	UIDropDownMenu_SetWidth(profileDropdown, 120)
	if currentProfile == "SharedSettings" or not RR_CharacterProfiles[characterID] then
		UIDropDownMenu_SetText(profileDropdown, "Shared Profile")
	else
		UIDropDownMenu_SetText(profileDropdown, RR_CharacterProfiles[characterID])
	end



	-- Dropdown initialization function
	profileDropdown.initialize = function(self, level)
		local info = UIDropDownMenu_CreateInfo()

		-- Add "Shared" profile option
		info.text = "Shared Profile"
		info.checked = currentProfile == "SharedSettings"
		info.func = function()
			if currentProfile == characterID then
				RuneReminderCharacterSettings = DeepCopy(RuneReminder_CurrentSettings)
				RR_CharacterProfiles[characterID] = "SharedSettings"
				UIDropDownMenu_SetText(profileDropdown, "Shared Profile")
				LoadProfileSettings("SharedSettings")  -- Load shared settings
			end

		end
		UIDropDownMenu_AddButton(info, level)

		-- Add other profiles 
		info.text = characterID
		info.checked = currentProfile == characterID
		info.func = function()
			if currentProfile == "SharedSettings" then
				RuneReminderSharedSettings = DeepCopy(RuneReminder_CurrentSettings)
			
				RR_CharacterProfiles[characterID] = characterID
				UIDropDownMenu_SetText(profileDropdown, characterID)
				LoadProfileSettings(characterID)  -- Load profile settings
			end
		end
		UIDropDownMenu_AddButton(info, level)
		
		
		--for profileName, _ in pairs(RR_Profiles) do
		--	info.text = profileName
		--	info.func = function()
		--		RR_CharacterProfiles[characterID] = profileName
		--		UIDropDownMenu_SetText(profileDropdown, profileName)
		--		LoadProfileSettings(profileName)  -- Load settings for the selected profile
		--	end
		--	UIDropDownMenu_AddButton(info, level)
		--end
	end
	
	profileDropdown:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT") 

		local tooltipText = string.format("%s\n%s", L["Switch between character-specific settings and the Shared Profile."], L["Shared Profile is the default for new characters and shared by all that use it."])
		GameTooltip:SetText(tooltipText)  -- true for wrap text
		
		GameTooltip:Show()
	end)

	profileDropdown:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	
	-- Reset Settings Button
	--local resetButton = CreateFrame("Button", "RuneReminderResetButton", panel, "UIPanelButtonTemplate")
	--resetButton:SetSize(100, 22)
	--resetButton:SetText("Reset Character Settings")
	--resetButton:SetPoint("TOPLEFT", shareProfileCheckbox, "BOTTOMLEFT", 0, -10)

	--resetButton:SetScript("OnClick", function()
		--StaticPopup_Show("CONFIRM_RESET_SETTINGS")
	--end)
	
	local function updateButtonSize(slider, value)
		_G[slider:GetName() .. "Text"]:SetText(L["Button Size: "] .. value)
		if RuneReminder_CurrentSettings.buttonSize ~= value then
			RuneReminder_CurrentSettings.buttonSize = value
			ResetAllButtons()
		end
	end
	local function updateButtonPadding(slider, value)
		_G[slider:GetName() .. "Text"]:SetText(L["Button Padding: "] .. value)
		if RuneReminder_CurrentSettings.buttonPadding ~= value then
			RuneReminder_CurrentSettings.buttonPadding = value
			ResetAllButtons()
		end
	end

	local function updateGlowOpacity(slider, value)
		_G[slider:GetName() .. "Text"]:SetText(L["Glow Opacity: "] .. value)
		if RuneReminder_CurrentSettings.glowOpacity ~= value then
			RuneReminder_CurrentSettings.glowOpacity = value
			ResetAllButtons()
		end
	end
	local function updateButtonTextSize(slider, value)
		_G[slider:GetName() .. "Text"]:SetText(L["Button Text Size"].." :".. value)
		if RuneReminder_CurrentSettings.buttonLabelSize ~= value then
			RuneReminder_CurrentSettings.buttonLabelSize = value

			local font = "Fonts\\FRIZQT__.TTF" 
			local buttonSize = RuneReminder_CurrentSettings.buttonSize or 25
			local cooldownFontSize = buttonSize/2 
			local slotFontSize = (cooldownFontSize/2.28) * (RuneReminder_CurrentSettings.buttonLabelSize or 1.0)
			
			for _, button in pairs(slotButtons) do
				button.text:SetFont(font, slotFontSize, "OUTLINE")
			end

		end
	end
	local function setEnabledState(control, enabled)
		if enabled then
			control:Enable()
			if control.Text then
				control.Text:SetTextColor(1, 1, 1) -- white (enabled state)
			end
		else 
			control:Disable()
			if control.Text then
				control.Text:SetTextColor(0.5, 0.5, 0.5) -- white (enabled state)
			end
		end
	end


    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)

    local titleText = string.format("%s %s - %s %s", L["Rune Reminder"], L["Options"], L["Version"], version)
	title:SetText(titleText)
	
	

    -- Create a ScrollFrame inside options panel
    local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 10, -40)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)

    -- Create a scroll child frame
    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollFrame:SetScrollChild(scrollChild)
    scrollChild:SetSize(1, 1) 
	
	
	local characterToggleLabel = scrollChild:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	characterToggleLabel:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 340, -10)  
	characterToggleLabel:SetText(L["Character Panel Engraving Mode"])

	-- Add a dropdown for tooltip anchor setting
	local characterToggleDropdown = CreateFrame("Frame", "RuneReminderEngravingModeDropdown", scrollChild, "UIDropDownMenuTemplate")
	characterToggleDropdown:SetPoint("TOPLEFT", characterToggleLabel, "BOTTOMLEFT", -20, 0) 
	characterToggleDropdown.initialize = function(self, level)
		local info = UIDropDownMenu_CreateInfo()
		for _, val in ipairs({"TOGGLE", "SHOW", "HIDE"}) do
			info.text = val
			info.func = self.SetValue
			info.arg1 = val
			info.checked = (RuneReminder_CurrentSettings.engravingMode == val)
			UIDropDownMenu_AddButton(info, level)
			
			if info.checked then
				UIDropDownMenu_SetText(self, val)
			end
		end
	end
	
	
	function characterToggleDropdown:SetValue(newValue)
		RuneReminder_CurrentSettings.engravingMode = newValue
		UIDropDownMenu_SetText(characterToggleDropdown, newValue)
	end

	characterToggleDropdown:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT") 
		local tooltipText = string.format("%s\n \n%s\n%s\n%s",
			L["Adjust default visibility of the Engraving panel on your character screen."],
			L["SHOW will always open display the Engraving panel when you open your character window."],
			L["HIDE will collapse/hide the engraving frame from your character window until you hit the Runes button."],
			L["TOGGLE will remember if you had the frame open or closed."]
		)

		GameTooltip:SetText(tooltipText)  -- true for wrap text
		GameTooltip:Show()
	end)

	characterToggleDropdown:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	
	
	-- Helper function for checkboxes
	local function CreateCheckbox(option, column, yOffset, label, tooltip)
		local checkbox = CreateFrame("CheckButton", "RuneReminder" .. option .. "Checkbox", scrollChild, "InterfaceOptionsCheckButtonTemplate")
		local x = 0 -- Adjust for left or right column
		if column == "left" then
			x = 16
		elseif column == "left-2" then
			x = 176
		elseif column == "left-3" then
			x = 336
		elseif column == "left-4" then
			x = 496
		elseif column == "right" then
			x = 340
		elseif column == "right-2" then
			x = 480	
		end
		
		checkbox:SetPoint("TOPLEFT", x, yOffset)
		checkbox.Text:SetText(label)
		checkbox.tooltipText = tooltip
		checkbox:SetScript("OnClick", function(self)
			RuneReminder_CurrentSettings[option] = self:GetChecked()
			UpdateActiveProfileSettings()
		end)
		checkbox:SetChecked(RuneReminder_CurrentSettings[option])
		return checkbox
	end


    -- Function to create a slider
    local function CreateSlider(name, label, minVal, maxVal, step, x, y, width)
        local slider = CreateFrame("Slider", "RuneReminder" .. name .. "Slider", scrollChild, "OptionsSliderTemplate")
        slider:SetPoint("TOPLEFT", x, y)
        slider:SetWidth(width) 
        slider:SetMinMaxValues(minVal, maxVal)
        slider:SetValueStep(step)
        slider:SetObeyStepOnDrag(true)
        slider:SetValue(RuneReminder_CurrentSettings[name] or minVal)

        _G[slider:GetName() .. "Text"]:SetText(label .. ": " .. (RuneReminder_CurrentSettings[name] or minVal))
        _G[slider:GetName() .. "Low"]:SetText(minVal)
        _G[slider:GetName() .. "High"]:SetText(maxVal)

        return slider
    end


	-- Function to create a slider and an associated textbox
	local function CreateSliderWithTextbox(name, label, minVal, maxVal, step, x, y, width)
		-- Create the slider
		local slider = CreateFrame("Slider", "RuneReminder" .. name .. "Slider", scrollChild, "OptionsSliderTemplate")
		slider:SetPoint("TOPLEFT", x + 20, y) -- Shift right to accommodate decrement button
		slider:SetWidth(width)
		slider:SetMinMaxValues(minVal, maxVal)
		slider:SetValueStep(step)
		slider:SetObeyStepOnDrag(true)
		slider:SetValue(RuneReminder_CurrentSettings[name] or minVal)

		_G[slider:GetName() .. "Text"]:SetText(label .. ": " .. (RuneReminder_CurrentSettings[name] or minVal))
		_G[slider:GetName() .. "Low"]:SetText(minVal)
		_G[slider:GetName() .. "High"]:SetText(maxVal)

		-- Create the textbox
		local textbox = CreateFrame("EditBox", "RuneReminder" .. name .. "Textbox", slider, "InputBoxTemplate")
		textbox:SetSize(50, 20) -- Set the size of the textbox
		textbox:SetPoint("TOP", slider, "BOTTOM", 0, 3) -- Positioning under the slider
		textbox:SetAutoFocus(false)
		textbox:SetFontObject(GameFontHighlightSmall)
		textbox:SetJustifyH("CENTER")
		textbox:SetText(tostring(RuneReminder_CurrentSettings[name]))
		textbox:SetMaxLetters(6)

		-- Save the textbox in the slider for easy reference
		slider.textbox = textbox

		-- Function to update textbox value
		local function UpdateTextboxValue(sliderValue)
			textbox:SetText(tostring(sliderValue))
		end

		-- Consolidate OnValueChanged function
		slider:SetScript("OnValueChanged", function(self, value)
			if step >= 1 then
				value = math.floor(value)
			else
				value = tonumber(string.format("%2.1f", value))
			end
			
			-- Update the setting based on the slider's name
			if name == "buttonSize" then
				updateButtonSize(self, value)
			elseif name == "buttonPadding" then
				updateButtonPadding(self, value)
			elseif name == "glowOpacity" then
				updateGlowOpacity(self, value)
			elseif name == "buttonLabelSize" then
				updateButtonTextSize(self, value)
			end

			-- Update the textbox with the new value
			self.textbox:SetText(tostring(value))
			UpdateActiveProfileSettings()
		end)

		-- Update slider when textbox value changes
		textbox:SetScript("OnEnterPressed", function(self)
			local value = self:GetText()
			value = tonumber(value)

			if value and value >= minVal and value <= maxVal then
				slider:SetValue(value)
				self:ClearFocus()
			else
				self:SetText(tostring(RuneReminder_CurrentSettings[name])) -- Reset to the last valid value if invalid input
			end
			UpdateActiveProfileSettings()
		end)

		textbox:SetScript("OnEscapePressed", function(self)
			self:ClearFocus()
			self:SetText(tostring(RuneReminder_CurrentSettings[name])) -- Reset
		end)
		
		-- Create Increment and Decrement Buttons
		local decrementButton = CreateFrame("Button", "RuneReminder" .. name .. "DecrementButton", slider, "UIPanelButtonTemplate")
		decrementButton:SetSize(25, 20)
		decrementButton:SetPoint("RIGHT", slider, "LEFT", -5, 0) 
		decrementButton:SetText("-")

		local incrementButton = CreateFrame("Button", "RuneReminder" .. name .. "IncrementButton", slider, "UIPanelButtonTemplate")
		incrementButton:SetSize(25, 20)
		incrementButton:SetPoint("LEFT", slider, "RIGHT", 5, 0)
		
		incrementButton:SetText("+")

		-- Update Slider Value Function
		local function AdjustSliderValue(slider, amount)
			local currentValue = slider:GetValue()
			local newValue = math.max(minVal, math.min(maxVal, currentValue + amount)) -- Ensure the value is within bounds
			slider:SetValue(newValue)
			UpdateActiveProfileSettings()
		end

		-- Increment and Decrement Scripts
		incrementButton:SetScript("OnClick", function()
			AdjustSliderValue(slider, step) 
		end)

		decrementButton:SetScript("OnClick", function()
			AdjustSliderValue(slider, -step) 
		end)

		return slider, textbox -- Return both slider and textbox
	end


	-- Create UI elements
	local yOffset = -10
	-- Rune Reminder Options (Label)
	local optionsLabel = scrollChild:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	optionsLabel:SetPoint("TOPLEFT", 16, yOffset)
	optionsLabel:SetText(L["Notification Options"])

	-- Next row starts after the label
	yOffset = yOffset - 20

	-- Left Column
	local enabledCheckbox = CreateCheckbox("enabled", "left", yOffset, L["Enable All Popup Notifications"], L["Toggle the popups (for all slots) on or off."])
	local hideReapplyButtonCheckbox = CreateCheckbox("hideReapplyButton", "left", yOffset - 30, L["Hide Re-Apply Button"], L["Toggle the visibility of the Re-Apply Rune button in popups."])
	local hideViewRunesButtonCheckbox = CreateCheckbox("hideViewRunesButton", "left", yOffset - 60, L["Hide View Runes Button"], L["Toggle the visibility of the View Runes button in popups."])
	local disableSwapCheckbox = CreateCheckbox("disableSwapNotify", "left", yOffset - 90, L["Disable when swapping to engraved gear"], L["Disable popup notification when equipping engraved gear."])
	local disableRemoveCheckbox = CreateCheckbox("disableRemoveNotify", "left", yOffset - 120, L["Disable when removing gear"], L["Disable popup notification when removing gear (without a new piece replacing it)"])

	-- Right Column
	local soundCheckbox = CreateCheckbox("soundNotification", "right", yOffset - 30, L["Enable Sound Notifications"], L["Toggle sound notifications for rune changes."])


	-- Runes Widget Options (Label)
	yOffset = yOffset - 160
	local widgetLabel = scrollChild:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	widgetLabel:SetPoint("TOPLEFT", 16, yOffset)
	widgetLabel:SetText(L["Runes Widget & Rune Sets Options"])

	-- Next row starts after the label
	yOffset = yOffset - 20

	local runeTextureLabel = scrollChild:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	runeTextureLabel:SetPoint("TOPLEFT", widgetLabel, "BOTTOMLEFT", 330, -40)  
	runeTextureLabel:SetText(L["Rune Texture:"])
	local runeTextureDropdown = CreateFrame("Frame", "RuneReminderRuneTextureDropdown", scrollChild, "UIDropDownMenuTemplate")
	runeTextureDropdown:SetPoint("TOPLEFT", runeTextureLabel, "BOTTOMLEFT", -20, -5)  
	UIDropDownMenu_SetWidth(runeTextureDropdown, 150)


	-- 
	local displayAnchorCheckbox = CreateCheckbox("anchorVisible", "left", yOffset, L["Display Positioning Anchor"], L["Controls display of the Anchor for positioning. This can also be toggled by Right Clicking the anchor."] .. "\n\n" .. L["NOTE: Even when hidden, it's grab/draggable. Lock positioning below if you do not want it to be."])
	local lockAnchorCheckbox = CreateCheckbox("anchorLocked", "right", yOffset, L["Lock Positioning Anchor"], L["Locks the anchor in place, preventing accidental click/drag repositioning."])
	yOffset = yOffset - 40
	
	local displayRuneSetsCheckbox = CreateCheckbox("displayRuneSets", "left", yOffset, L["Display Rune Sets"], L["Toggle the display of the Rune Sets button"])
	local setEngraveOnLoadCheckbox = CreateCheckbox("setEngraveOnLoad", "left", yOffset - 30, L["Begin Engraving Immediately (Rune Sets)"], L["If enabled, selecting to Load a Rune Set will immediately attempt to begin engraving."])
	local toggleRuneSetsCheckbox = CreateCheckbox("toggleSets", "left", yOffset - 60, L["Toggle Rune Slots by Right Clicking on Rune Sets"], L["If enabled, right clicking the Rune Sets button will expand/collapse the Runes Widget."])
	local toggleRuneSetsTogglesAllCheckbox = CreateCheckbox("toggleSetsTogglesAll", "left", yOffset - 90, L["Rune Sets Toggle Expands All"], L["If enabled, when right clicking the Rune Sets button, all slots will default to expanded/displayed."])
	
	local displayRunesCheckbox = CreateCheckbox("displayRunes", "left", yOffset - 130, L["Display Runes Widget"], L["Toggle the display of the Runes Widget"])
	local hideUnknownCheckbox = CreateCheckbox("hideUnknownRunes", "right", yOffset - 130, L["Hide Unknown Runes"], L["Prevents runes that have not been found from displaying in the Runes Widget"])

	local displayCooldownCheckbox = CreateCheckbox("displayCooldown", "left", yOffset - 160, L["Display Cooldown Animation"], L["Display cooldown animation on engraved runes."])
	local displayCooldownTextCheckbox = CreateCheckbox("displayCooldownText", "right", yOffset - 160, L["Display Cooldown Text"], L["Display time remaining on cooldown for engraved runes. Turn this off if you're seeing doubled up numbers from another addon."])

	--local displayRuneSetsLabelCheckbox = CreateCheckbox("showSetsLabel", "left", yOffset - 190, L["Display Rune Sets Text Label"], L["Display the Rune Sets Button Text."])
	local displayRuneSlotsLabelCheckbox = CreateCheckbox("showSlotLabels", "left", yOffset - 190, L["Display Rune Slots Text Labels"], L["Display the Rune Slot Button Labels."])
	
	local buttonTextSlider = CreateSliderWithTextbox("buttonLabelSize", L["Button Text Size"], 0.0, 2.0, 0.1, 27, yOffset - 235, 175)
	
	local enableCheckedCheckbox = CreateCheckbox("enableChecked", "left", yOffset - 280, L["Set Checked State"], L["Enables the Checked state, which gives an alternate glow effect. This effect can be stylized in Masque."] .. "\n\n" .. L["NOTE: The Checked state will overlap with the custom Glow texture. Most users will not want both enabled together."])
	local disableGlowCheckbox = CreateCheckbox("disableGlow", "right", yOffset - 280, L["Disable Engraved Glow"], L["Removes the custom glow texture on engraved rune slots."] .. "\n\n" .. L["NOTE: The Checked state will overlap with this. Most users will not want both enabled together."])

	local glowOpacitySlider = CreateSliderWithTextbox("glowOpacity", L["Glow Opacity"], 0.0, 1.0, 0.1, 27, yOffset - 330, 175)

	local glowTextureLabel = scrollChild:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	glowTextureLabel:SetPoint("LEFT", disableGlowCheckbox, "BOTTOMLEFT", 0, -10)  
	glowTextureLabel:SetText(L["Glow Texture:"])

	local glowTextureDropdown = CreateFrame("Frame", "RuneReminderGlowTextureDropdown", scrollChild, "UIDropDownMenuTemplate")
	glowTextureDropdown:SetPoint("TOPLEFT", glowTextureLabel, "BOTTOMLEFT", -20, -5)  

	local simpleTooltipsCheckbox = CreateCheckbox("simpleTooltips", "left", yOffset - 380, L["Simple Tooltips"], L["Removes the Engraving Tooltips from the Rune Slots"])
	local tooltipAnchorLabel = scrollChild:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	tooltipAnchorLabel:SetPoint("TOPLEFT", glowTextureLabel, "BOTTOMLEFT", 0, -55) 
	tooltipAnchorLabel:SetText(L["Tooltip Position:"])
	local tooltipAnchorDropdown = CreateFrame("Frame", "RuneReminderTooltipAnchorDropdown", scrollChild, "UIDropDownMenuTemplate")
	tooltipAnchorDropdown:SetPoint("TOPLEFT", tooltipAnchorLabel, "BOTTOMLEFT", -20, -5)  
	
	
	local autoToggleOnHoverCheckbox = CreateCheckbox("autoToggleOnHover", "left", yOffset - 410, L["Auto Toggle on Hover"], L["Automatically show/hide runes when hovering over runes/slot buttons."])
	
	
	local keepOpenCheckbox = CreateCheckbox("keepOpen", "left", yOffset - 440, L["Keep Runes Open (during/after engraving)"], L["Disable auto-collapse when applying a new rune."])
	local disableLeftClickCheckbox = CreateCheckbox("disableLeftClickKeepOpen", "left", yOffset - 470, L["Disable LeftClick-to-Toggle w/ Keep Open"], L["Prevents normal left clicks from collapsing a column/row when Keep Open is enabled."])
	
	local rotateRunesCheckbox = CreateCheckbox("rotateRunes", "left", yOffset - 500, L["Rotate Runes"], L["Toggle between Horizontal and Vertical alignment."])
	local swapDirectionCheckbox = CreateCheckbox("swapDirection", "left", yOffset - 530, L["Swap Direction"], L["Swap the direction the runes expand in the widget."])
	
	yOffset = yOffset - 570
	
	local hideUnknownSlotsCheckbox = CreateCheckbox("hideUnknownSlots", "left", yOffset, L["Hide Slots until Runes are found/available"], L["Hide each slot in the Runes Widget until at least 1 rune is known for that slot."])
	hideUnknownSlotsCheckbox:SetScript("OnClick", function(self)
		RuneReminder_CurrentSettings.hideUnknownSlots = self:GetChecked()
		SetShownSlots(true)
		UpdateActiveProfileSettings()
	end)
	
	yOffset = yOffset - 30
	local hideChestSlotCheckbox = CreateCheckbox("hideChestSlot", "left", yOffset, L["Hide Chest Slot"], L["Hide the Chest Slot on the Runes Widget."])
	hideChestSlotCheckbox:SetScript("OnClick", function(self)
		RuneReminder_CurrentSettings.hideChestSlot = self:GetChecked()
		SetShownSlots(true)
		UpdateActiveProfileSettings()
	end)
	local hideLegsSlotCheckbox = CreateCheckbox("hideLegsSlot", "left-2", yOffset, L["Hide Legs Slot"], L["Hide the Legs Slot on the Runes Widget."])
	hideLegsSlotCheckbox:SetScript("OnClick", function(self)
		RuneReminder_CurrentSettings.hideLegsSlot = self:GetChecked()
		SetShownSlots(true)
		UpdateActiveProfileSettings()
	end)
	local hideHandsSlotCheckbox = CreateCheckbox("hideHandsSlot", "left-3", yOffset, L["Hide Hands Slot"], L["Hide the Hands Slot on the Runes Widget."])
	hideHandsSlotCheckbox:SetScript("OnClick", function(self)
		RuneReminder_CurrentSettings.hideHandsSlot = self:GetChecked()
		SetShownSlots(true)
		UpdateActiveProfileSettings()
	end)
	yOffset = yOffset - 30
	local hideWaistSlotCheckbox = CreateCheckbox("hideWaistSlot", "left", yOffset, L["Hide Waist Slot"], L["Hide the Waist Slot on the Runes Widget."])
		hideWaistSlotCheckbox:SetScript("OnClick", function(self)
		RuneReminder_CurrentSettings.hideWaistSlot = self:GetChecked()
		SetShownSlots(true)
		UpdateActiveProfileSettings()
	end)
	local hideFeetSlotCheckbox = CreateCheckbox("hideFeetSlot", "left-2", yOffset, L["Hide Feet Slot"], L["Hide the Feet Slot on the Runes Widget."])
		hideFeetSlotCheckbox:SetScript("OnClick", function(self)
		RuneReminder_CurrentSettings.hideFeetSlot = self:GetChecked()
		SetShownSlots(true)
		UpdateActiveProfileSettings()
	end)
	local hideWristsSlotCheckbox = CreateCheckbox("hideWristsSlot", "left-3", yOffset, L["Hide Wrists Slot"], L["Hide the Wrists Slot on the Runes Widget."])
		hideWristsSlotCheckbox:SetScript("OnClick", function(self)
		RuneReminder_CurrentSettings.hideWristsSlot = self:GetChecked()
		SetShownSlots(true)
		UpdateActiveProfileSettings()
	end)
	yOffset = yOffset - 30
	local hideHeadSlotCheckbox = CreateCheckbox("hideHeadSlot", "left", yOffset, L["Hide Head Slot"], L["Hide the Head Slot on the Runes Widget."])
		hideHeadSlotCheckbox:SetScript("OnClick", function(self)
		RuneReminder_CurrentSettings.hideHeadSlot = self:GetChecked()
		SetShownSlots(true)
		UpdateActiveProfileSettings()
	end)
	local hideNeckSlotCheckbox = CreateCheckbox("hideNeckSlot", "left-2", yOffset, L["Hide Neck Slot"], L["Hide the Neck Slot on the Runes Widget."])
		hideNeckSlotCheckbox:SetScript("OnClick", function(self)
		RuneReminder_CurrentSettings.hideNeckSlot = self:GetChecked()
		SetShownSlots(true)
		UpdateActiveProfileSettings()
	end)
	local hideShoulderSlotCheckbox = CreateCheckbox("hideShoulderSlot", "left-3", yOffset, L["Hide Shoulder Slot"], L["Hide the Shoulder Slot on the Runes Widget."])
		hideShoulderSlotCheckbox:SetScript("OnClick", function(self)
		RuneReminder_CurrentSettings.hideShoulderSlot = self:GetChecked()
		SetShownSlots(true)
		UpdateActiveProfileSettings()
	end)
	yOffset = yOffset - 80

	glowTextureDropdown.initialize = function(self, level)
			local info = UIDropDownMenu_CreateInfo()
			for userVisible, path in pairs(glowTextures) do
				info.text = userVisible
				info.func = function()
					RuneReminder_CurrentSettings.glowTexture = path
					UIDropDownMenu_SetText(glowTextureDropdown, userVisible)
					ResetAllButtons()
					UpdateActiveProfileSettings()
				end
				if RuneReminder_CurrentSettings.glowTexture == path then
					info.checked = true
					UIDropDownMenu_SetText(glowTextureDropdown, userVisible) 
				else
					info.checked = false
				end
				
				UIDropDownMenu_AddButton(info, level)
			end
	end
	
	
	UIDropDownMenu_SetWidth(glowTextureDropdown, 150)
	
	
	runeTextureDropdown.initialize = function(self, level)
		if not self.IsInitialized then
			local info = UIDropDownMenu_CreateInfo()
		
			for i = 1, #runeTextureOrder do
				local userVisible = runeTextureOrder[i]
				local path = runeTextures[userVisible]
				
				info.text = userVisible
				info.func = function()
					RuneReminder_CurrentSettings.runeSetsIcon = path
					UIDropDownMenu_SetText(runeTextureDropdown, userVisible)
					ResetAllButtons()
					UpdateActiveProfileSettings()
				end
				if RuneReminder_CurrentSettings.runeSetsIcon == path then
					info.checked = true
					UIDropDownMenu_SetText(runeTextureDropdown, userVisible) 
					if RuneSetsButton then
						RuneSetsButton:Hide()
						RuneSetsButton = nil
					end
					CreateRuneSetsButton()
				else
					info.checked = false
				end
				
				UIDropDownMenu_AddButton(info, level)
			end
			self.isInitialized = true
		end

	end

	-- Add a dropdown for tooltip anchor setting
	tooltipAnchorDropdown.initialize = function(self, level)
			local info = UIDropDownMenu_CreateInfo()
			for _, anchor in ipairs({"ANCHOR_TOP", "ANCHOR_RIGHT", "ANCHOR_BOTTOM", "ANCHOR_LEFT", "ANCHOR_TOPRIGHT", "ANCHOR_BOTTOMRIGHT", "ANCHOR_TOPLEFT", "ANCHOR_BOTTOMLEFT", "ANCHOR_CURSOR"}) do
				info.text = anchor
				info.func = self.SetValue
				info.arg1 = anchor
				info.checked = (RuneReminder_CurrentSettings.tooltipAnchor == anchor)
				UIDropDownMenu_AddButton(info, level)
			end
			self.isInitialized = true

	end
	
	--displayRuneSetsLabelCheckbox:SetScript("OnClick", function(self)
	--	RuneReminder_CurrentSettings.showSetsLabel = self:GetChecked()
	--	
	--	if RuneReminder_CurrentSettings.showSetsLabel then
	--		if RuneSetsButton then
	--			RuneSetsButton.text:Show()
	--		end
	--	else
	--		if RuneSetsButton then
	--			RuneSetsButton.text:Hide()
	--		end
	--	end
	--	
	--	UpdateActiveProfileSettings()
	--end)
	
	displayRuneSlotsLabelCheckbox:SetScript("OnClick", function(self)
		RuneReminder_CurrentSettings.showSlotLabels = self:GetChecked()
		
		
		if RuneReminder_CurrentSettings.showSlotLabels then
			for _, button in pairs(slotButtons) do
				button.text:Show()
			end
		else
			for _, button in pairs(slotButtons) do
				button.text:Hide()
			end
		end

		UpdateActiveProfileSettings()
	end)

	function tooltipAnchorDropdown:SetValue(newValue)
		RuneReminder_CurrentSettings.tooltipAnchor = newValue
		UIDropDownMenu_SetText(tooltipAnchorDropdown, newValue)
		CloseDropDownMenus()
		UpdateActiveProfileSettings()
	end

	tooltipAnchorLabel:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT") 
		GameTooltip:SetText(L["Adjust tooltip anchoring in relation to the rune button"]) 
		GameTooltip:Show()
	end)

	tooltipAnchorLabel:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)

	UIDropDownMenu_SetWidth(tooltipAnchorDropdown, 150)
	UIDropDownMenu_SetButtonWidth(tooltipAnchorDropdown, 124)
	UIDropDownMenu_SetText(tooltipAnchorDropdown, RuneReminder_CurrentSettings.tooltipAnchor or "ANCHOR_RIGHT")
	UIDropDownMenu_JustifyText(tooltipAnchorDropdown, "LEFT")

	local function UpdateCooldownTextCheckboxState()
		if RuneReminder_CurrentSettings.displayCooldown then
			displayCooldownTextCheckbox:Enable()
			displayCooldownTextCheckbox.Text:SetTextColor(1, 1, 1) -- white (enabled state)
		else
			displayCooldownTextCheckbox:Disable()
			displayCooldownTextCheckbox.Text:SetTextColor(0.5, 0.5, 0.5) -- grey (disabled state)
		end
	end

	local function UpdateNotificationCheckboxStates()

		if RuneReminder_CurrentSettings.enabled then
			setEnabledState(hideViewRunesButtonCheckbox, true)
			setEnabledState(hideReapplyButtonCheckbox, true)
			setEnabledState(disableSwapCheckbox, true)
			setEnabledState(disableRemoveCheckbox, true)
		else
			setEnabledState(hideViewRunesButtonCheckbox, false)
			setEnabledState(hideReapplyButtonCheckbox, false)
			setEnabledState(disableSwapCheckbox, false)
			setEnabledState(disableRemoveCheckbox, false)
		end
		
		
	end	

	
	local function UpdateRuneSetsCheckboxStates()
		if RuneReminder_CurrentSettings.displayRuneSets then			
			setEnabledState(toggleRuneSetsCheckbox, true)
			setEnabledState(toggleRuneSetsTogglesAllCheckbox, true)
			setEnabledState(setEngraveOnLoadCheckbox, true)
			setEnabledState(swapDirectionCheckbox, true)
			setEnabledState(displayAnchorCheckbox, true)
			setEnabledState(lockAnchorCheckbox, true)
		else
			if RuneReminder_CurrentSettings.displayRunes then
				setEnabledState(swapDirectionCheckbox, true)
				setEnabledState(displayAnchorCheckbox, true)
				setEnabledState(lockAnchorCheckbox, true)
			else 
				setEnabledState(swapDirectionCheckbox, false)
				setEnabledState(displayAnchorCheckbox, false)
				setEnabledState(lockAnchorCheckbox, false)
			end
			setEnabledState(toggleRuneSetsCheckbox, false)
			setEnabledState(toggleRuneSetsTogglesAllCheckbox, false)
			setEnabledState(setEngraveOnLoadCheckbox, false)
			
		end
	end
	
	local function UpdateRunesWidgetCheckboxStates()
		if RuneReminder_CurrentSettings.displayRunes then		
			setEnabledState(hideUnknownCheckbox, true)
			setEnabledState(keepOpenCheckbox, true)
			setEnabledState(disableLeftClickCheckbox, true)
			setEnabledState(autoToggleOnHoverCheckbox, true)
			setEnabledState(rotateRunesCheckbox, true)
			setEnabledState(swapDirectionCheckbox, true)
			setEnabledState(simpleTooltipsCheckbox, true)
			setEnabledState(disableGlowCheckbox, true)
			setEnabledState(enableCheckedCheckbox, true)
			setEnabledState(displayCooldownCheckbox, true)
			setEnabledState(displayAnchorCheckbox, true)
			setEnabledState(lockAnchorCheckbox, true)
			--setEnabledState(glowTextureLabel, true)
			--setEnabledState(tooltipAnchorLabel, true)
			
			if RuneReminder_CurrentSettings.displayCooldown then
				setEnabledState(displayCooldownTextCheckbox, true)
			else
				setEnabledState(displayCooldownTextCheckbox, false)
			end
		else
			setEnabledState(hideUnknownCheckbox, false)
			setEnabledState(keepOpenCheckbox, false)
			setEnabledState(disableLeftClickCheckbox, false)
			setEnabledState(autoToggleOnHoverCheckbox, false)
			setEnabledState(rotateRunesCheckbox, false)
			setEnabledState(swapDirectionCheckbox, false)
			setEnabledState(simpleTooltipsCheckbox, false)
			setEnabledState(disableGlowCheckbox, false)
			setEnabledState(enableCheckedCheckbox, false)
			setEnabledState(displayCooldownCheckbox, false)
			setEnabledState(displayCooldownTextCheckbox, false)
			--setEnabledState(glowTextureLabel, false)
			
			if RuneReminder_CurrentSettings.displayRuneSets then
				setEnabledState(swapDirectionCheckbox, true)
				setEnabledState(displayAnchorCheckbox, true)
				setEnabledState(lockAnchorCheckbox, true)
				--setEnabledState(tooltipAnchorLabel, true)
			else 
				setEnabledState(swapDirectionCheckbox, false)
				setEnabledState(displayAnchorCheckbox, false)
				setEnabledState(lockAnchorCheckbox, false)
				--setEnabledState(tooltipAnchorLabel, false)
			end
		end
	end

	displayCooldownCheckbox:SetScript("OnClick", function(self)
		RuneReminder_CurrentSettings.displayCooldown = self:GetChecked()	
		UpdateCooldownTextCheckboxState() 
		UpdateActiveProfileSettings()
	end)
	
	toggleRuneSetsCheckbox:SetScript("OnClick", function(self)
		RuneReminder_CurrentSettings.toggleSets = self:GetChecked()
		UpdateRuneSetsCheckboxStates() 
		UpdateActiveProfileSettings()
	end)

	local function UpdateControlStates()
		-- Disable glow settings if DisableGlow is checked
		glowOpacitySlider:SetEnabled(not RuneReminder_CurrentSettings.disableGlow)
		UIDropDownMenu_EnableDropDown(glowTextureDropdown, not RuneReminder_CurrentSettings.disableGlow)
		
		-- Disable 'Disable LeftClick w/ Keep Open' if Keep Runes Open isn't checked
		disableLeftClickCheckbox:SetEnabled(RuneReminder_CurrentSettings.keepOpen)
	end


	-- Sliders
	local widgetButtonSizeLabel = scrollChild:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	widgetButtonSizeLabel:SetPoint("TOPLEFT", 16, yOffset + 30)
	widgetButtonSizeLabel:SetText(L["Button Size & Padding"])
	local widgetPosLabel = scrollChild:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	widgetPosLabel:SetPoint("TOPLEFT", 470, yOffset + 30)
	widgetPosLabel:SetText(L["Adjust Positioning"])	

	-- Create buttonSizeSlider with textbox
	local buttonSizeSlider, buttonSizeTextbox = CreateSliderWithTextbox("buttonSize", L["Button Size"], 5, 100, 1, 26, yOffset, 350)
	yOffset = yOffset - 60
	
	local paddingSlider, paddingTextbox = CreateSliderWithTextbox("buttonPadding", L["Button Padding"], 0, 10, 1, 26, yOffset, 350)
		
	-- Update the size of the scroll child based on the number of elements
	scrollChild:SetSize(600, math.abs(yOffset))

	
	-- Function to update the labels for Alignment and Direction
	local function UpdateOptionLabels()
		if RuneReminder_CurrentSettings.runeAlignment == "Horizontal" then
			rotateRunesCheckbox.Text:SetText(L["Rotate Runes - Currently: Horizontal"])
			if RuneReminder_CurrentSettings.runeDirection == "Standard" then
				swapDirectionCheckbox.Text:SetText(L["Swap Direction - Currently: Standard - Expand Down"])
			else
				swapDirectionCheckbox.Text:SetText(L["Swap Direction - Currently: Alternate - Expand Up"])
			end
		else
			rotateRunesCheckbox.Text:SetText(L["Rotate Runes - Currently: Vertical"])
			if RuneReminder_CurrentSettings.runeDirection == "Standard" then
				swapDirectionCheckbox.Text:SetText(L["Swap Direction - Currently: Standard - Expand Right"])
			else
				swapDirectionCheckbox.Text:SetText(L["Swap Direction - Currently: Alternate - Expand Left"])
			end
		end
	end

	-- On Click/changes 
	enabledCheckbox:SetScript("OnClick", function(self)
		RuneReminder_CurrentSettings.enabled = self:GetChecked()
		UpdateNotificationCheckboxStates()
		UpdateActiveProfileSettings()
	end)

	
	
	rotateRunesCheckbox:SetScript("OnClick", function(self)
        RuneReminder_CurrentSettings.runeAlignment = self:GetChecked() and "Vertical" or "Horizontal"
        SetRuneAlignment(RuneReminder_CurrentSettings.runeAlignment)
        UpdateOptionLabels()  
		UpdateActiveProfileSettings()
    end)
    rotateRunesCheckbox:SetChecked(RuneReminder_CurrentSettings.runeAlignment == "Vertical")

    swapDirectionCheckbox:SetScript("OnClick", function(self)
        RuneReminder_CurrentSettings.runeDirection = self:GetChecked() and "Alternate" or "Standard"
        SetRuneDirection(RuneReminder_CurrentSettings.runeDirection)
        UpdateOptionLabels()
		UpdateActiveProfileSettings()
    end)
	
	disableGlowCheckbox:SetScript("OnClick", function(self)
		RuneReminder_CurrentSettings.disableGlow = self:GetChecked()
		for slotID in pairs(validSlots) do
			UpdateRuneSlotButton(slotID) 
		end  
		UpdateActiveProfileSettings()
	end)
	
	enableCheckedCheckbox:SetScript("OnClick", function(self)
		RuneReminder_CurrentSettings.enableChecked = self:GetChecked()
		for slotID in pairs(validSlots) do
			UpdateRuneSlotButton(slotID) 
		end  
		UpdateActiveProfileSettings()
	end)
	
	disableLeftClickCheckbox:SetScript("OnClick", function(self)
		RuneReminder_CurrentSettings.disableLeftClickKeepOpen = self:GetChecked()
		UpdateActiveProfileSettings()
	end)

	displayRunesCheckbox:SetScript("OnClick", function(self)
		RuneReminder_CurrentSettings.displayRunes = self:GetChecked()
		if not frame.texture then
			initFrame()
		end
		CreateSlotButtons()
			if RuneReminder_CurrentSettings.displayRunes then
				RefreshRuneSelectionButtons()
			else 
				HideRuneSelectionButtons()
			end	
			ShowHideAnchor()
			
		UpdateRunesWidgetCheckboxStates()
		end)
		keepOpenCheckbox:SetScript("OnClick", function(self)
		RuneReminder_CurrentSettings.keepOpen = self:GetChecked()
		if RuneReminder_CurrentSettings.keepOpen then
			RefreshRuneSelectionButtons()
		else 
				HideRuneSelectionButtons()
		end
		UpdateActiveProfileSettings()
	end)
	
	displayRuneSetsCheckbox:SetScript("OnClick", function(self)
		RuneReminder_CurrentSettings.displayRuneSets = self:GetChecked()
		
		UpdateRuneSetsCheckboxStates()
		
		if RuneReminder_CurrentSettings.displayRuneSets then
			CreateRuneSetsButton()
		elseif RuneSetsButton then
			RuneSetsButton:Hide()
			RuneSetsButton = nil
		end
		
		CreateSlotButtons(true)
		
			if not frame.texture then
				initFrame()
			end
	
			if RuneReminder_CurrentSettings.displayRunes then
				RefreshRuneSelectionButtons()
			else 
				HideRuneSelectionButtons()
			end	
			ShowHideAnchor()
			UpdateActiveProfileSettings()
		end)
		
	keepOpenCheckbox:SetScript("OnClick", function(self)
		RuneReminder_CurrentSettings.keepOpen = self:GetChecked()
		if RuneReminder_CurrentSettings.keepOpen then
			RefreshRuneSelectionButtons()
				else 
				HideRuneSelectionButtons()
			end
		UpdateActiveProfileSettings()
	end)
	
	
	hideUnknownCheckbox:SetScript("OnClick", function(self)
		RuneReminder_CurrentSettings.hideUnknownRunes = self:GetChecked()
		RefreshRuneSelectionButtons(nil, AreAnyRunesVisible())
		UpdateActiveProfileSettings()
	end)
	
	autoToggleOnHoverCheckbox:SetScript("OnClick", function(self)
		RuneReminder_CurrentSettings.autoToggleOnHover = self:GetChecked()
		UpdateButtonBehaviors()
		UpdateActiveProfileSettings()
	end)
		
	displayAnchorCheckbox:SetScript("OnClick", function(self)
		RuneReminder_CurrentSettings.anchorVisible = self:GetChecked()
		ShowHideAnchor()
		UpdateActiveProfileSettings()
	end)
	
	lockAnchorCheckbox:SetScript("OnClick", function(self)
		RuneReminder_CurrentSettings.anchorLocked = self:GetChecked()
		UpdateActiveProfileSettings()
	end)
	
		

	-- Function to adjust offset values
	local function adjustOffset(direction, amount)
		local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint()
	
		if direction == "x" then
			-- Move left or right by amount
			xOfs = xOfs + amount
		elseif direction == "y" then
			-- Move up or down by amount
			yOfs = yOfs + amount
		end
		

		-- Apply the new position to the frame
		frame:ClearAllPoints()
		frame:SetPoint(point, relativeTo, relativePoint, xOfs, yOfs)
		RuneReminder_CurrentSettings.charLocation = {}

		RuneReminder_CurrentSettings.charLocation.xOfs = xOfs
		RuneReminder_CurrentSettings.charLocation.yOfs = yOfs
		RuneReminder_CurrentSettings.charLocation.relativePoint = relativePoint
		UpdateActiveProfileSettings()
	end

	-- Reset Button
	local resetButton = CreateFrame("Button", "ResetPositionButton", scrollChild, "UIPanelButtonTemplate")
	resetButton:SetText(L["Reset"])
	resetButton:SetSize(50, 20)
	resetButton:SetPoint("TOP", scrollChild, "TOP", 225, yOffset + 25) 
	resetButton:SetScript("OnClick", function()
		initFrame(true)
		UpdateActiveProfileSettings()
	end)

	resetButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT") 
		GameTooltip:SetText(L["Reset Positioning"])  -- true for wrap text
		GameTooltip:Show()
	end)

	resetButton:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)


	-- Arrow Buttons Configuration
	local arrowDirections = {
		{"+1", 0, 1, "BOTTOM", "TOP", 0, 2},
		{"-1", 0, -1, "TOP", "BOTTOM", 0, -2},
		{"-1", -1, 0, "RIGHT", "LEFT", -2, 0},
		{"+1", 1, 0, "LEFT", "RIGHT", 2, 0},
		{"+25", 0, 25, "BOTTOM", "TOP", 0, 25},
		{"-25", 0, -25, "TOP", "BOTTOM", 0, -25},
		{"-25", -25, 0, "RIGHT", "LEFT", -25, 0},
		{"+25", 25, 0, "LEFT", "RIGHT", 25, 0},
	}

	for _, dir in ipairs(arrowDirections) do
		local button = CreateFrame("Button", dir[1] .. "Button", scrollChild, "UIPanelButtonTemplate")
		button:SetText(dir[1])  -- Replace with arrow symbols or images
		button:SetSize(25, 20) 

		-- Position each button relative to the reset button
		button:SetPoint(dir[4], resetButton, dir[5], dir[6], dir[7])

		button:SetScript("OnClick", function()
			adjustOffset("x", dir[2])  
			adjustOffset("y", dir[3])  
		end)
		
	button:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT") 
		local direction = ""
		local amount = 0
		
		if dir[5] == "TOP" then
			direction = "up"
			amount = abs(dir[1])
		elseif dir[5] == "BOTTOM" then
			direction = "down"
			amount = abs(dir[1])
		elseif dir[5] == "LEFT" then
			direction = "left"
			amount = abs(dir[2])
		elseif dir[5] == "RIGHT" then
			direction = "right"
			amount = abs(dir[2])
		end
		
		
		
		GameTooltip:SetText(L["Move "]..L[direction].." "..tostring(amount))  -- true for wrap text
		GameTooltip:Show()
	end)

	button:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	end


    -- Function to update controls based on current settings
    function panel:UpdateControls()
        enabledCheckbox:SetChecked(RuneReminder_CurrentSettings.enabled)
        soundCheckbox:SetChecked(RuneReminder_CurrentSettings.soundNotification)
        --handsCheckbox:SetChecked(RuneReminder_CurrentSettings.handsNotification)
        --chestCheckbox:SetChecked(RuneReminder_CurrentSettings.chestNotification)
        --legsCheckbox:SetChecked(RuneReminder_CurrentSettings.legsNotification)
        hideReapplyButtonCheckbox:SetChecked(RuneReminder_CurrentSettings.hideReapplyButton)
        hideViewRunesButtonCheckbox:SetChecked(RuneReminder_CurrentSettings.hideViewRunesButton)
        displayRunesCheckbox:SetChecked(RuneReminder_CurrentSettings.displayRunes)
		hideUnknownCheckbox:SetChecked(RuneReminder_CurrentSettings.hideUnknownRunes)
		keepOpenCheckbox:SetChecked(RuneReminder_CurrentSettings.keepOpen)
        simpleTooltipsCheckbox:SetChecked(RuneReminder_CurrentSettings.simpleTooltips)
        disableGlowCheckbox:SetChecked(RuneReminder_CurrentSettings.disableGlow)
		enableCheckedCheckbox:SetChecked(RuneReminder_CurrentSettings.enableChecked)
        rotateRunesCheckbox:SetChecked(RuneReminder_CurrentSettings.runeAlignment == "Vertical")
        swapDirectionCheckbox:SetChecked(RuneReminder_CurrentSettings.runeDirection == "Alternate")
        buttonSizeSlider:SetValue(RuneReminder_CurrentSettings.buttonSize or 25)
		paddingSlider:SetValue(RuneReminder_CurrentSettings.buttonPadding or 1)
		disableSwapCheckbox:SetChecked(RuneReminder_CurrentSettings.disableSwapNotify or false)
		disableRemoveCheckbox:SetChecked(RuneReminder_CurrentSettings.disableRemoveNotify or false)
		disableLeftClickCheckbox:SetChecked(RuneReminder_CurrentSettings.disableLeftClickKeepOpen or false)
		autoToggleOnHoverCheckbox:SetChecked(RuneReminder_CurrentSettings.autoToggleOnHover or false)
		glowOpacitySlider:SetValue(RuneReminder_CurrentSettings.glowOpacity)
		displayAnchorCheckbox:SetChecked(RuneReminder_CurrentSettings.anchorVisible)
		lockAnchorCheckbox:SetChecked(RuneReminder_CurrentSettings.anchorLocked)
		displayRuneSetsCheckbox:SetChecked(RuneReminder_CurrentSettings.displayRuneSets)
		toggleRuneSetsCheckbox:SetChecked(RuneReminder_CurrentSettings.toggleSets)
		toggleRuneSetsTogglesAllCheckbox:SetChecked(RuneReminder_CurrentSettings.toggleSetsTogglesAll)
		setEngraveOnLoadCheckbox:SetChecked(RuneReminder_CurrentSettings.setEngraveOnLoad)
		displayCooldownCheckbox:SetChecked(RuneReminder_CurrentSettings.displayCooldown)
		displayCooldownTextCheckbox:SetChecked(RuneReminder_CurrentSettings.displayCooldownText)
		
		hideUnknownSlotsCheckbox:SetChecked(RuneReminder_CurrentSettings.hideUnknownSlots)
		hideChestSlotCheckbox:SetChecked(RuneReminder_CurrentSettings.hideChestSlot)
		hideLegsSlotCheckbox:SetChecked(RuneReminder_CurrentSettings.hideLegsSlot)
		hideHandsSlotCheckbox:SetChecked(RuneReminder_CurrentSettings.hideHandsSlot)
		hideWaistSlotCheckbox:SetChecked(RuneReminder_CurrentSettings.hideWaistSlot)
		hideFeetSlotCheckbox:SetChecked(RuneReminder_CurrentSettings.hideFeetSlot)
		hideWristsSlotCheckbox:SetChecked(RuneReminder_CurrentSettings.hideWristsSlot)
		hideHeadSlotCheckbox:SetChecked(RuneReminder_CurrentSettings.hideHeadSlot)
		hideNeckSlotCheckbox:SetChecked(RuneReminder_CurrentSettings.hideNeckSlot)
		hideShoulderSlotCheckbox:SetChecked(RuneReminder_CurrentSettings.hideShoulderSlot)
		
		displayRuneSlotsLabelCheckbox:SetChecked(RuneReminder_CurrentSettings.showSlotLabels)
		
		glowTextureDropdown:initialize()
		runeTextureDropdown:initialize()
		tooltipAnchorDropdown:initialize()
		characterToggleDropdown:initialize()
		
		
		UpdateCooldownTextCheckboxState() 
		UpdateRunesWidgetCheckboxStates()
		UpdateRuneSetsCheckboxStates()
		UpdateNotificationCheckboxStates()
		
		
		UpdateOptionLabels()
		UpdateButtonBehaviors()
		
		UpdateActiveProfileSettings()
		SetShownSlots(true)
    end

    panel:SetScript("OnShow", function()
		panel:UpdateControls()
	end)
	
    InterfaceOptions_AddCategory(panel)
end

local function ShowRuneUpdateMessageInChat(oldItemLink, oldRune, newItemLink, newRune, slotName)
    if not RuneReminder_CurrentSettings.enabled and not RuneReminder_CurrentSettings[string.lower(slotName) .. "Notification"] then return end
    local message = string.format("|cff2da3cf[%s]|cffffffff %s %s - ",
    L["Rune Reminder"],
    L["updated"],
    slotName
)
	
    if oldRune and not newRune then
        message = message .. string.format("|cffabdaeb%s|cffffffff %s",
			oldRune.name,
			L["has been removed."]
		)
		DEFAULT_CHAT_FRAME:AddMessage(message, 0, 1, 1)
    elseif oldRune and newRune and oldRune.name ~= newRune.name then
        message = message .. string.format("|cffabdaeb%s|cffffffff %s |cffabdaeb%s|r.",
			oldRune.name,
			L["has been replaced with"],
			newRune.name
		)
		DEFAULT_CHAT_FRAME:AddMessage(message, 0, 1, 1)
	elseif newRune and not oldRune then
        message = message .. string.format("|cffabdaeb%s|cffffffff %s.",
			newRune.name,
			L["has been added"]
		)
		DEFAULT_CHAT_FRAME:AddMessage(message, 0, 1, 1)
    end

    
end


local function ShowRuneUpdatePopup(oldItemLink, oldRune, newItemLink, newRune, slotName)
    if not RuneReminder_CurrentSettings.enabled and not RuneReminder_CurrentSettings[string.lower(slotName) .. "Notification"] then return end
    local baseText = string.format("|cff2da3cf[%s]|cffffffff %s %s!|r\n",
		L["Rune Reminder"],
		L["updated"],
		slotName
	)
    local runeText = ""
    local skillLineAbilityID = oldRune and oldRune.skillLineAbilityID or nil

    -- Mapping slot names to inventory slot IDs
    local slotIDMap = {
        Hands = 10,
        Chest = 5,
        Legs = 7
    }
    local slotID = slotIDMap[slotName] -- TODO: Fix this, items should be passed in 
	
    -- Get the current item link for the slot
    local currentItemLink = GetInventoryItemLink("player", slotID)

    if oldRune and not newRune and not RuneReminder_CurrentSettings.disableRemoveNotify then
        runeText = string.format("|cffabdaeb%s|cffffffff %s.",
			oldRune.name,
			L["has been removed"]
		)
    elseif oldRune and newRune and oldRune.name ~= newRune.name and not RuneReminder_CurrentSettings.disableSwapNotify then
        runeText = string.format("|cffabdaeb%s|cffffffff %s |cffabdaeb%s|r.",
			oldRune.name,
			L["has been replaced with"],
			newRune.name
		)
	else 
		return
    end
	
	local dialog = {
        text = baseText .. runeText,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
	
    if (not RuneReminder_CurrentSettings.hideReapplyButton) and currentItemLink and skillLineAbilityID then
        dialog.button1 = L["Re-Apply "] .. oldRune.name
        dialog.OnButton1 = function()
            EngraveRune(slotName, skillLineAbilityID)
        end
    end

    if not RuneReminder_CurrentSettings.hideViewRunesButton then
        dialog.button3 = L["View Runes"]
        dialog.OnAlt = function()
            if not PaperDollFrame:IsVisible() then
                ToggleCharacter("PaperDollFrame")
            end
        end
    end

    dialog.button4 = CLOSE

    StaticPopupDialogs["RUNE_UPDATE_REMINDER"] = dialog
    StaticPopup_Show("RUNE_UPDATE_REMINDER")
end

function UpdateRunes(includePopups, includeChat)
    for slotID, slotName in pairs(validSlots) do
		C_Engraving.ClearExclusiveCategoryFilter()
		C_Engraving.SetSearchFilter("")
		C_Engraving.RefreshRunesList()
		
        local newRune = C_Engraving.GetRuneForEquipmentSlot(slotID)
        local oldRune = currentRunes[slotID]

        -- Debugging: Print old and new rune information
        if debugging then
            print("Updating runes for slotID:", slotID, "Slot Name:", slotName)
            print("Old Rune:", oldRune and oldRune.name or "None", "New Rune:", newRune and newRune.name or "None")
        end

        -- Check if the rune has been added, removed, or changed
        if (oldRune and not newRune) or (oldRune and newRune and oldRune.name ~= newRune.name) then
            if includePopups then
                ShowRuneUpdatePopup(oldItemLink, oldRune, newItemLink, newRune, slotName)
            end
        end
		if includeChat then
			ShowRuneUpdateMessageInChat(oldItemLink, oldRune, newItemLink, newRune, slotName)
		end

        -- Update the stored rune information
		currentRunes[slotID] = newRune

    end
	
	if not InCombatLockdown() then
		ResetAllButtons()
	end
	
	-- Update all slot buttons cooldowns when equipment changes
	if RuneReminder_CurrentSettings.displayCooldown then
		for slotID, runeInfo in pairs(currentRunes) do
            local button = slotButtons[slotID]
			
		   if button and newRune and runeInfo.name then
                UpdateRuneSlotCooldown(button, runeInfo.name)
           end
        end
	end
	RefreshSpellIDMap()
end
local function RefreshMasqueGroup()
	if Masque then
		group = Masque:Group("RuneReminder", "RuneWidget")
		
	end
	ResetAllButtons()
end


local function PrintCurrentRunes()
       for slotID, slotName in pairs(validSlots) do
            local runeInfo = currentRunes[slotID]
            print(string.format("|cff2da3cf[%s]|r %s: %s",
				L["Rune Reminder"],
				slotName,
				(runeInfo and "|cffabdaeb" .. runeInfo.name or L["None"])
			))
        end
end


local function swapDir()
    -- Toggle between standard and alternate direction
    RuneReminder_CurrentSettings.runeDirection = (RuneReminder_CurrentSettings.runeDirection == "Standard") and "Alternate" or "Standard"
    redrawWidget() 
	if RuneReminderOptionsPanel:IsVisible() then
		RuneReminderOptionsPanel:UpdateControls()
	end
	
end
local function rotate()
    -- Toggle between horizontal and vertical alignment
    RuneReminder_CurrentSettings.runeAlignment = (RuneReminder_CurrentSettings.runeAlignment == "Horizontal") and "Vertical" or "Horizontal"
    redrawWidget() 
	if RuneReminderOptionsPanel:IsVisible() then
		RuneReminderOptionsPanel:UpdateControls()
	end
end



-- Rune Sets
local function ApplyRuneToSlot(slotID, runeID, setName)
	UpdateRuneSetsButtonState()
end


function ApplyRuneSet(setToLoad, setName)
    if not setToLoad or next(setToLoad) == nil then
        print("|cff2da3cf[" .. L["Rune Reminder"] .. "]|r " .. L["Error: Invalid or empty Rune Set."])
        return
    end

	setToApply = setName
	local differences = GetDifferencesBetweenSets(currentRunes, setToLoad)
	
	if next(differences) == nil then -- If no differences, set is correctly applied
		print(string.format("|cff2da3cf[%s]|r %s '%s' %s.",
			L["Rune Reminder"],
			L["Rune Set"],
			setName,
			L["has been fully applied successfully"]
		))

		updateRunes(false, false)
	else
	
		slotID, runeID = next(differences)
		
		local runeDetails = GetRuneDetailsFromID(runeID)
		local slot = GetSlotName(slotID)
		
		if not runeDetails then
			print(string.format("|cff2da3cf[%s]|r %s %s %s %s.",
				L["Rune Reminder"],
				L["Error:"],
				L["Unable to find details for rune ID"],
				runeID
			))

			return
		else 
			
			if not C_Engraving.IsRuneEquipped(runeID) then
				ClearCursor()
				C_Engraving.CastRune(runeID)
					local runeCast = C_Engraving.GetCurrentRuneCast()
					if runeCast and runeCast.equipmentSlot then
						settingRuneID = runeID
						isEngravingRune = true
						
						if slot == "Hands" then
							CharacterHandsSlot:Click()
						elseif slot == "Chest" then
							CharacterChestSlot:Click()
						elseif slot == "Legs" then
							CharacterLegsSlot:Click()
						elseif slot == "Head" then
							CharacterHeadSlot:Click()
						elseif slot == "Neck" then
							CharacterNeckSlot:Click()
						elseif slot == "Feet" then
							CharacterFeetSlot:Click()
						elseif slot == "Shoulder" or slot == "Shoulders" then
							CharacterShoulderSlot:Click()
						elseif slot == "Wrists" or slot == "Wrist" then
							CharacterWristSlot:Click()
						elseif slot == "Waist" or slot == "Belt" then
							CharacterWaistSlot:Click()
						end
							
							ReplaceEnchant()
							StaticPopup_Hide("REPLACE_ENCHANT")
							print(string.format("|cff2da3cf[%s]|r %s |cffabdaeb%s|r %s |cffabdaeb%s|r %s |cffabdaeb%s|r.",
								L["Rune Reminder"],
								L["Applying"],
								runeDetails.name,
								L["to"],
								slot,
								L["for Rune Set"],
								setName
							))

							ClearCursor()
							
					end
				end
				isEngravingRune = false 
			end
		end
end

-- A helper function to compare two rune sets
local function AreRuneSetsIdentical(runeSetA, runeSetB)
    for slotID, skillLineAbilityID in pairs(runeSetA) do
        if runeSetB[slotID] ~= skillLineAbilityID then
            return false
        end
    end
    -- Also check the other way around in case runeSetB has extra entries
    for slotID, skillLineAbilityID in pairs(runeSetB) do
        if runeSetA[slotID] ~= skillLineAbilityID then
            return false
        end
    end
    return true
end

function DeleteRuneSet(setName, sendinChat)
    local characterID = GetCharacterUniqueID()
    if RR_RuneSets[characterID] and RR_RuneSets[characterID][setName] then
        RR_RuneSets[characterID][setName] = nil
        -- Confirmation message moved to OnAccept
		print(string.format("|cff2da3cf[%s]|r %s '%s' %s.",
			L["Rune Reminder"],
			L["Rune Set"],
			setName,
			L["has been deleted"]
		))

    end
end

-- Saving 
function SaveRuneSet(setName)
    RR_RuneSets[characterID] = RR_RuneSets[characterID] or {}

    local currentSet = {}
    for slotID in pairs(validSlots) do
        if currentRunes[slotID] then
            currentSet[slotID] = currentRunes[slotID].skillLineAbilityID
        end
    end

    local existingSet = RR_RuneSets[characterID][setName]
    local identicalSetExists = false
    local identicalSetName

    -- Check against all sets for identical configuration
    for savedSetName, savedSet in pairs(RR_RuneSets[characterID]) do
        if AreRuneSetsIdentical(savedSet, currentSet) then
            identicalSetExists = true
            identicalSetName = savedSetName
            break
        end
    end

    if identicalSetExists and identicalSetName ~= setName then
        StaticPopupDialogs["CONFIRM_IDENTICAL_RUNE_SET"] = {
			text = string.format("|cff2da3cf[%s]|r\n %s '%s' %s",
				L["Rune Reminder"],
				L["An identical Rune Set named"],
				identicalSetName,
				L["already exists."]
			),
			button1 = L["Create New"],
			button3 = string.format("%s '%s' %s '%s'", L["Rename"], identicalSetName, L["to"], setName),
			button4 = L["Cancel"],
			OnButton1 = function()
				RR_RuneSets[characterID][setName] = currentSet
				print(string.format("|cff2da3cf[%s]|r %s '%s' %s",
					L["Rune Reminder"],
					L["New set"],
					setName,
					L["created with identical runes."]
				))
			end,
			OnAlt = function()
				RR_RuneSets[characterID][setName] = currentSet
				RR_RuneSets[characterID][identicalSetName] = nil
				print(string.format("|cff2da3cf[%s]|r %s '%s' %s '%s'.",
					L["Rune Reminder"],
					L["Set"],
					identicalSetName,
					L["renamed to"],
					setName
				))
			end,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
			preferredIndex = 3, 
		}
		
        StaticPopup_Show("CONFIRM_IDENTICAL_RUNE_SET")
    elseif existingSet then
        if AreRuneSetsIdentical(existingSet, currentSet) then
            print(string.format("|cff2da3cf[%s]|r %s '%s' %s",
				L["Rune Reminder"],
				L["Set"],
				setName,
				L["already exists with the same runes."]
			))

        else
            -- Prompt user for update
            StaticPopupDialogs["CONFIRM_UPDATE_RUNE_SET"] = {
                text = string.format("|cff2da3cf[%s]|r\n%s '%s' %s", L["Rune Reminder"], L["A set named"], setName, L["already exists. Update with new runes?"]),
                button1 = L["Yes"],
                button2 = L["No"],
                OnAccept = function()
                    RR_RuneSets[characterID][setName] = currentSet
                    print(string.format("|cff2da3cf[%s]|r %s %s.", L["Rune Reminder"], setName, L["updated with new runes"]))
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
                preferredIndex = 3, -- Avoid taint
            }
            StaticPopup_Show("CONFIRM_UPDATE_RUNE_SET")
        end
    else
        -- Save the new set and print out the details
        RR_RuneSets[characterID][setName] = currentSet
        print(string.format("|cff2da3cf[%s]|r %s '%s' %s:", L["Rune Reminder"], L["Rune Set"], setName, L["saved with"]))
        for slotID, skillLineAbilityID in pairs(currentSet) do
            local runeDetails = GetRuneDetailsFromID(skillLineAbilityID)
            if runeDetails then
                print(string.format("|cff2da3cf[%s]|r %s: |cffabdaeb%s", L["Rune Reminder"], GetSlotName(slotID), runeDetails.name))
            else
                print(string.format("|cff2da3cf[%s]|r %s: |cffabdaeb%s", L["Rune Reminder"], GetSlotName(slotID), L["Unknown Rune"]))
            end
        end
    end
end




function LoadRuneSet(setName, manual)
    local characterID = GetCharacterUniqueID()
    local setToLoad = RR_RuneSets[characterID] and RR_RuneSets[characterID][setName]

    if not setToLoad then
        print(string.format("|cff2da3cf[%s]|r %s '%s'.",
			L["Rune Reminder"],
			L["No saved set named"],
			setName
		))

        return
    end
	
    local differences = GetDifferencesBetweenSets(currentRunes, setToLoad)
    if next(differences) == nil then -- Check if differences table is empty
        print(string.format("|cff2da3cf[%s]|r %s '%s'.",
			L["Rune Reminder"],
			L["You are already using the Rune Set"],
			setName
		))

        return
	
    end

	local slotID, runeID = next(differences)	

	-- Generate the detailed change message
	local changeDetails = {}
	for slotID, newRuneID in pairs(differences) do
		local slotName = GetSlotName(slotID) or L["Unknown Slot"]
		local oldRuneDetails = currentRunes[slotID] and GetRuneDetailsFromID(currentRunes[slotID].skillLineAbilityID)
		local oldRuneName = oldRuneDetails and oldRuneDetails.name or L["No Rune"]

		local newRuneDetails = GetRuneDetailsFromID(newRuneID)
		local newRuneName = newRuneDetails and newRuneDetails.name or L["Unknown Rune"]

		table.insert(changeDetails, "" .. slotName .. ": " .. oldRuneName .. " -> |cffabdaeb" .. newRuneName)
	end

    -- If in manual mode, display the rune selection buttons for the user to apply runes manually
    if manual then
	
        print(string.format("|cff2da3cf[%s]|r %s '%s' %s",
			L["Rune Reminder"],
			L["To load the"],
			setName,
			L["Rune Set, apply the following runes:"]
		))

		for slotID, newRuneID in pairs(differences) do
			local slotName = GetSlotName(slotID) or L["Unknown Slot"]
			local oldRuneDetails = currentRunes[slotID] and GetRuneDetailsFromID(currentRunes[slotID].skillLineAbilityID)
			local oldRuneName = oldRuneDetails and oldRuneDetails.name or L["No Rune"]

			local newRuneDetails = GetRuneDetailsFromID(newRuneID)
			local newRuneName = newRuneDetails and newRuneDetails.name or L["Unknown Rune"]

			-- Updated format to include [Rune Reminder] and slot names
			print(string.format("|cff2da3cf[%s]|r %s: %s -> |cffabdaeb%s",
				L["Rune Reminder"],
				slotName,
				oldRuneName,
				newRuneName
			))

		end
		
    else
        -- Existing logic for automatic application of rune set
        ApplyRuneSet(setToLoad, setName)
    end
	
end

local function ListRuneSets()
    local characterKey = GetCharacterUniqueID()

    local sets = RR_RuneSets[characterKey]
    if not sets or next(sets) == nil then
        print(string.format("|cff2da3cf[%s]|r %s %s %s",
			L["Rune Reminder"],
			L["No Rune Sets saved for"],
			characterKey,
			"."
		))

        return
    end

    for setName, setSlots in pairs(sets) do
        print(string.format("|cff2da3cf[%s]|r %s: %s",
			L["Rune Reminder"],
			L["Rune Set:"],
			setName
		))
		for slotID, runeID in pairs(setSlots) do
			local slotName = GetSlotName(slotID)
			local runeDetails = GetRuneDetailsFromID(runeID)
			if runeDetails then
				print(string.format("|cff2da3cf[%s]|r  %s: |cffabdaeb%s",
					L["Rune Reminder"],
					slotName,
					runeDetails.name
				))
			else
				print(string.format("|cff2da3cf[%s]|r  %s: %s",
					L["Rune Reminder"],
					slotName,
					L["No rune"]
				))
			end
		end

    end
end




-- Slash Command Handler
local function HandleSlashCommand(msg)
    local command, rest = msg:match("^(%S*)%s*(.-)$")

    local function toggleSetting(settingName, state)
		if settingName == "displayRunes" then
			if state == "on" then
				RuneReminder_CurrentSettings.displayRunes = true
				print(string.format("|cff2da3cf[%s]|r %s", L["Rune Reminder"], L["Runes Widget Enabled"]))

			elseif state == "off" then 
				RuneReminder_CurrentSettings.displayRunes = false
				print(string.format("|cff2da3cf[%s]|r %s", L["Rune Reminder"], L["Runes Widget Disabled"]))

			else 
			RuneReminder_CurrentSettings.displayRunes = not RuneReminder_CurrentSettings.displayRunes
            local stateText = RuneReminder_CurrentSettings.displayRunes and L["Enabled"] or L["Disabled"]
            print(string.format("|cff2da3cf[%s]|cffffffff %s %s", L["Rune Reminder"], L["Runes Widget"], stateText))

			end
			if RuneReminderOptionsPanel:IsVisible() then
				UpdateRunesWidgetCheckboxStates()
			end
			ShowHideAnchor()
			CreateSlotButtons(true)
		elseif settingName == "keepOpen" then
			toggleKeepOpen()
        elseif state == "on" then
            RuneReminder_CurrentSettings[settingName] = true
            print(string.format("|cff2da3cf[%s]|r %s %s %s", L["Rune Reminder"], settingName, L["Enabled"]))
			if settingName == "altLoad" then
			print(string.format("|cff2da3cf[%s]|r|cffabdaeb %s:|cffffffff %s", L["Rune Reminder"], L["WARNING"], L["This should only be used if you are experiencing conflicts with other addons. You may need to open your character window for your runes to initially load."]))
			end
        elseif state == "off" then
            RuneReminder_CurrentSettings[settingName] = false
            print(string.format("|cff2da3cf[%s]|cffffffff %s %s %s", L["Rune Reminder"], settingName, L["Disabled"]))
        else
            RuneReminder_CurrentSettings[settingName] = not RuneReminder_CurrentSettings[settingName]
            local stateText = RuneReminder_CurrentSettings[settingName] and "Enabled" or "Disabled"
            print(string.format("|cff2da3cf[%s]|cffffffff %s %s", L["Rune Reminder"], settingName, stateText))
        end
		
		if command == "debugging" then
			debugging = RuneReminder_CurrentSettings.debugging or false
		end

		if settingName == "disableGlow" or "enableChecked" then
			for slotID in pairs(validSlots) do
				UpdateRuneSlotButton(slotID) 
			end  
		end
		
		UpdateActiveProfileSettings()
    end

    if command == "sound" then 
        toggleSetting("soundNotification", rest)
    elseif command == "enable" or command == "on" then
        toggleSetting("enabled", "on")
    elseif command == "disable" or command == "off" then
        toggleSetting("enabled", "off")
    elseif command == "altload" then
        toggleSetting("alternateLoad", rest)
	elseif command == "displayrunes" then
        toggleSetting("displayRunes", rest)
	elseif command == "debugging" then
        toggleSetting("debugging", rest)
	elseif command == "disableGlow" or command == "disableglow" then
        toggleSetting("disableGlow", rest)
	elseif command == "simpleTooltips" or comand == "tooltips" then
        toggleSetting("simpleTooltips", rest)
    elseif command == "keepOpen" or command == "keepopen" then
        toggleSetting("keepOpen", rest)
    elseif command == "settings" then
        print(string.format("|cff2da3cf[%s]|r %s", L["Rune Reminder"], L["Current Settings:"]))
        for setting, value in pairs(RuneReminder_CurrentSettings) do
			if setting ~= "debugging" then 
				print(string.format("|cff2da3cf[%s]|cffffffff %s: %s", L["Rune Reminder"], setting, tostring(value)))
			end
        end
	elseif command == "reapply" then
		if rest == "on" or rest == "enable" or rest == "show" then
			toggleSetting("hideReapplyButton", "off")
		elseif rest == "off" or rest == "disable" or rest == "hide" then
			toggleSetting("hideReapplyButton", "on")
		else
			toggleSetting("hideReapplyButton")
		end
    elseif command == "viewrunes" then
        if rest == "on" or rest == "enable" or rest == "show" then
			toggleSetting("hideViewRunesButton", "off")
		elseif rest == "off" or rest == "disable" or rest == "hide" then
			toggleSetting("hideViewRunesButton", "on")
		else
			toggleSetting("hideViewRunesButton")
		end
	elseif command == "list" then
	        -- List current runes
			print(string.format("|cff2da3cf[%s]|r|cffffffff %s", L["Rune Reminder"], L["Currently Applied Runes:"]))
        for slotID, slotName in pairs(validSlots) do
            local runeInfo = currentRunes[slotID]
            if runeInfo then
                print(string.format("|cff2da3cf[%s]|r|cffffffff %s:|r|cffabdaeb %s", L["Rune Reminder"], slotName, runeInfo.name))
            else
                print(string.format("|cff2da3cf[%s]|r|cffffffff %s:|r %s", L["Rune Reminder"], slotName, L["None"]))
            end
        end
	elseif command == "reset" then
        -- Reset currentRunes
        print(string.format("|cff2da3cf[%s]|r %s", L["Rune Reminder"], L["Runes Widget reset."]))
		initFrame(true)
		ResetAllButtons()
	elseif command == "refresh" then
		RefreshMasqueGroup()
    elseif command == "update" then
        -- Force update of currentRunes
        UpdateRunes(true, true)
		InitializeRuneDetails()
		SetShownSlots(true)
		ResetAllButtons()
        print(string.format("|cff2da3cf[%s]|r %s", L["Rune Reminder"], L["Runes updated:"]))
		PrintCurrentRunes()
    elseif command == "options" then
        -- Directly open the Rune Reminder options panel
        InterfaceOptionsFrame_OpenToCategory(RuneReminderOptionsPanel)
        InterfaceOptionsFrame_OpenToCategory(RuneReminderOptionsPanel) -- Call twice due to a Blizzard UI bug
	elseif command == "rotate" then
		rotate()		
        print(string.format("|cff2da3cf[%s]|r %s %s %s", L["Rune Reminder"], L["Rune Alignment set to"], RuneReminder_CurrentSettings.runeAlignment))
    elseif command == "swapdir" then
		swapDir()
        print(string.format("|cff2da3cf[%s]|r %s %s %s", L["Rune Reminder"], L["Rune Direction set to"], RuneReminder_CurrentSettings.runeDirection))
	elseif command == "howto" or command == "instructions" then
        print(string.format("|cff2da3cf[%s]|r %s", L["Rune Reminder"], L["Shift Click the widget (or type /rr options) to open the Options Panel. Here you can configure the notifications and runes widget to your preferences."]))
		print(string.format("|cff2da3cf[%s]|r %s", L["Rune Reminder"], L["Left Click + Drag the anchor to position the Runes Widget. Ctrl+Click will lock/unlock it, and Right Click will hide the anchor."]))
		print(string.format("|cff2da3cf[%s]|r %s", L["Rune Reminder"], L["Clicking on a gear slot expands the runes for that slot. Right-clicking toggle expand/collapses all slots."]))
		print(string.format("|cff2da3cf[%s]|r %s", L["Rune Reminder"], L["Select a rune to apply it to the appropriate equipment slot, no need to open the character window or confirm which item."]))
		print(string.format("|cff2da3cf[%s]|r %s", L["Rune Reminder"], L["Type /rr help for more commands."]))

   elseif command == "help" or command == "commands" then
	
		print("|cff2da3cf[" .. L["Rune Reminder"] .. "]|cffffffff " .. L["Version"] .. " " .. (version or L["Unknown"]) .. " - " .. L["Available Commands:"])
		print("|cff2da3cf[" .. L["Rune Reminder"] .. "]|r /rr |cffabdaeb[enable/on]|r - " .. L["Enable popup notifications"])
		print("|cff2da3cf[" .. L["Rune Reminder"] .. "]|r /rr |cffabdaeb[disable/off]|r - " .. L["Disable popup notifications"])
		print("|cff2da3cf[" .. L["Rune Reminder"] .. "]|r /rr |cffabdaebsound [on/off]|r - " .. L["Toggle sound notifications"])
		print("|cff2da3cf[" .. L["Rune Reminder"] .. "]|r /rr |cffabdaebreapply [on/off]|r - " .. L["Toggle the Re-Apply Rune button in popups"])
		print("|cff2da3cf[" .. L["Rune Reminder"] .. "]|r /rr |cffabdaebviewrunes [on/off]|r - " .. L["Toggle the View Runes button in popups"])
		print("|cff2da3cf[" .. L["Rune Reminder"] .. "]|r /rr |cffabdaeboptions|r - " .. L["Loads the options window"])
		print("|cff2da3cf[" .. L["Rune Reminder"] .. "]|r /rr |cffabdaebdisplayrunes|r - " .. L["Enables or disables the Runes Widget"])
		print("|cff2da3cf[" .. L["Rune Reminder"] .. "]|r /rr |cffabdaebreset|r - " .. L["Resets the positioning of the Runes Widget"])
		print("|cff2da3cf[" .. L["Rune Reminder"] .. "]|r /rr |cffabdaebrotate|r - " .. L["Rotates the Runes Widget"])
		print("|cff2da3cf[" .. L["Rune Reminder"] .. "]|r /rr |cffabdaebswapdir|r - " .. L["Changes the direction of the rune buttons"])
		print("|cff2da3cf[" .. L["Rune Reminder"] .. "]|r /rr |cffabdaebsettings|r - " .. L["Display current settings"])
		print("|cff2da3cf[" .. L["Rune Reminder"] .. "]|r /rr |cffabdaeblist|r - " .. L["Display currently loaded runes"])
		print("|cff2da3cf[" .. L["Rune Reminder"] .. "]|r /rr |cffabdaebsets|r - " .. L["List the saved Rune Sets"])
		print("|cff2da3cf[" .. L["Rune Reminder"] .. "]|r /rr |cffabdaebsave {setname}|r - " .. L["Save a Rune Set with the specific name"])
		print("|cff2da3cf[" .. L["Rune Reminder"] .. "]|r /rr |cffabdaebdelete {setname}|r - " .. L["Delete a Rune Set with the specific name"])
		print("|cff2da3cf[" .. L["Rune Reminder"] .. "]|r /rr |cffabdaeb[howto/instructions]|r - " .. L["Basic how-to on using Rune Reminder"])
		print("|cff2da3cf[" .. L["Rune Reminder"] .. "]|r /rr |cffabdaeb[help/commands]|r - " .. L["Show this help message"])

	elseif command == "save" and rest ~= "" then -- Rune Sets 
			SaveRuneSet(rest)
	elseif command == "load" and rest ~= "" then
			LoadRuneSet(rest, false)
	elseif command == "delete" and rest ~= "" then
        -- Show the confirmation dialog before deleting
        --StaticPopup_Show("CONFIRM_DELETE_RUNE_SET", rest).data = rest
		PrepDeleteRuneSet(rest)
	elseif command == "sets" then
		ListRuneSets()
    else
        -- Default behavior for /rr
        local version = GetAddOnMetadata("RuneReminder", "Version")
        print("|cff2da3cf[Rune Reminder]|r Addon " .. (RuneReminder_CurrentSettings.enabled and L["Enabled"] or L["Disabled"]) .. " " .. L["Version"] ..  (version or L["Unknown"]))
        print("|cff2da3cf[" .. L["Rune Reminder"] .. "]|r " .. L["Type"] .. " |cffabdaeb/rr help|r " .. L["for help and additional commands"])
    end
end


-- Event Handler Function
local function OnEvent(self, event, ...)
	if debugging then
	print("-----EVENT:"..event)
	end
	
    if event == "ADDON_LOADED" and ... == addonName then
		C_Timer.After(2,function()

		if Masque and not group then
			group = Masque:Group("RuneReminder", "RuneWidget")
		end
					
		    InitializeRRSettings()
			CreateOptionsPanel()
			ApplyButtonSizes()  
			initFrame()
			ShowHideAnchor()
			CreateSlotButtons(true) 
			
			print("|cff2da3cf[Rune Reminder]|r Version ".. (version or "Unknown") .." Loaded")
			-- Toggle character screen if alternateLoad is not enabled
            if not RuneReminder_CurrentSettings.alternateLoad then
                ToggleCharacter("PaperDollFrame")
                ToggleCharacter("PaperDollFrame")
			else 
				print("|cff2da3cf[" .. L["Rune Reminder"] .. "]|r|cffabdaeb " .. L["WARNING"] .. ":|cffffffff " .. L["Alternate Loading enabled. Toggle this with /rr altload. This should only be used if you are experiencing conflicts with other addons. You may need to open your character window for your runes to initially load."])
            end
			
			C_Timer.After(1.5,function() 
				LoadProfileSettings(currentProfile)
				-- Load current rune information
				UpdateRunes(false, true)
				SetShownSlots(true)
				UpdateButtonBehaviors()
				
			end)
			
        end)
	elseif event == "VARIABLES_LOADED" then
		--InitializeCharacterSettings()
	elseif event == "PLAYER_ENTERING_WORLD" then
        -- Actions when the player is entering the world
		InitializeRRSettings()
    elseif event == "PLAYER_EQUIPMENT_CHANGED" then
        -- Actions when the player's equipment changes
        UpdateRunes(true, true)
		if RuneReminder_CurrentSettings.soundNotification then 
			PlaySound(8959)
		end
		if RuneReminder_CurrentSettings.displayCooldown then 
			-- Update all slot buttons cooldowns when equipment changes
			for slotID, runeInfo in pairs(currentRunes) do
				local button = slotButtons[slotID]
				if button and runeInfo and runeInfo.name then
					UpdateRuneSlotCooldown(button, runeInfo.name)
				end
			end
		end

	elseif event == "NEW_RECIPE_LEARNED" then
	local recipeID = ...
		
    if debugging then
        print("New Recipe Learned: " .. recipeID)
    end
	
	C_Engraving.ClearExclusiveCategoryFilter()
	C_Engraving.SetSearchFilter("")
	
	--local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)
    local categories = C_Engraving.GetRuneCategories(false, false)

    for _, category in ipairs(categories) do
		C_Engraving.ClearCategoryFilter(category)
        local runes = C_Engraving.GetRunesForCategory(category, false)
        
	    if debugging then
			print("New Recipe Learned: " .. recipeID)
		end	
		
        for _, rune in ipairs(runes) do
			if debugging then
				print(rune.skillLineAbilityID)
			end
			
            if rune.skillLineAbilityID == recipeID then --recipeInfo.skillLineAbilityID then
                local slotName = GetSlotName(category)
                local shouldNotify = RuneReminder_CurrentSettings.enabled
                
				print("|cff2da3cf[" .. L["Rune Reminder"] .. "]|r " .. L["New "] .. slot .. " " .. L["rune Learned:"] .. " |cffabdaeb" .. rune.name .. "|r")
				
                if shouldNotify then
                    local currentRune = currentRunes[category]
					local dialogText = "|cff2da3cf[" .. L["Rune Reminder"] .. "]|cffffffff " .. L["You've learned a new "] .. slotName .. L[" rune:"] .. "|r" .. "|cffabdaeb" .. rune.name .. "|r."
                    
                    if currentRune then
                        dialogText = dialogText .. L[" Replace "] .. "|cffabdaeb" .. currentRune.name .. "|cffffffff" .. L[" with "] .. "|cffabdaeb" .. rune.name .. "|cffffffff" .. L["?"]
                    else
                        dialogText = dialogText .. L[" Engrave "] .. slotName .. "?"
                    end

                    StaticPopupDialogs["ENGRAVE_NEW_RUNE"] = {
                        text = dialogText,
                        button1 = L["Yes"],
                        button2 = L["No"],
                        OnAccept = function()
                            EngraveRune(slotName, rune.skillLineAbilityID)
                        end,
                        timeout = 30,
                        whileDead = true,
                        hideOnEscape = true,
                        preferredIndex = 3, -- Reduce taint issues
                    }
                    
                    StaticPopup_Show("ENGRAVE_NEW_RUNE")
                end
                break -- Only handle one rune at a time
            end
			
        end
		RefreshRuneSelectionButtons(category)
    end
	InitializeRuneDetails()
	SetShownSlots(true)
	elseif event == "ENGRAVING_MODE_CHANGED" then
		local emode = ...
		if PaperDollFrame:IsVisible() and RuneReminder_CurrentSettings.engravingMode == "TOGGLE"  then
			RuneReminder_CurrentSettings.collapseRunesPanel = not emode	
		end
		
    elseif event == "RUNE_UPDATED" then
        -- Actions when a rune is updated
		local rune = ...
		
		if rune then
			if settingRuneID == 0 then
				UpdateRunes(false, true)
			else
				settingRuneID = 0
				UpdateRunes(false, false)
			end
			
			UpdateRuneSetsButtonState()
		end

	elseif event == "SETTINGS_CHANGED" then
        CreateSlotButtons(true)  -- Recreate buttons to apply new positions
		RuneReminderOptionsPanel:UpdateControls()
	elseif event == "UNIT_SPELLCAST_SENT" then
	local _, target, cast, spellID = ...
       if debugging then
		local info = GetSpellInfo(spellID)
		print(spellID)
		print("yo")
		print(info)
	   end
	elseif event == "SPELL_UPDATE_COOLDOWN" or event == "SPELL_UPDATE_USABLE" then
	  -- Loop through all known runes and update cooldowns
	  
	  if not RuneReminder_CurrentSettings then
		InitializeRRSettings()
	  end
	  
	  if RuneReminder_CurrentSettings.displayCooldown then
	     for slotID, runeInfo in pairs(currentRunes) do
            local button = slotButtons[slotID]
            if runeInfo and button and button.cooldown then
                UpdateRuneSlotCooldown(button, runeInfo.name)
            end
        end
	  end

    end
end


-- Register the slash command
SLASH_RUNEREMINDER1 = "/rr"
SLASH_RUNEREMINDER2 = "/runereminder"
SlashCmdList["RUNEREMINDER"] = HandleSlashCommand


-- Register Events and Set Script
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
frame:RegisterEvent("ENGRAVING_MODE_CHANGED")
frame:RegisterEvent("RUNE_UPDATED")
frame:RegisterEvent("NEW_RECIPE_LEARNED")
frame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
frame:RegisterEvent("SPELL_UPDATE_USABLE")
--frame:RegisterEvent("UNIT_SPELLCAST_SENT")
frame:SetScript("OnEvent", OnEvent)

frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")

function ShowHideAnchor()

	local isVisible = RuneReminder_CurrentSettings.anchorVisible
	
	if not RuneReminder_CurrentSettings.displayRunes and not RuneReminder_CurrentSettings.displayRuneSets then
		isVisible = false
	end
	
	if frame.texture then
		if isVisible then 
			frame.texture:SetAlpha(0.5)
			frame.text:SetAlpha(0.5)
		else 
			frame.texture:SetAlpha(0)
			frame.text:SetAlpha(0)
		end
	elseif IsVisible then
		initFrame()
	end
	
	
	if isVisible then
			frame:SetScript("OnEnter", function(self)

				GameTooltip:SetOwner(self, RuneReminder_CurrentSettings.tooltipAnchor)
				
				-- Define the text based on settings
				local lockStatus = RuneReminder_CurrentSettings.anchorLocked and "locked" or "unlocked"
				local lockAction = RuneReminder_CurrentSettings.anchorLocked and "unlock" or "lock"
				local visibilityAction = RuneReminder_CurrentSettings.anchorVisible and "hide" or "show"

				GameTooltip:SetText(string.format("|cff2da3cf[%s]|r|cffabdaeb\n%s|r %s |cffabdaeb%s|r.\n|cffabdaeb%s |r+ |cffabdaeb%s|r %s |cffabdaeb%s|r.\n|cffabdaeb%s |r+ |cffabdaeb%s |r%s |cffabdaeb%s|r.\n|cffabdaeb%s |r%s |cffabdaeb%s|r.", 
				L["Rune Reminder"], 
				L["Left Click"], L["to"], L["Drag"],
				L["Left Click"], L["Ctrl"], L["to"], L["lock/unlock"],
				L["Left Click"], L["Shift"], L["to"], L["open the Options Panel"],
				L["Right Click"], L["to"], L["hide the anchor"]), 1, 1, 1, 1, true)
				GameTooltip:Show()

			end)
			
			frame:SetScript("OnLeave", function(self)
				GameTooltip:Hide()
			end)
	else
		frame:SetScript("OnEnter", nil)
		frame:SetScript("OnLeave", nil)
	end
	
end


frame:SetScript("OnMouseDown", function(self, button)
	local isLocked = RuneReminder_CurrentSettings.anchorLocked or false
	local isVisible = RuneReminder_CurrentSettings.anchorVisible or true
	
    if button == "LeftButton" and IsControlKeyDown() then
		RuneReminder_CurrentSettings.anchorLocked = not isLocked
	elseif button == "LeftButton" and IsShiftKeyDown() then
		ToggleOptionsPanel()
	elseif button == "LeftButton" and not isLocked then
        self:StartMoving()
		GameTooltip:Hide()
    elseif button == "RightButton" then
		RuneReminder_CurrentSettings.anchorVisible = not RuneReminder_CurrentSettings.anchorVisible
		ShowHideAnchor()
    end
	
	if RuneReminderOptionsPanel:IsVisible() then
		RuneReminderOptionsPanel:UpdateControls()
	else 
		UpdateActiveProfileSettings()
	end
	
end)



frame:SetScript("OnMouseUp", function(self)
    self:StopMovingOrSizing()
	local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
	RuneReminder_CurrentSettings.charLocation = {}
	

	-- Apply the new position to the frame
	frame:ClearAllPoints()
	frame:SetPoint(point, relativeTo, relativePoint, xOfs, yOfs)
	RuneReminder_CurrentSettings.charLocation.xOfs = xOfs
	RuneReminder_CurrentSettings.charLocation.yOfs = yOfs
	RuneReminder_CurrentSettings.charLocation.relativePoint = relativePoint
	
	UpdateActiveProfileSettings()
end)


-- Add StaticPopupDialog for saving rune set
StaticPopupDialogs["SAVE_RUNE_SET"] = {
    text = L["Enter a name for the Rune Set:"],
    button1 = L["Save"],
    button2 = L["Cancel"],
    hasEditBox = true,
	OnShow = function(self)
        self.editBox:SetFocus()
        self.editBox:SetScript("OnEnterPressed", function()
            local setName = self.editBox:GetText()
            if setName ~= "" then
                SaveRuneSet(setName) 
            end
            self:Hide()
        end)
    end,
    OnAccept = function(self)
        local setName = self.editBox:GetText()
        if setName ~= "" then
            SaveRuneSet(setName) 
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3, -- Reduce taint issues
}

StaticPopupDialogs["CONFIRM_RESET_SETTINGS"] = {
    text = L["Are you sure you want to reset the settings to default?"],
    button1 = L["Yes"],
    button2 = L["No"],
    OnAccept = function() ResetSettings() end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}
StaticPopupDialogs["CONFIRM_DELETE_SETTINGS"] = {
    text = L["Are you sure you want to delete the settings and revert to default?"],
    button1 = L["Yes"],
    button2 = L["No"],
    OnAccept = function() ResetSettings() end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}


