local addonName, ItemProfConstants = ...

local frame = CreateFrame( "Frame" )
frame.name = addonName

local NUM_PROFS_TRACKED = ItemProfConstants.NUM_PROF_FLAGS

local profsCheck
local questCheck
local vendorCheck
local dmfCheck
local classQuestLabel
local profQuestLabel
local iconSizeSlider
local iconSizeLabel
local iconDemoTexture

local PROF_CHECK = {}
local QUEST_CHECK = {}

local configDefaultShowProfs = true
local configDefaultShowQuests = true
local configDefaultProfFlags = 0xFF
local configDefaultQuestFlags = 0xFFFFF
local configDefaultIncludeVendor = false
local configDefaultIconSize = 16
local configDefaultShowDMF = true

local userVariables



local function SaveAndQuit() 

	local profFlags = 0
	-- Ignore the profession flags if master profession checkbox is unchecked
	for i=0, NUM_PROFS_TRACKED-1 do
		local bitMask = bit.lshift( 1, i )
		local isChecked = PROF_CHECK[ bitMask ]:GetChecked()
		if isChecked then
			profFlags = profFlags + bitMask
		end
	end
	
	local questFlags = 1		-- Normal quests flag
	for i=1, 19 do
		local bitMask = bit.lshift( 1, i )
		local isChecked = QUEST_CHECK[ bitMask ]:GetChecked()
		if isChecked then
			questFlags = questFlags + bitMask
		end
	end
	
	
	userVariables.showProfs = profsCheck:GetChecked()
	userVariables.showQuests = questCheck:GetChecked()
	userVariables.profFlags = profFlags
	userVariables.questFlags = questFlags
	userVariables.includeVendor = vendorCheck:GetChecked()
	userVariables.iconSize = iconSizeSlider:GetValue()
	userVariables.showDMF = dmfCheck:GetChecked()

	ItemProfConstants:ConfigChanged()
end



local function ToggleProfCheckbox() 

	local isChecked = profsCheck:GetChecked()
	-- How do I call as a stored function CheckButton:Enable()?
	for k,v in pairs( PROF_CHECK ) do
		if isChecked then
			v:Enable()
		else
			v:Disable()
		end
	end
	
end


local function ToggleQuestCheckbox() 

	local isChecked = questCheck:GetChecked()
	if isChecked then
		for k,v in pairs( QUEST_CHECK ) do
			v:Enable()
		end
	else
		for k,v in pairs( QUEST_CHECK ) do
			v:Disable()
		end
	end
	
end


local function RefreshWidgets()

	-- Sync the widgets state with the config variables
	profsCheck:SetChecked( userVariables.showProfs )
	questCheck:SetChecked( userVariables.showQuests )
	vendorCheck:SetChecked( userVariables.includeVendor )
	dmfCheck:SetChecked( userVariables.showDMF )
	local profFlags = userVariables.profFlags
	local questFlags = userVariables.questFlags
	iconSizeSlider:SetValue( userVariables.iconSize )
	
	-- Update the profession checkboxes
	for i=0, NUM_PROFS_TRACKED-1 do
		local bitMask = bit.lshift( 1, i )
		local isSet = bit.band( profFlags, bitMask )
		PROF_CHECK[ bitMask ]:SetChecked( isSet ~= 0 )
	end

	-- Update the quest checkboxes
	for i=1, 19 do
		local bitMask = bit.lshift( 1, i )
		local isSet = bit.band( questFlags, bitMask )
		QUEST_CHECK[ bitMask ]:SetChecked( isSet ~= 0 )
	end
	
	-- Set checkboxes enabled/disabled
	ToggleProfCheckbox()
	ToggleQuestCheckbox()
end


local function IconSizeChanged( self, value ) 

	-- Called when the icon slider widget changes value
	iconDemoTexture:SetSize( value, value )
	iconSizeLabel:SetText( value )
end


local function InitVariables( self, event, loadedName )
	
	if loadedName ~= addonName then
		return
	end

	frame:UnregisterEvent( "ADDON_LOADED" )

	local configRealm = ItemProfConstants.configTooltipIconsRealm
	local configChar = ItemProfConstants.configTooltipIconsChar
	
	if not ItemTooltipIconsConfig then
		ItemTooltipIconsConfig = {}
	end
	
	if not ItemTooltipIconsConfig[ configRealm ] then
		ItemTooltipIconsConfig[ configRealm ] = {}
	end
	
	if not ItemTooltipIconsConfig[ configRealm ][ configChar ] then
		ItemTooltipIconsConfig[ configRealm ][ configChar ] = {}
	end
	
	userVariables = ItemTooltipIconsConfig[ configRealm ][ configChar ]
	
	if userVariables.showProfs == nil then
		userVariables.showProfs = configDefaultShowProfs
	end
	
	if userVariables.showQuests == nil then
		userVariables.showQuests = configDefaultShowQuests
	end
	
	if userVariables.profFlags == nil then
		userVariables.profFlags = configDefaultProfFlags
	end
	
	if userVariables.questFlags == nil then
		userVariables.questFlags = configDefaultQuestFlags
	end
	
	if userVariables.includeVendor == nil then
		userVariables.includeVendor = configDefaultIncludeVendor
	end
	
	if userVariables.iconSize == nil then
		userVariables.iconSize = configDefaultIconSize
	end
	
	if userVariables.showDMF == nil then
		userVariables.showDMF = configDefaultShowDMF
	end
	
	
	RefreshWidgets()
	ItemProfConstants:ConfigChanged()
