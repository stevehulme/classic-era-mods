--[[
    Necrosis 
    Copyright (C) - copyright file included in this release
--]]

-- On définit G comme étant le tableau contenant toutes les frames existantes.
local _G = getfenv(0)


------------------------------------------------------------------------------------------------------
-- CREATION DE LA FRAME DES OPTIONS
------------------------------------------------------------------------------------------------------

function Necrosis:SetTimersConfig()

	local frame = _G["NecrosisTimersConfig"]
	if not frame then
		-- Création de la fenêtre
		frame = CreateFrame("Frame", "NecrosisTimersConfig", NecrosisGeneralFrame)
		frame:SetFrameStrata("DIALOG")
		frame:SetMovable(false)
		frame:EnableMouse(true)
		frame:SetWidth(350)
		frame:SetHeight(452)
		frame:Show()
		frame:ClearAllPoints()
		frame:SetPoint("BOTTOMLEFT")

		-- Create page 1
		frame = CreateFrame("Frame", "NecrosisTimersConfig1", NecrosisTimersConfig)
		frame:SetFrameStrata("DIALOG")
		frame:SetMovable(false)
		frame:EnableMouse(true)
		frame:SetWidth(350)
		frame:SetHeight(452)
		frame:Show()
		frame:ClearAllPoints()
		frame:SetPoint("BOTTOMLEFT")

		-- Create navigation
		local FontString = frame:CreateFontString(nil, nil, "GameFontNormalSmall")
		FontString:Show()
		FontString:ClearAllPoints()
		FontString:SetPoint("BOTTOM", frame, "BOTTOM", 90, 90)
		FontString:SetText("1 / 2")

		FontString = frame:CreateFontString("NecrosisTimersConfig1Text", nil, "GameFontNormalSmall")
		FontString:Show()
		FontString:ClearAllPoints()
		FontString:SetPoint("BOTTOM", frame, "BOTTOM", 50, 400)

		-- Boutons
		frame = CreateFrame("Button", nil, NecrosisTimersConfig1, "UIPanelButtonTemplate")
		frame:SetText(">>>")
		frame:EnableMouse(true)
		frame:Show()
		frame:ClearAllPoints()
		frame:SetPoint("RIGHT", NecrosisTimersConfig1, "BOTTOMRIGHT", 120, 100)

		frame:SetScript("OnClick", function()
			NecrosisTimersConfig2:Show()
			NecrosisTimersConfig1:Hide()
		end)

		frame = CreateFrame("Button", nil, NecrosisTimersConfig1, "UIPanelButtonTemplate")
		frame:SetText("<<<")
		frame:EnableMouse(true)
		frame:Show()
		frame:ClearAllPoints()
		frame:SetPoint("LEFT", NecrosisTimersConfig1, "BOTTOMLEFT", 40, 100)

		frame:SetScript("OnClick", function()
			NecrosisTimersConfig2:Show()
			NecrosisTimersConfig1:Hide()
		end)


		-- Choix du timer graphique
		frame = CreateFrame("Frame", "NecrosisTimerSelection", NecrosisTimersConfig1, "UIDropDownMenuTemplate")
		frame:Show()
		frame:ClearAllPoints()
		frame:SetPoint("RIGHT", NecrosisTimersConfig1, "BOTTOMRIGHT", 40, 400)

		local FontString = frame:CreateFontString("NecrosisTimerSelectionT", "OVERLAY", "GameFontNormalSmall")
		FontString:Show()
		FontString:ClearAllPoints()
		FontString:SetPoint("LEFT", NecrosisTimersConfig1, "BOTTOMLEFT", 35, 403)
		FontString:SetTextColor(1, 1, 1)

		UIDropDownMenu_SetWidth(frame, 125)

		-- Affiche ou masque le bouton des timers
		frame = CreateFrame("CheckButton", "NecrosisShowSpellTimerButton", NecrosisTimersConfig1, "UICheckButtonTemplate")
		frame:EnableMouse(true)
		frame:SetWidth(24)
		frame:SetHeight(24)
		frame:Show()
		frame:ClearAllPoints()
		frame:SetPoint("LEFT", NecrosisTimersConfig1, "BOTTOMLEFT", 40, 325)

		local f = _G[Necrosis.Warlock_Buttons.timer.f]
		frame:SetScript("OnClick", function(self)
			NecrosisConfig.ShowSpellTimers = self:GetChecked()
			if NecrosisConfig.ShowSpellTimers then
				f:Show()
			else
				f:Hide()
			end
		end)

		FontString = frame:CreateFontString(nil, nil, "GameFontNormalSmall")
		FontString:Show()
		FontString:ClearAllPoints()
		FontString:SetPoint("LEFT", frame, "RIGHT", 5, 1)
		FontString:SetTextColor(1, 1, 1)
		frame:SetFontString(FontString)
		-- frame:SetDisabledTextColor(0.75, 0.75, 0.75)

		-- Affiche les timers sur la gauche du bouton
		frame = CreateFrame("CheckButton", "NecrosisTimerOnLeft", NecrosisTimersConfig1, "UICheckButtonTemplate")
		frame:EnableMouse(true)
		frame:SetWidth(24)
		frame:SetHeight(24)
		frame:Show()
		frame:ClearAllPoints()
		frame:SetPoint("LEFT", NecrosisTimersConfig1, "BOTTOMLEFT", 40, 300)

		frame:SetScript("OnClick", function(self)
			Necrosis:SymetrieTimer(self:GetChecked())
		end)

		FontString = frame:CreateFontString(nil, nil, "GameFontNormalSmall")
		FontString:Show()
		FontString:ClearAllPoints()
		FontString:SetPoint("LEFT", frame, "RIGHT", 5, 1)
		FontString:SetTextColor(1, 1, 1)
		frame:SetFontString(FontString)
		-- frame:SetDisabledTextColor(0.75, 0.75, 0.75)

		-- Affiche les timers de bas en haut
		frame = CreateFrame("CheckButton", "NecrosisTimerUpward", NecrosisTimersConfig1, "UICheckButtonTemplate")
		frame:EnableMouse(true)
		frame:SetWidth(24)
		frame:SetHeight(24)
		frame:Show()
		frame:ClearAllPoints()
		frame:SetPoint("LEFT", NecrosisTimersConfig1, "BOTTOMLEFT", 40, 275)

		frame:SetScript("OnClick", function(self)
			if (self:GetChecked()) then
				NecrosisConfig.SensListe = -1
			else
				NecrosisConfig.SensListe = 1
			end
		end)

		FontString = frame:CreateFontString(nil, nil, "GameFontNormalSmall")
		FontString:Show()
		FontString:ClearAllPoints()
		FontString:SetPoint("LEFT", frame, "RIGHT", 5, 1)
		FontString:SetTextColor(1, 1, 1)
		frame:SetFontString(FontString)
		-- frame:SetDisabledTextColor(0.75, 0.75, 0.75)
		
		
		-- transparence de la barre de sort
		frame = CreateFrame("Slider", "NecrosisAlphaBar", NecrosisTimersConfig1, "OptionsSliderTemplate")
		frame:SetMinMaxValues(1, 100)-- Alpha slider min max
		frame:SetValueStep(1)
		frame:SetObeyStepOnDrag(true)
		frame:SetStepsPerPage(1)
		frame:SetWidth(150)
		frame:SetHeight(15)
		frame:Show()
		frame:ClearAllPoints()
		frame:SetPoint("CENTER", NecrosisTimersConfig1, "BOTTOMLEFT", 225, 355)

		frame:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(self:GetValue())
		end)
		
		frame:SetScript("OnLeave", function() GameTooltip:Hide() end)
		frame:SetScript("OnValueChanged", function(self) GameTooltip:SetText(math.floor(self:GetValue())) end)
		frame:SetScript("OnMouseUp", function(self)
			GameTooltip:SetText(self:GetValue())
			NecrosisConfig.NecrosisAlphaBar = math.floor(self:GetValue())

		end)
		
		local FontString = frame:CreateFontString("NecrosisAlphaBarT", "OVERLAY", "GameFontNormalSmall")
		FontString:Show()
		FontString:ClearAllPoints()
		FontString:SetPoint("CENTER", frame, "CENTER", 0, 12)
		FontString:SetTextColor(1, 1, 1)
		


		NecrosisAlphaBarLow:SetText("1")
		NecrosisAlphaBarHigh:SetText("100")

		-- Create page 2
		frame = {}
		frame = CreateFrame("Frame", "NecrosisTimersConfig2", NecrosisTimersConfig)
		frame:SetFrameStrata("DIALOG")
		frame:SetMovable(false)
		frame:EnableMouse(true)
		frame:SetWidth(350)
		frame:SetHeight(452)
		frame:Show()
		frame:ClearAllPoints()
		frame:SetPoint("BOTTOMLEFT")

		-- Create navigation
		FontString = frame:CreateFontString(nil, nil, "GameFontNormalSmall")
		FontString:Show()
		FontString:ClearAllPoints()
		FontString:SetPoint("BOTTOM", frame, "BOTTOM", 90, 95)
		FontString:SetText("2 / 2")

		FontString = frame:CreateFontString("NecrosisTimersConfig2Text", nil, "GameFontNormalSmall")
		FontString:Show()
		FontString:ClearAllPoints()
		FontString:SetPoint("BOTTOM", frame, "BOTTOM", 50, 400)
		FontString:SetText(SHOW)

		-- Boutons
		frame = CreateFrame("Button", nil, NecrosisTimersConfig2, "UIPanelButtonTemplate")
		frame:SetText(">>>")
		frame:EnableMouse(true)
		frame:Show()
		frame:ClearAllPoints()
		frame:SetPoint("RIGHT", NecrosisTimersConfig2, "BOTTOMRIGHT", 120, 100)

		frame:SetScript("OnClick", function()
			NecrosisTimersConfig1:Show()
			NecrosisTimersConfig2:Hide()
		end)

		frame = CreateFrame("Button", nil, NecrosisTimersConfig2, "UIPanelButtonTemplate")
		frame:SetText("<<<")
		frame:EnableMouse(true)
		frame:Show()
		frame:ClearAllPoints()
		frame:SetPoint("LEFT", NecrosisTimersConfig2, "BOTTOMLEFT", 40, 100)

		frame:SetScript("OnClick", function()
			NecrosisTimersConfig1:Show()
			NecrosisTimersConfig2:Hide()
		end)

		-- timers
		local initY = 395
		local initX = 40
		
		for i = 1, #NecrosisConfig.Timers, 1 do
			--print("usage",NecrosisConfig.Timers[i].usage)
			frame = CreateFrame("CheckButton", "NecrosisTimerShow"..i, NecrosisTimersConfig2, "UICheckButtonTemplate")
			frame:EnableMouse(true)
			frame:SetWidth(24)
			frame:SetHeight(24)
			frame:Show()
			frame:ClearAllPoints()
			
			
			if i < 8 then
				frame:SetPoint("LEFT", NecrosisTimersConfig2, "BOTTOMLEFT", initX , initY - (25 * i))			
			else
				frame:SetPoint("LEFT", NecrosisTimersConfig2, "BOTTOMLEFT", initX + 250, initY - (25 * (i-7)))				
			end
			
			


			frame:SetScript("OnClick", function(self)
				Necrosis.UpdateSpellTimer(i, self:GetChecked())
			end)

			FontString = frame:CreateFontString(nil, nil, "GameFontNormalSmall")
			FontString:Show()
			FontString:ClearAllPoints()
			FontString:SetPoint("LEFT", frame, "RIGHT", 5, 1)
			FontString:SetTextColor(1, 1, 1)
			frame:SetFontString(FontString)
			
			frame:SetChecked(NecrosisConfig.Timers[i].show)
			frame:SetText(Necrosis.GetSpellName(NecrosisConfig.Timers[i].usage))
		end
		NecrosisTimersConfig2:Hide()
	end

	UIDropDownMenu_Initialize(NecrosisTimerSelection, Necrosis.Timer_Init)
	
	NecrosisTimerSelectionT:SetText(self.Config.Timers["Type de timers"])
	NecrosisShowSpellTimerButton:SetText(self.Config.Timers["Afficher le bouton des timers"])
	NecrosisTimerOnLeft:SetText(self.Config.Timers["Afficher les timers sur la gauche du bouton"])
	NecrosisTimerUpward:SetText(self.Config.Timers["Afficher les timers de bas en haut"])
	--transparence
	NecrosisAlphaBarT:SetText(self.Config.Timers["Transparence des timers"])
	if NecrosisConfig.NecrosisAlphaBar then
		NecrosisAlphaBar:SetValue(NecrosisConfig.NecrosisAlphaBar)
	else
		NecrosisAlphaBar:SetValue(100)
	end


	UIDropDownMenu_SetSelectedID(NecrosisTimerSelection, (NecrosisConfig.TimerType + 1))
	UIDropDownMenu_SetText(NecrosisTimerSelection, Necrosis.Config.Timers.Type[NecrosisConfig.TimerType + 1])

	NecrosisShowSpellTimerButton:SetChecked(NecrosisConfig.ShowSpellTimers)
	NecrosisTimerOnLeft:SetChecked(NecrosisConfig.SpellTimerPos == -1)
	NecrosisTimerUpward:SetChecked(NecrosisConfig.SensListe == -1)

	if NecrosisConfig.TimerType == 0 then
		NecrosisTimerUpward:Disable()
		NecrosisTimerOnLeft:Disable()

	elseif NecrosisConfig.TimerType == 2 then
		NecrosisTimerUpward:Disable()
		NecrosisTimerOnLeft:Enable()
	else
		NecrosisTimerOnLeft:Enable()
		NecrosisTimerUpward:Enable()
	end

	local frame = _G["NecrosisTimersConfig"]
	frame:Show()
