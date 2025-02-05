local _, MoveAny = ...
local btnsize = 36
local MADEBUFFLIMIT = 10
local MADEBUFFSPACINGX = 4
local MADEBUFFSPACINGY = 10
local debuffs = {}
local once = true
local MADebuffBar = nil
function MoveAny:GetDebuffBar()
	return MADebuffBar
end

function MoveAny:GetDebuffPosition(p1, p3)
	MoveAny:GetEleOptions("MADebuffBar", "GetBuffPosition")["MADEBUFFMODE"] = MoveAny:GetEleOptions("MADebuffBar", "GetBuffPosition")["MADEBUFFMODE"] or 0
	if MoveAny:GetEleOptions("MADebuffBar", "GetBuffPosition")["MADEBUFFMODE"] == 0 then
		if p1 == "TOPLEFT" or p1 == "LEFT" then
			return "TOPLEFT", "TOPLEFT"
		elseif p1 == "TOPRIGHT" or p1 == "RIGHT" or p1 == "TOP" or p1 == "CENTER" then
			return "TOPRIGHT", "TOPRIGHT"
		elseif p1 == "BOTTOMLEFT" then
			return "BOTTOMLEFT", "BOTTOMLEFT"
		elseif p1 == "BOTTOMRIGHT" or p1 == "BOTTOM" then
			return "BOTTOMRIGHT", "BOTTOMRIGHT"
		end
	elseif MoveAny:GetEleOptions("MADebuffBar", "GetBuffPosition")["MADEBUFFMODE"] == 1 then
		return "TOPRIGHT", "TOPRIGHT"
	elseif MoveAny:GetEleOptions("MADebuffBar", "GetBuffPosition")["MADEBUFFMODE"] == 2 then
		return "TOPLEFT", "TOPLEFT"
	elseif MoveAny:GetEleOptions("MADebuffBar", "GetBuffPosition")["MADEBUFFMODE"] == 3 then
		return "BOTTOMRIGHT", "BOTTOMRIGHT"
	elseif MoveAny:GetEleOptions("MADebuffBar", "GetBuffPosition")["MADEBUFFMODE"] == 4 then
		return "BOTTOMLEFT", "BOTTOMLEFT"
	end

	return "TOPRIGHT", "TOPRIGHT"
end