end


local function CreateCheckbox( name, x, y, label, tooltip )

	local check = CreateFrame( "CheckButton", name, frame, "ChatConfigCheckButtonTemplate" ) --"OptionsCheckButtonTemplate" )
	_G[ name .. "Text" ]:SetText( label )
	check.tooltip = tooltip
	check:SetPoint( "TOPLEFT", x, y )

	return check
end


local function CreateProfessionWidgets() 

	profsCheck = CreateCheckbox( "ItemTooltipIconsConfigCheck0", 20, -50, " Enable Profession Icons", "If enabled profession icons will be displayed on items that are crafting materials" )
	profsCheck:SetScript( "OnClick", ToggleProfCheckbox )

	PROF_CHECK[ 1 ] = CreateCheckbox( "ItemTooltipIconsConfigCheck0a", 45, -70, " Cooking", nil )
	PROF_CHECK[ 2 ] = CreateCheckbox( "ItemTooltipIconsConfigCheck0b", 45, -90, " First Aid", nil )
	PROF_CHECK[ 4 ] = CreateCheckbox( "ItemTooltipIconsConfigCheck0c", 45, -110, " Alchemy", nil )
	PROF_CHECK[ 8 ] = CreateCheckbox( "ItemTooltipIconsConfigCheck0d", 45, -130, " Blacksmithing", nil )
	PROF_CHECK[ 16 ] = CreateCheckbox( "ItemTooltipIconsConfigCheck0e", 245, -70, " Enchanting", nil )
	PROF_CHECK[ 32 ] = CreateCheckbox( "ItemTooltipIconsConfigCheck0f", 245, -90, " Engineering", nil )
	PROF_CHECK[ 64 ] = CreateCheckbox( "ItemTooltipIconsConfigCheck0g", 245, -110, " Leatherworking", nil )
	PROF_CHECK[ 128 ] = CreateCheckbox( "ItemTooltipIconsConfigCheck0h", 245, -130, " Tailoring", nil )
end

local function CreateQuestWidgets() 
	
	questCheck = CreateCheckbox( "ItemTooltipIconsConfigCheck1", 20, -180, " Enable Quest Icons", "If enabled quest icons will be displayed on items that are needed by quests" )
	questCheck:SetScript( "OnClick", ToggleQuestCheckbox )

	QUEST_CHECK[ 0x00002 ] = CreateCheckbox( "ItemTooltipIconsConfigCheck1b", 45, -200, " Alliance", nil )
	QUEST_CHECK[ 0x00004 ] = CreateCheckbox( "ItemTooltipIconsConfigCheck1c", 45, -220, " Horde", nil )


	classQuestLabel = frame:CreateFontString( "ClassQuestLabel", "OVERLAY", "GameTooltipText" )
	classQuestLabel:SetFont( "Fonts\\FRIZQT__.TTF", 14, "THINOUTLINE" )
	classQuestLabel:SetPoint( "TOPLEFT", 45, -255 )
	classQuestLabel:SetTextColor( 1, 0.85, 0.15 )
	classQuestLabel:SetText( "Class Quests" )

	QUEST_CHECK[ 0x00008 ] = CreateCheckbox( "ItemTooltipIconsConfigCheck1d1", 45, -270, " Druid", nil )
	QUEST_CHECK[ 0x00010 ] = CreateCheckbox( "ItemTooltipIconsConfigCheck1d2", 45, -290, " Hunter", nil )
	QUEST_CHECK[ 0x00020 ] = CreateCheckbox( "ItemTooltipIconsConfigCheck1d3", 45, -310, " Mage", nil )
	QUEST_CHECK[ 0x00040 ] = CreateCheckbox( "ItemTooltipIconsConfigCheck1d4", 245, -270, " Paladin", nil )
	QUEST_CHECK[ 0x00080 ] = CreateCheckbox( "ItemTooltipIconsConfigCheck1d5", 245, -290, " Priest", nil )
	QUEST_CHECK[ 0x00100 ] = CreateCheckbox( "ItemTooltipIconsConfigCheck1d6", 245, -310, " Rogue", nil )
	QUEST_CHECK[ 0x00200 ] = CreateCheckbox( "ItemTooltipIconsConfigCheck1d7", 445, -270, " Shaman", nil )
	QUEST_CHECK[ 0x00400 ] = CreateCheckbox( "ItemTooltipIconsConfigCheck1d8", 445, -290, " Warlock", nil )
	QUEST_CHECK[ 0x00800 ] = CreateCheckbox( "ItemTooltipIconsConfigCheck1d9", 445, -310, " Warrior", nil )



	profQuestLabel = frame:CreateFontString( "ProfQuestLabel", "OVERLAY", "GameTooltipText" )
	profQuestLabel:SetFont( "Fonts\\FRIZQT__.TTF", 14, "THINOUTLINE" )
	profQuestLabel:SetPoint( "TOPLEFT", 45, -345 )
	profQuestLabel:SetTextColor( 1, 0.85, 0.15 )
	profQuestLabel:SetText( "Profession Quests" )

	QUEST_CHECK[ 0x01000 ] = CreateCheckbox( "ItemTooltipIconsConfigCheck1e1", 45, -360, " Cooking", nil )
	QUEST_CHECK[ 0x02000 ] = CreateCheckbox( "ItemTooltipIconsConfigCheck1e2", 45, -380, " First Aid", nil )
	QUEST_CHECK[ 0x04000 ] = CreateCheckbox( "ItemTooltipIconsConfigCheck1e3", 45, -400, " Alchemy", nil )
	QUEST_CHECK[ 0x08000 ] = CreateCheckbox( "ItemTooltipIconsConfigCheck1e4", 45, -420, " Blacksmithing", nil )
	QUEST_CHECK[ 0x10000 ] = CreateCheckbox( "ItemTooltipIconsConfigCheck1e5", 245, -360, " Enchanting", nil )
	QUEST_CHECK[ 0x20000 ] = CreateCheckbox( "ItemTooltipIconsConfigCheck1e6", 245, -380, " Engineering", nil )
	QUEST_CHECK[ 0x40000 ] = CreateCheckbox( "ItemTooltipIconsConfigCheck1e7", 245, -400, " Leatherworking", nil )
	QUEST_CHECK[ 0x80000 ] = CreateCheckbox( "ItemTooltipIconsConfigCheck1e8", 245, -420, " Tailoring", nil )