end


------------------------------------------------------------------------------------------------------
-- FONCTIONS NECESSAIRES AUX DROPDOWNS
------------------------------------------------------------------------------------------------------

-- Fonctions du Dropdown des timers
function Necrosis.Timer_Init()
	local element = {}

	for i in ipairs(Necrosis.Config.Timers.Type) do
		element.text = Necrosis.Config.Timers.Type[i]
		element.checked = false
		element.func = Necrosis.Timer_Click
		UIDropDownMenu_AddButton(element)
	end
end

function Necrosis.Timer_Click(self)
	local ID = self:GetID()
	UIDropDownMenu_SetSelectedID(NecrosisTimerSelection, ID)
	NecrosisConfig.TimerType = ID - 1
	if not (ID == 1) then Necrosis:CreateTimerAnchor() end
	
	
	if ID == 1 then -- Disable Timer
		NecrosisTimerUpward:Disable()
		NecrosisTimerOnLeft:Disable()
		if _G["NecrosisListSpells"] then NecrosisListSpells:SetText("") end
		local index = 1
		while _G["NecrosisTimerFrame"..index] do
			_G["NecrosisTimerFrame"..index]:Hide()
			index = index + 1
		end
	elseif ID == 3 then -- Timer Texture Text
		NecrosisTimerUpward:Disable()
		NecrosisTimerOnLeft:Enable()
		local index = 1
		while _G["NecrosisTimerFrame"..index] do
			_G["NecrosisTimerFrame"..index]:Hide()
			index = index + 1
		end
	else -- Timer graphique


		SetupBuffTimers()
		if _G["NecrosisListSpells"] then NecrosisListSpells:SetText("") end
	end
end
