-- Constant
local updateInterval = (1 / 30); -- used to only update the UI every 1/30 ticks. Preventing useless CPU cycles.

-- Updated every OnUpdate
local lastUpdate = 0;

-- Updated every updateInterval, to automatically change display text after a user has changed the value
local showPreciseValues = false;

-- Conditionally updated when it actually has changed
local lastPlayerPosition;

function MinimapCoordinates_OnUpdate(self, elapsed)
	if (lastUpdate >= updateInterval) then
		MinimapCoordinates_UpdatePlayerPosition();

		lastUpdate = 0;
		showPreciseValues = EZCoordinates_SavedVars.ShowPreciseValues;
	else
		lastUpdate = lastUpdate + elapsed;
	end
end

function MinimapCoordinates_UpdatePlayerPosition()
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
		
		LocationManagerDisplay:SetText(positionText);
	end
end