end

local function CreateIconResizeWidgets()

	iconSizeSlider = CreateFrame( "Slider", "ItemTooltipIconsConfigSlider0", frame, "OptionsSliderTemplate" )
	iconSizeSlider:SetPoint( "TOPLEFT", 20, -540 )
	iconSizeSlider:SetMinMaxValues( 8, 32 )
	iconSizeSlider:SetValueStep( 1 )
	iconSizeSlider:SetStepsPerPage( 1 )
	iconSizeSlider:SetWidth( 200 )
	iconSizeSlider:SetObeyStepOnDrag( true )
	iconSizeSlider:SetScript( "OnValueChanged", IconSizeChanged )
	_G[ "ItemTooltipIconsConfigSlider0Text" ]:SetText( "Icon Size" )
	_G[ "ItemTooltipIconsConfigSlider0Low" ]:SetText( nil )
	_G[ "ItemTooltipIconsConfigSlider0High" ]:SetText( nil )

	iconSizeLabel = frame:CreateFontString( nil, "OVERLAY", "GameTooltipText" )
	iconSizeLabel:SetFont( "Fonts\\FRIZQT__.TTF", 12, "THINOUTLINE" )
	iconSizeLabel:SetPoint( "TOPLEFT", 225, -542 )

	iconDemoTexture = frame:CreateTexture( nil, "OVERLAY" )
	iconDemoTexture:SetPoint( "TOPLEFT", 300, -540 )
	iconDemoTexture:SetTexture( GetSpellTexture( 4036 ) )
end


local dialogHeader = frame:CreateFontString( nil, "OVERLAY", "GameTooltipText" )
dialogHeader:SetFont( "Fonts\\FRIZQT__.TTF", 10, "THINOUTLINE" )
dialogHeader:SetPoint( "TOPLEFT", 20, -20 )
dialogHeader:SetText( "These options allow you control which icons are displayed on the item tooltips.\nThe quest icon can be filtered to display on items needed for quests of specific class/profession." )


CreateProfessionWidgets()
CreateQuestWidgets()
vendorCheck = CreateCheckbox( "ItemTooltipIconsConfigCheck2", 20, -470, " Vendor Items", "Display icons on items sold by vendors" )
dmfCheck = CreateCheckbox( "ItemTooltipIconsConfigCheck3", 20, -490, " Darkmoon Faire Ticket Items", "Display a ticket icon if the item can be exchanged for Darkmoon Faire tickets" )
CreateIconResizeWidgets()



frame:SetScript( "OnEvent", InitVariables )
frame:RegisterEvent( "ADDON_LOADED" )

if Settings and ( Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory ) then
	-- Classic client is now using the modern Settings API
	frame.OnCommit = SaveAndQuit
	frame.OnRefresh = RefreshWidgets
	local category = _G.Settings.RegisterCanvasLayoutCategory( frame, frame.name )
	category.ID = frame.name
	_G.Settings.RegisterAddOnCategory( category )
else
	frame.okay = SaveAndQuit
	frame:SetScript( "OnShow", RefreshWidgets )
	InterfaceOptions_AddCategory( frame )
end