function MoveAny:InitDebuffBar()
	if MoveAny:IsEnabled("DEBUFFS", false) then
		MADebuffBar = CreateFrame("Frame", "MADebuffBar", MoveAny:GetMainPanel())
		MADebuffBar:SetPoint("TOPRIGHT", MoveAny:GetMainPanel(), "TOPRIGHT", -165, -132)
		if MoveAny:GetWoWBuild() ~= "RETAIL" then
			MADebuffBar:SetSize(btnsize * 10, btnsize * 3)
		else
			local sw1, sh1 = BuffFrame:GetSize()
			MADebuffBar:SetSize(sw1, sh1)
		end

		if MoveAny:DEBUG() then
			DebuffButton1.t = DebuffButton1:CreateTexture()
			DebuffButton1.t:SetAllPoints(DebuffButton1)
			DebuffButton1.t:SetColorTexture(0, 1, 1, 1)
			MADebuffBar.t = MADebuffBar:CreateTexture()
			MADebuffBar.t:SetAllPoints(MADebuffBar)
			MADebuffBar.t:SetColorTexture(1, 0, 0, 0.2)
		end

		local rel = "RIGHT"
		local dirH = "LEFT"
		local dirV = "BOTTOM"
		function MoveAny:UpdateDebuffDirections()
			local p1, _, p3, _, _ = MADebuffBar:GetPoint()
			local bp1, bp3 = MoveAny:GetDebuffPosition(p1, p3)
			rel = "RIGHT"
			if bp1 == "TOPLEFT" then
				rel = "LEFT"
			elseif bp1 == "LEFT" then
				rel = "LEFT"
			elseif bp1 == "BOTTOMLEFT" then
				rel = "LEFT"
			end

			dirH = "LEFT"
			if rel == "LEFT" then
				dirH = "RIGHT"
			end

			dirV = "BOTTOM"
			if bp3 == "BOTTOMLEFT" then
				dirV = "TOP"
			elseif bp3 == "BOTTOM" then
				dirV = "TOP"
			elseif bp3 == "BOTTOMRIGHT" then
				dirV = "TOP"
			end
		end

		MoveAny:UpdateDebuffDirections()
		function MoveAny:UpdateDebuffs()
			MADEBUFFLIMIT = MoveAny:GetEleOption("MADebuffBar", "MADEBUFFLIMIT", 10)
			MADEBUFFSPACINGX = MoveAny:GetEleOption("MADebuffBar", "MADEBUFFSPACINGX", 4)
			MADEBUFFSPACINGY = MoveAny:GetEleOption("MADebuffBar", "MADEBUFFSPACINGY", 10)
			MoveAny:UpdateDebuffDirections()
			for bid = 1, 32 do
				local bbtn = _G["DebuffButton" .. bid]
				if bbtn then
					if bbtn.masetup == nil then
						bbtn.masetup = true
						bbtn:SetParent(MADebuffBar)
						function bbtn:GetMAEle()
							return MADebuffBar
						end

						hooksecurefunc(
							bbtn,
							"SetPoint",
							function(sel, ...)
								if sel.setpoint_bbtn then return end
								sel.setpoint_bbtn = true
								local p1, _, p3, _, _ = MADebuffBar:GetPoint()
								local bp1, bp3 = MoveAny:GetDebuffPosition(p1, p3)
								local sw2, sh2 = sel:GetSize()
								local numBuffs = 1
								local prevBuff = nil
								for i = 1, 32 do
									local btn = _G["DebuffButton" .. i]
									if i == bid then break end
									if btn and btn:GetParent() == MADebuffBar then
										numBuffs = numBuffs + 1
										prevBuff = btn
									end
								end

								local count = 0
								local id = numBuffs + count
								local caly = (id - 0.1) / MADEBUFFLIMIT
								local cy = caly - caly % 1
								if bbtn:GetParent() == MADebuffBar then
									if numBuffs == 1 then
										local posx = 0
										if rel == "RIGHT" then
											posx = -count * (sw2 + MADEBUFFSPACINGX)
										else
											posx = count * (sw2 + MADEBUFFSPACINGX)
										end

										local posy = 0
										if MADEBUFFLIMIT == 1 then
											posx = 0
											if dirV == "BOTTOM" then
												posy = 0
											else
												posy = 30 + MADEBUFFSPACINGY
											end
										end

										MoveAny:SetPoint(sel, bp1, MADebuffBar, bp3, posx, posy)
									else
										if id % MADEBUFFLIMIT == 1 or MADEBUFFLIMIT == 1 then
											if dirV == "BOTTOM" then
												MoveAny:SetPoint(sel, bp1, MADebuffBar, bp3, 0, -cy * (sh2 + MADEBUFFSPACINGY))
											else
												MoveAny:SetPoint(sel, bp1, MADebuffBar, bp3, 0, cy * (sh2 + MADEBUFFSPACINGY))
											end
										elseif prevBuff then
											if rel == "RIGHT" then
												MoveAny:SetPoint(sel, rel, prevBuff, dirH, -MADEBUFFSPACINGX, 0)
											else
												MoveAny:SetPoint(sel, rel, prevBuff, dirH, MADEBUFFSPACINGX, 0)
											end
										end
									end
								end

								sel.setpoint_bbtn = false
							end
						)
					end

					bbtn:ClearAllPoints()
					bbtn:SetPoint("CENTER", 0, 0)
				end
			end

			-- Masque
			if LibStub then
				local MSQ = LibStub("Masque", true)
				if MSQ then
					if once then
						once = false
						MSQ:Register("Buffs", function() end, {})
						MAMasqueBuffs = MSQ:Group("MA Blizzard Buffs")
					end

					for i = 1, 32 do
						local btn = _G["DebuffButton" .. i]
						if btn and not btn.MasqueButtonData then
							btn.MasqueButtonData = {
								Button = btn,
								Icon = _G["DebuffButton" .. "IconTexture"],
							}

							MAMasqueBuffs:AddButton(btn, btn.MasqueButtonData, "Item")
						end
					end
				end
			end
		end

		if MADebuffBar then
			hooksecurefunc(
				MADebuffBar,
				"SetPoint",
				function(sel, ...)
					MoveAny:UpdateDebuffs()
				end
			)
		end

		local f = CreateFrame("FRAME")
		f:RegisterEvent("UNIT_AURA")
		f:SetScript(
			"OnEvent",
			function(sel, event, ...)
				if event == "UNIT_AURA" then
					local unit = ...
					if unit and unit == "player" then
						MoveAny:UpdateDebuffs()
					end
				end
			end
		)

		C_Timer.After(1, MoveAny.UpdateDebuffs)
	end
end
