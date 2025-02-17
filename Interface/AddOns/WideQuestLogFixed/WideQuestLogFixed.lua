-- Configure this as a double-wide frame to stop the UIParent trampling on it
UIPanelWindows["QuestLogFrame"] = { area = "override", pushable = 0, xoffset = -16, yoffset = 12, bottomClampOverride = 140+12, width = 724, height = 513, whileDead = 1 };

function GetElvUI()
    local elvEnabled = IsAddOnLoaded("ElvUI")
    local elvSkinningEnabled = false
    local elv

    if elvEnabled then
        elv = ElvUI[1];
        elvSkinningEnabled = elv.private.skins.blizzard.enable == true and elv.private.skins.blizzard.quest == true
    end

    return elvEnabled, elvSkinningEnabled, elv
end

local function ElvSkinFrames()
	local _, elvSkinningEnabled, E = GetElvUI()

    if elvSkinningEnabled == false then return end

	local S = E:GetModule('Skins')

	local function LoadSkin()
		for i = 1, QUESTS_DISPLAYED do
			local questLogTitle = _G['QuestLogTitle'..i]
			questLogTitle:Width(302)
		end

		QuestLogFrame:HookScript('OnShow', function()
			QuestLogNoQuestsText:ClearAllPoints();
			QuestLogNoQuestsText:SetPoint("CENTER", QuestLogFrame);
		end)
	end

	S:AddCallback('Quest', LoadSkin)
end

