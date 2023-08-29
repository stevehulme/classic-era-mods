function LocationManager_GetPlayerLocation()
	local map = C_Map.GetBestMapForUnit("player");
	
	if (map == nil) then
		return nil;
	end

	local position = C_Map.GetPlayerMapPosition(map, "player");
	
	if (position == nil) then
		return nil;
	end

	return {
		Map = map,
		X = position.x,
		Y = position.y,
	};
end

function LocationManager_GetMouseLocation(localWorldMapFrame)
	if (localWorldMapFrame) then
		local x, y = GetCursorPosition();
		local left, top = localWorldMapFrame.ScrollContainer:GetLeft(), localWorldMapFrame.ScrollContainer:GetTop();
		local width = localWorldMapFrame.ScrollContainer:GetWidth();
		local height = localWorldMapFrame.ScrollContainer:GetHeight()
		local scale = localWorldMapFrame.ScrollContainer:GetEffectiveScale();
		local cx = (x/scale - left) / width
		local cy = (top - y/scale) / height

		if cx < 0 or cx > 1 or cy < 0 or cy > 1 then
			cx, cy = nil, nil
		end

		return {
			X = cx,
			Y = cy,
		};
	end
end

function LocationManager_GetPositionText(position)
	if (position == nil) then
		return nil;
	end

	local x = position.X and position.X or 0;
	local y = position.Y and position.Y or 0;
	
	local formatString = "%d, %d";

	if (EZCoordinates_SavedVars.ShowPreciseValues) then
		formatString = "%0.2f, %0.2f";
	end

	local positionText = format("(" .. formatString .. ")", x * 100, y * 100);

	return positionText;
end