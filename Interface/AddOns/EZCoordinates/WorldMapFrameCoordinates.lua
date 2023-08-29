-- Static
local localWorldMapFrame = WorldMapFrame;

-- Constant
local updateInterval = (1 / 30); -- used to only update the UI every 1/30 ticks. Preventing useless CPU cycles.

-- Updated every OnUpdate
local lastUpdate = 0;

-- Updated every updateInterval, to automatically change display text after a user has changed the value
local showPreciseValues = false;

-- Conditionally updated when it actually has changed
local lastPlayerPosition = nil;
local lastMousePosition = nil;

-- Updated when the user moves their mouse in or out of the WorldMapFrame
local trackMouse = false;

function WorldMapFrameCoordinates_OnUpdate(self, elapsed)
	if (lastUpdate >= updateInterval) then
		WorldMapFramePlayerCoordinates_UpdatePlayerPosition();
		WorldMapFrameMouseCoordinates_UpdateMousePosition();

		lastUpdate = 0;
		showPreciseValues = EZCoordinates_SavedVars.ShowPreciseValues;
	else
		lastUpdate = lastUpdate + elapsed;
	end
end

function WorldMapFrameCoordinates_OnEnter(self)
	trackMouse = true;
end

function WorldMapFrameCoordinates_OnLeave(self)
	trackMouse = false;
	lastMousePosition = nil;

	-- Force the UI to remove the mouse tracking text immediately
	WorldMapFrameMouseCoordinates_UpdateMousePosition(true);
end

function WorldMapFramePlayerCoordinates_UpdatePlayerPosition()
	local currentPlayerPosition = LocationManager_GetPlayerLocation();
	local shouldUpdatePlayerPosition = false;

	if (currentPlayerPosition == nil and lastPlayerPosition == nil) then
		-- No need to update
	elseif (currentPlayerPosition == nil and lastPlayerPosition ~= nil) then
		shouldUpdatePlayerPosition = true;
	elseif (currentPlayerPosition ~= nil and lastPlayerPosition == nil) then
		shouldUpdatePlayerPosition = true;
	elseif (EZCoordinates_SavedVars.ShowPreciseValues ~= showPreciseValues) then
		shouldUpdatePlayerPosition = true;
	elseif (lastPlayerPosition.Map ~= currentPlayerPosition.Map or lastPlayerPosition.X ~= currentPlayerPosition.X or lastPlayerPosition.Y ~= currentPlayerPosition.Y) then
		shouldUpdatePlayerPosition = true;
	end

	if (shouldUpdatePlayerPosition) then
		lastPlayerPosition = currentPlayerPosition;
		
		local positionText = LocationManager_GetPositionText(lastPlayerPosition);
	
		if (positionText ~= nil) then
			WorldMapFramePlayerCoordinatesDisplay:SetText("Player: " .. positionText);
		else
			WorldMapFramePlayerCoordinatesDisplay:SetText(nil);
		end
	end
end

function WorldMapFrameMouseCoordinates_UpdateMousePosition(force)
	if (trackMouse) then
		local currentMousePosition  = LocationManager_GetMouseLocation(localWorldMapFrame);
		local shouldUpdateMousePosition = false;

		if (currentMousePosition == nil and lastMousePosition == nil) then
			-- No need to update
		elseif (currentMousePosition == nil and lastMousePosition ~= nil) then
			shouldUpdateMousePosition = true;
		elseif (currentMousePosition ~= nil and lastMousePosition == nil) then
			shouldUpdateMousePosition = true;
		elseif (EZCoordinates_SavedVars.ShowPreciseValues ~= showPreciseValues) then
			shouldUpdateMousePosition = true;
		elseif (lastMousePosition.X ~= currentMousePosition.X or lastMousePosition.Y ~= currentMousePosition.Y) then
			shouldUpdateMousePosition = true;
		end

		if (shouldUpdateMousePosition) then
			lastMousePosition = currentMousePosition;
			
			local positionText = LocationManager_GetPositionText(lastMousePosition);
	
			if (positionText ~= nil) then
				WorldMapFrameMouseCoordinatesDisplay:SetText("Mouse: " .. positionText);
			else
				WorldMapFrameMouseCoordinatesDisplay:SetText(nil);
			end
		end
	elseif (force) then
		local positionText = LocationManager_GetPositionText(lastMousePosition);

		WorldMapFrameMouseCoordinatesDisplay:SetText(positionText);
	end
end

localWorldMapFrame.ScrollContainer:SetScript("OnEnter", WorldMapFrameCoordinates_OnEnter);
localWorldMapFrame.ScrollContainer:SetScript("OnLeave", WorldMapFrameCoordinates_OnLeave);