local function SkinFrames()
    -- Widen the window, note that this size includes some pad on the right hand
    -- side after the scrollbars
    QuestLogFrame:SetWidth(772);
    QuestLogFrame:SetHeight(513);

    -- Adjust quest log title text
    QuestLogTitleText:ClearAllPoints();
    QuestLogTitleText:SetPoint("TOP", QuestLogFrame, "TOP", 0, -18);

    -- Relocate the detail frame over to the right, and stretch it to full
    -- height.
    QuestLogDetailScrollFrame:ClearAllPoints();
    QuestLogDetailScrollFrame:SetPoint("TOPLEFT", QuestLogListScrollFrame, "TOPRIGHT", 41, 0);
    QuestLogDetailScrollFrame:SetHeight(362);

    -- Relocate the close button
    QuestLogFrameCloseButton:ClearAllPoints();
    QuestLogFrameCloseButton:SetPoint("TOPRIGHT", QuestLogFrame, "TOPRIGHT", -78, -8);

    -- Relocate the Exit button and its text
    QuestFrameExitButton:ClearAllPoints();
    QuestFrameExitButton:SetPoint("BOTTOMRIGHT", QuestLogFrame, "BOTTOMRIGHT", -90, 53);
    QuestFrameExitButtonText:ClearAllPoints();
    QuestFrameExitButtonText:SetPoint("CENTER", QuestFrameExitButton, "CENTER", 0, 0);

    -- Relocate the quest count
    QuestLogQuestCount:ClearAllPoints();
    QuestLogQuestCount:SetPoint("TOPLEFT", QuestLogDetailScrollFrame, "TOPRIGHT", -55, 28);
    QuestLogCountRight:ClearAllPoints()
    QuestLogCountRight:SetPoint("TOPRIGHT", QuestLogFrame, -88, -42)

    -- Relocate the 'no active quests' text
    QuestLogNoQuestsText:ClearAllPoints();
    QuestLogNoQuestsText:SetPoint("TOP", QuestLogListScrollFrame, 0, -90);

    -- Expand the quest list to full height
    QuestLogListScrollFrame:SetHeight(362);

    -- Create the additional rows
    local oldQuestsDisplayed = QUESTS_DISPLAYED;
    QUESTS_DISPLAYED = QUESTS_DISPLAYED + 17;

    local _, elvSkinningEnabled = GetElvUI()

    -- Show 3 more quests when ElvUI is present
    if (elvSkinningEnabled) then
        QUESTS_DISPLAYED = QUESTS_DISPLAYED + 1;
    end

    for i = oldQuestsDisplayed + 1, QUESTS_DISPLAYED do
        local button = CreateFrame("Button", "QuestLogTitle" .. i, QuestLogFrame, "QuestLogTitleButtonTemplate");
        button:SetID(i);
        button:Hide();
        button:ClearAllPoints();
        button:SetPoint("TOPLEFT", _G["QuestLogTitle" .. (i - 1)], "BOTTOMLEFT", 0, 1);
    end

    -- Now do some trickery to replace the backing textures
    local regions = { QuestLogFrame:GetRegions() }

    -- Slightly freakish offsets to align the images with the frame
    local xOffsets = { LEFT = 3; MIDDLE = 259; RIGHT = 515; }
    local yOffsets =  { TOP = 0; BOT = -256; }

    local textures = {
        TOPLEFT = "Interface\\AddOns\\WideQuestLogFixed\\Icons\\DW_TopLeft";
        TOPRIGHT = "Interface\\AddOns\\WideQuestLogFixed\\Icons\\DW_TopRight";
        BOTLEFT = "Interface\\AddOns\\WideQuestLogFixed\\Icons\\DW_BotLeft";
        BOTRIGHT = "Interface\\AddOns\\WideQuestLogFixed\\Icons\\DW_BotRight";
        -- these will be replaced
        TOPMIDDLE = "Interface\\AddOns\\WideQuestLogFixed\\Icons\\DW_TopMid";
        BOTMIDDLE = "Interface\\AddOns\\WideQuestLogFixed\\Icons\\DW_BotMid";
    }

    local nativeTextures = {
        [136804] = {
            texturePath = "Interface\\QuestFrame\\UI-QUESTLOG-TOPLEFT";
            xofs = "LEFT";
            yofs = "TOP";
            which = "TOPLEFT";
        };
        [136805] = {
            texturePath = "Interface\\QuestFrame\\UI-QUESTLOG-TOPRIGHT";
            xofs = "RIGHT";
            yofs = "TOP";
            which = "TOPRIGHT";
        };
        [136798] = {
            texturePath = "Interface\\QuestFrame\\UI-QUESTLOG-BOTLEFT";
            xofs = "LEFT";
            yofs = "BOT";
            which = "BOTLEFT";
        };
        [136799] = {
            texturePath = "Interface\\QuestFrame\\UI-QUESTLOG-BOTRIGHT";
            xofs = "RIGHT";
            yofs = "BOT";
            which = "BOTRIGHT";
        };
        TOPMIDDLE = {
            xofs = "MIDDLE";
            yofs = "TOP";
        };
        BOTMIDDLE = {
            xofs = "MIDDLE";
            yofs = "BOT";
        };
    }

    local PATTERN = "^Interface\\QuestFrame\\UI-QUESTLOG-(([A-Z]{3})([A-Z]+))$";
    for _, region in ipairs(regions) do
        if (region:IsObjectType("Texture")) then
            local texturefile = region:GetTexture();
            local which, yofs, xofs;

            if (type(texturefile) == 'string') then
                which, yofs, xofs = texturefile:match(PATTERN);
            else
                -- failover to texture IDs
                if (nativeTextures[texturefile]) then
                    texturefile = nativeTextures[texturefile];
                    which = texturefile.which;
                    yofs = texturefile.yofs;
                    xofs = texturefile.xofs;
                end
            end

            if (which) then
                xofs = xofs and xOffsets[xofs];
                yofs = yofs and yOffsets[yofs];
                if (xofs and yofs and textures[which]) then
                    region:SetPoint("TOPLEFT", QuestLogFrame, "TOPLEFT", xofs, yofs);
                    region:SetTexture(textures[which]);
                    region:SetWidth(256);
                    region:SetHeight(256);
                    textures[which] = nil;
                end
            end
        end
    end

    -- Add in the new ones
    for name, path in pairs(textures) do
        if (path and nativeTextures[name]) then
            local xofs = nativeTextures[name].xofs;
            local yofs = nativeTextures[name].yofs;
            if (xOffsets[xofs] and yOffsets[yofs]) then
                local region = QuestLogFrame:CreateTexture(nil, "ARTWORK");
                region:ClearAllPoints();
                region:SetPoint("TOPLEFT", QuestLogFrame, "TOPLEFT", xOffsets[xofs], yOffsets[yofs]);
                region:SetWidth(256);
                region:SetHeight(256);
                region:SetTexture(path);
            end
        end
    end

    -- And do some tricks with the empty quest log textures...
    local topOfs = 0.37;
    local topH = 256 * (1 - topOfs);

    local botCap = 0.83;
    local botH = 128 *  botCap;

    local xSize = 256 + 64;
    local ySize = topH + botH;

    local nxSize = QuestLogDetailScrollFrame:GetWidth() + 26;
    local nySize = QuestLogDetailScrollFrame:GetHeight() + 8;

    local function relocateEmpty(t, w, h, x, y)
        local nx = x / xSize * nxSize - 10;
        local ny = y / ySize * nySize + 8;
        local nw = w / xSize * nxSize;
        local nh = h / ySize * nySize;

        t:SetWidth(nw);
        t:SetHeight(nh);
        t:ClearAllPoints();
        t:SetPoint("TOPLEFT", QuestLogDetailScrollFrame, "TOPLEFT", nx, ny);
    end

    local txset = { EmptyQuestLogFrame:GetRegions(); }
    for _, t in ipairs(txset) do
        if (t:IsObjectType("Texture")) then
            local p = t:GetTexture();
            if (type(p) == "string") then
                p = p:match("-([^-]+)$");
                if (p) then
                    if (p == "TopLeft") then
                        t:SetTexCoord(0, 1, topOfs, 1);
                        relocateEmpty(t, 256, topH, 0, 0);
                    elseif (p == "TopRight") then
                        t:SetTexCoord(0, 1, topOfs, 1);
                        relocateEmpty(t, 64, topH, 256, 0);
                    elseif (p == "BotLeft") then
                        t:SetTexCoord(0, 1, 0, botCap);
                        relocateEmpty(t, 256, botH, 0, -topH);
                    elseif (p == "BotRight") then
                        t:SetTexCoord(0, 1, 0, botCap);
                        relocateEmpty(t, 64, botH, 256, -topH);
                    else
                        t:Hide();
                    end
                end
            end
        end
    end
end

SkinFrames()
ElvSkinFrames()