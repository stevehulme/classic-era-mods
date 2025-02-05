local _G = _G
local select = _G.select
local pairs = _G.pairs
local ipairs = _G.ipairs
local string = _G.string
local type = _G.type
local error = _G.error
local table = _G.table


local function Restack_Yield( long )
	ArkInventory.ThreadYield( ArkInventory.Global.Thread.Format.Restack, nil, long and 25 )
end

local function Restack_YieldEvent( event )
	ArkInventory.ThreadYield( ArkInventory.Global.Thread.Format.Restack, nil, 1000, "VAULT_UPDATE" )
end

function ArkInventory.RestackString( )
	return ArkInventory.Const.ButtonData[ArkInventory.ENUM.BUTTONID.Restack].Name( )
end

local function RestackMessageStart( loc_id )
	
	if ArkInventory.db.option.message.restack[loc_id] then
		ArkInventory.Output( ArkInventory.RestackString( ), ": ", ArkInventory.Global.Location[loc_id].Name, " - " , ArkInventory.Localise["START"] )
	end
	
end

local function RestackMessageComplete( loc_id )
	
	if ArkInventory.db.option.message.restack[loc_id] then
		ArkInventory.Output( ArkInventory.RestackString( ), ": ", ArkInventory.Global.Location[loc_id].Name, " - " , ArkInventory.Localise["COMPLETE"] )
	end
	
	if ArkInventory.db.option.restack.refresh then
		--ArkInventory.Frame_Main_Generate( nil, ArkInventory.Const.Window.Draw.Recalculate )
	end
	
end

local function RestackMessageAbort( loc1, loc2 )
	
	local loc2 = loc2 or loc1
	
	if loc1 == loc2 then
		ArkInventory.OutputWarning( ArkInventory.RestackString( ), ": ", ArkInventory.Global.Location[loc1].Name, " - ", ArkInventory.Localise["ABORTED"] )
	else
		ArkInventory.OutputWarning( ArkInventory.RestackString( ), ": ", ArkInventory.Global.Location[loc1].Name, " - ", ArkInventory.Localise["ABORTED"], ": ", string.format( ArkInventory.Localise["RESTACK_FAIL_CLOSED"], ArkInventory.Global.Location[loc2].Name ) )
	end
	
end

local function RestackBagCheck( blizzard_id )
	
	local numSlots
	local numFreeSlots
	local bagFamily
	
	local map = ArkInventory.Util.MapGetBlizzard( blizzard_id )
	
	local loc_id_window = map.loc_id_window
	local bag_id_window = map.bag_id_window
	
	local loc_id_storage = map.loc_id_storage
	local bag_id_storage = map.bag_id_storage
	
	
	if loc_id_window == ArkInventory.Const.Location.Vault then
		
		if not ArkInventory.Global.Mode.Vault or bag_id_window ~= GetCurrentGuildBankTab( ) then
			return loc_id_storage
		end
		
		bagFamily = -2
		
		if bag_id_window <= GetNumGuildBankTabs( ) then
			numSlots = ArkInventory.Const.BLIZZARD.GLOBAL.GUILDBANK.NUM_SLOTS
		end
		
	else
		
		numSlots = ArkInventory.CrossClient.GetContainerNumSlots( blizzard_id )
		numFreeSlots, bagFamily = ArkInventory.CrossClient.GetContainerNumFreeSlots( blizzard_id )
		
	end
	
	if loc_id_storage == ArkInventory.Const.Location.ReagentBag then
		
		bagFamily = -2
		
	end
	
	if loc_id_window == ArkInventory.Const.Location.Bank and not ArkInventory.Global.Mode.Bank then
		--ArkInventory.OutputWarning( "aborting, no longer at bank" )
		return loc_id_storage
	end
	
	if loc_id_storage == ArkInventory.Const.Location.ReagentBank then
		
		bagFamily = -2
		
		-- the reagent bank always returns its number of slots even if you havent unlocked it
		-- should ever get here any more, if its not unlocked it wont get added into bag_order
		if not ArkInventory.CrossClient.IsReagentBankUnlocked( ) then
			numSlots = 0
		end
		
	end
	
	if loc_id_storage == ArkInventory.Const.Location.AccountBank then
		
		bagFamily = -2
		
		if ArkInventory.CrossClient.IsWarbankInUseByAnotherCharacter( ) then
			return loc_id_storage
		end
		
	end
	
	--numFreeSlots = numSlots - numFreeSlots -- temporary bug fix in 11.0.2
	
	return false, bagFamily or 0, numSlots or 0, numFreeSlots or 0
	
end

local restackBagOrder = { }
local no_more_profession_items = { }
local no_more_crafting_items = { }
	
function ArkInventory.RestackInit( )
	
	table.wipe( restackBagOrder )
	table.wipe( no_more_profession_items )
	table.wipe( no_more_crafting_items )
	
end

local function RestackBagOrder( loc_id_window )
	
--	/dump RestackBagOrder( ArkInventory.Const.Location.Bag )
	
	if restackBagOrder[loc_id_window] then
		-- cached for each restack run
		return restackBagOrder[loc_id_window]
	end
	
	local bag_order = { }
	
	local active_map = ArkInventory.Util.getWindowActiveMap( loc_id_window )
	
	local bags = {
		[ArkInventory.ENUM.RESTACK.ORDER.ACCOUNT] = { },
		[ArkInventory.ENUM.RESTACK.ORDER.REAGENT] = { },
		[ArkInventory.ENUM.RESTACK.ORDER.PROFESSION] = { },
		[ArkInventory.ENUM.RESTACK.ORDER.NORMAL] = { },
	}
	
	for bag_id_window, map in ipairs( ArkInventory.Util.MapGetWindow( loc_id_window ) ) do
		if not map.hidden and map.panel_id == active_map.panel_id then
			local _, bagFamily, numSlots = RestackBagCheck( map.blizzard_id )
			if numSlots > 0 then
				if bagFamily > 0 then
					table.insert( bags[ArkInventory.ENUM.RESTACK.ORDER.PROFESSION], map.blizzard_id )
				else
					if map.loc_id_storage == ArkInventory.Const.Location.AccountBank then
						table.insert( bags[ArkInventory.ENUM.RESTACK.ORDER.ACCOUNT], map.blizzard_id )
					elseif map.loc_id_storage == ArkInventory.Const.Location.ReagentBag or map.loc_id_storage == ArkInventory.Const.Location.ReagentBank then
						table.insert( bags[ArkInventory.ENUM.RESTACK.ORDER.REAGENT], map.blizzard_id )
					else
						table.insert( bags[ArkInventory.ENUM.RESTACK.ORDER.NORMAL], map.blizzard_id )
					end
				end
			end
		end
	end
	
	for k, v in ipairs( ArkInventory.db.option.restack.bagorder ) do
		--ArkInventory.OutputDebug( v, " = ", bags[v] )
		bag_order = ArkInventory.Table.Append( { bag_order, bags[v] }, true )
	end
	
	
	--ArkInventory.Output( "bag_order [", #bag_order, "] = ", bag_order )
	
	restackBagOrder[loc_id_window] = bag_order
	return restackBagOrder[loc_id_window]
	
end

local function IngoreItem( id )
	local search_id = string.format( "item:%s", id )
	return not ArkInventory.db.option.restack.include.item[search_id]
end

local function FindItem( src_loc_id_window, dst_loc_id_window, dst_bag_id_window, dst_bag_pos, dst_slot_id, id, partial_only )
	
	ArkInventory.Util.Assert( src_loc_id_window, "FindItem - src_loc_id_window is nil" )
	ArkInventory.Util.Assert( dst_loc_id_window, "FindItem - dst_loc_id_window is nil" )
	ArkInventory.Util.Assert( dst_bag_id_window, "FindItem - dst_bag_id_window is nil" )
	ArkInventory.Util.Assert( dst_bag_pos, "FindItem - dst_bag_pos is nil" )
	ArkInventory.Util.Assert( dst_slot_id, "FindItem - dst_slot_id is nil" )
	ArkInventory.Util.Assert( id, "FindItem - id is nil" )
	
	-- find a stack of a specific item
	
	--ArkInventory.Output( "item> find [", src_loc_id_window, "] [", dst_loc_id_window, "] [", dst_bag_id_window, "] [", dst_bag_pos, "] [", dst_slot_id, "] [", id, "]" )
	
	if IngoreItem( id ) then return end
	
	local map = ArkInventory.Util.MapGetWindow( dst_loc_id_window, dst_bag_id_window )
	local dst_loc_id_storage = map.loc_id_storage
	
	if not ArkInventory.db.option.restack.stack[dst_loc_id_storage].enable then
		return
	end
	
	local recheck = false
	
	
	local codex = ArkInventory.Codex.GetPlayer( )
	
	local bag_order = RestackBagOrder( src_loc_id_window )
	for bag_pos, blizzard_id in ArkInventory.reverse_ipairs( bag_order ) do
		
		Restack_Yield( )
		
		local map = ArkInventory.Util.MapGetBlizzard( blizzard_id )
		local src_bag_id_window = map.bag_id_window
		
		if ( src_loc_id_window == ArkInventory.Const.Location.Vault ) or ( not codex.player.data.option[src_loc_id_window].bag[src_bag_id_window].restack.ignore ) then
			
			local ab, bt, slot_count = RestackBagCheck( blizzard_id )
			if ab then
				return ab
			end
			
			for slot_id = slot_count, 1, -1 do
				
				Restack_Yield( )
				
				local ab = RestackBagCheck( blizzard_id )
				if ab then
					return ab
				end
				
				if ( src_loc_id_window ~= dst_loc_id_window ) or ( src_loc_id_window == dst_loc_id_window and bag_pos > dst_bag_pos ) or ( src_loc_id_window == dst_loc_id_window and bag_pos == dst_bag_pos and slot_id > dst_slot_id ) then
					-- (different location) or (same location and higher bag) or (same location and same bag and higher slot)
					
					local itemInfo
					if src_loc_id_window == ArkInventory.Const.Location.Vault then
						itemInfo = ArkInventory.CrossClient.GetGuildBankItemInfo( src_bag_id_window, slot_id )
						ArkInventory.CrossClient.GetGuildBankItemInfo( 1, 91 )
					else
						itemInfo = ArkInventory.CrossClient.GetContainerItemInfo( blizzard_id, slot_id )
					end
					
					if itemInfo.hyperlink then
						
						if itemInfo.isLocked then
							
							--ArkInventory.Output( "item> locked [", blizzard_id, ".", slot_id, "] ", itemInfo.hyperlink )
							recheck = true
							
						else
							
							local info = ArkInventory.GetObjectInfo( itemInfo.hyperlink )
							if info.id == id then
								if ( not partial_only ) or ( partial_only and itemInfo.stackCount < info.stacksize ) then
									--ArkInventory.Output( "item> found [", src_loc_id_window, ".", src_bag_id_window, ".", slot_id, "] for [", dst_loc_id_window, ".", dst_bag_id_window, ".", dst_slot_id, "] ", itemInfo.hyperlink )
									return false, recheck, true, src_loc_id_window, src_bag_id_window, blizzard_id, slot_id
								end
							end
							
						end
						
					end
					
				else
					
					break
					
				end
				
			end
			
		end
		
	end
	
	
	if recheck then
		
		--ArkInventory.Output( "item> recheck" )
		--Restack_Yield( recheck )
		--return FindItem( src_loc_id_window, dst_loc_id_window, dst_bag_id_window, dst_bag_pos, dst_slot_id, id, partial_only )
		
	else
		
		if src_loc_id_window ~= ArkInventory.Const.Location.Bag and ArkInventory.db.option.restack.stack[dst_loc_id_storage].checkbag then
			--ArkInventory.Output( "item> checkbag enabled" )
			return FindItem( ArkInventory.Const.Location.Bag, dst_loc_id_window, dst_bag_id_window, dst_bag_pos, dst_slot_id, id )
		end
		
	end
	
	--ArkInventory.Output( "item> exit" )
	return false, recheck
	
end

local function FindCraftingItem( src_loc_id_window, dst_loc_id_window, dst_bag_id_window, dst_bag_pos, dst_slot_id, dst_bag_type )
	
	ArkInventory.Util.Assert( src_loc_id_window, "FindCraftingItem - src_loc_id_window is nil" )
	ArkInventory.Util.Assert( dst_loc_id_window, "FindCraftingItem - dst_loc_id_window is nil" )
	ArkInventory.Util.Assert( dst_bag_id_window, "FindCraftingItem - dst_bag_id_window is nil" )
	ArkInventory.Util.Assert( dst_bag_pos, "FindCraftingItem - dst_bag_pos is nil" )
	ArkInventory.Util.Assert( dst_slot_id, "FindCraftingItem - dst_slot_id is nil" )
	
	local recheck = false
	
	local map = ArkInventory.Util.MapGetWindow( dst_loc_id_window, dst_bag_id_window )
	local dst_loc_id_storage = map.loc_id_storage
	
	if not ArkInventory.db.option.restack.consolidate[dst_loc_id_storage].enable then
		return
	end
	
	Restack_Yield( )
	
	local mode = "craft"
	if dst_bag_type then
		mode = "prof"
	end
	
	--ArkInventory.Output( mode, "> find [", src_loc_id_window, "] [", dst_loc_id_window, "] [", dst_bag_id_window, "] [", dst_bag_pos, "] [", dst_slot_id, "] [", dst_bag_type, "]" )
	
	local codex = ArkInventory.Codex.GetPlayer( )
	
	if dst_bag_type == 0 then
		ArkInventory.OutputError( "code failure: checking for profession item of type [", dst_bag_type, "]" )
		return dst_loc_id_window
	end
	
	if not no_more_profession_items[src_loc_id_window] then
		no_more_profession_items[src_loc_id_window] = { }
	end
	
	if ( dst_bag_type and not no_more_profession_items[src_loc_id_window][dst_bag_type] ) or ( not dst_bag_type and not no_more_crafting_items[src_loc_id_window] ) then
		
		local bag_order = RestackBagOrder( src_loc_id_window )
		for bag_pos, blizzard_id in ArkInventory.reverse_ipairs( bag_order ) do
			
			Restack_Yield( )
			
			if ( dst_bag_type and no_more_profession_items[src_loc_id_window][dst_bag_type] ) or ( not dst_bag_type and no_more_crafting_items[src_loc_id_window] ) then
				--ArkInventory.Output( mode, "> exit1 [", bag_pos, "] no [", dst_bag_type, "] items in [", src_loc_id_window, "]" )
				break
			end
			
			local map = ArkInventory.Util.MapGetBlizzard( blizzard_id )
			local src_bag_id_window = map.bag_id_window
			
			if not codex.player.data.option[src_loc_id_window].bag[src_bag_id_window].restack.ignore then
				
				local ab, bt, count = RestackBagCheck( blizzard_id )
				if ab then
					return ab
				end
				
				for slot_id = count, 1, -1 do
					
					Restack_Yield( )
					
					if ( dst_bag_type and no_more_profession_items[src_loc_id_window][dst_bag_type] ) or ( not dst_bag_type and no_more_crafting_items[src_loc_id_window] ) then
						--ArkInventory.Output( mode, "> exit2 [", slot_id, "] no [", dst_bag_type, "] items in [", src_loc_id_window, "]" )
						break
					end
					
					--Restack_Yield( )
					
					local ab = RestackBagCheck( blizzard_id )
					if ab then
						return ab
					end
					
					if ( src_loc_id_window ~= dst_loc_id_window ) or ( src_loc_id_window == dst_loc_id_window and bag_pos > dst_bag_pos ) or ( src_loc_id_window == dst_loc_id_window and bag_pos == dst_bag_pos and slot_id > dst_slot_id ) then
					-- ( different location ) or (same location and lower bag) or (same location and same bag and lower slot)
						
						local itemInfo
						if src_loc_id_window == ArkInventory.Const.Location.Vault then
							itemInfo = ArkInventory.CrossClient.GetGuildBankItemInfo( src_bag_id_window, slot_id )
						else
							itemInfo = ArkInventory.CrossClient.GetContainerItemInfo( blizzard_id, slot_id )
						end
						
						if itemInfo.hyperlink then
							
							if itemInfo.isLocked then
								
								--ArkInventory.Output( mode, "> locked [", blizzard_id, ".", slot_id, "] ", itemInfo.hyperlink )
								recheck = true
								
							else
								
								local info = ArkInventory.GetObjectInfo( itemInfo.hyperlink )
								
								if IngoreItem( info.id ) then
									
									--ArkInventory.OutputDebug( mode, "> ignored [", blizzard_id, ".", slot_id, "] [", info.craft, "] [", info.itemunique, "] ", itemInfo.hyperlink )
									
								else
									
									--ArkInventory.OutputDebug( mode, "> check [", blizzard_id, ".", slot_id, "] [", info.craft, "] [", info.itemunique, "] ", itemInfo.hyperlink )
									
									if not info.itemunique then
										
										if dst_bag_type then
											
											if info.craft or info.itemtypeid == ArkInventory.ENUM.ITEM.TYPE.REAGENT.PARENT or info.itemtypeid == ArkInventory.ENUM.ITEM.TYPE.PROJECTILE.PARENT then
												
												if ArkInventory.ClientCheck( ArkInventory.ENUM.EXPANSION.WRATH ) then -- FIX ME, not sure when this shifted to multi bagtype support
													
													if bit.band( info.itemfamily, dst_bag_type ) > 0 then
														--ArkInventory.Output( mode, "> found [", blizzard_id, ".", slot_id, "] " , itemInfo.hyperlink )
														return false, recheck, true, src_loc_id_window, src_bag_id_window, blizzard_id, slot_id
													end
													
												else
													
													if info.itemfamily == dst_bag_type then
														--ArkInventory.Output( mode, "> found [", blizzard_id, ".", slot_id, "] " , itemInfo.hyperlink )
														return false, recheck, true, src_loc_id_window, src_bag_id_window, blizzard_id, slot_id
													end
													
												end
												
											end
											
										else
											
											if info.craft then
												
												--ArkInventory.Output( mode, "> found [", blizzard_id, ".", slot_id, "] " , itemInfo.hyperlink )
												return false, recheck, true, src_loc_id_window, src_bag_id_window, blizzard_id, slot_id
												
											end
											
										end
										
									end
									
								end
								
							end
							
						end
						
					else
						
						break -- reached current bag/slot
						
					end
					
				end
				
			end
			
		end
		
		if not recheck then
			if dst_bag_type then
				--ArkInventory.Output( mode, "> set no_more_profession_items[", src_loc_id_window, "][", dst_bag_type, "] = true" )
				no_more_profession_items[src_loc_id_window][dst_bag_type] = true
			else
				--ArkInventory.Output( mode, "> set no_more_crafting_items[", src_loc_id_window, "] = true" )
				no_more_crafting_items[src_loc_id_window] = true
			end
		end
		
	else
		--ArkInventory.Output( mode, "> exit0 - no items [", src_loc_id_window, "] [", dst_loc_id_window, "] [", dst_bag_id_window, "] [", dst_bag_pos, "] [", dst_slot_id, "] [", dst_bag_type, "]" )
	end
	
	
	if recheck then
		
		--ArkInventory.Output( mode, "> recheck" )
		--Restack_Yield( recheck )
		--return FindCraftingItem( src_loc_id_window, dst_loc_id_window, dst_bag_id_window, dst_bag_pos, dst_slot_id, dst_bag_type )
		
	else
		
		if src_loc_id_window ~= ArkInventory.Const.Location.Bag and ArkInventory.db.option.restack.consolidate[dst_loc_id_storage].checkbag then
			--ArkInventory.Output( mode, "> check bags enabled for [", dst_loc_id_storage, "] [", ArkInventory.Global.Location[dst_loc_id_storage].Name, "]" )
			return FindCraftingItem( ArkInventory.Const.Location.Bag, dst_loc_id_window, dst_bag_id_window, dst_bag_pos, dst_slot_id, dst_bag_type )
		end
		
	end
	
	
	--ArkInventory.Output( mode, "> end - no items [", src_loc_id_window, "] [", dst_loc_id_window, "] [", dst_bag_id_window, "] [", dst_bag_pos, "] [", dst_slot_id, "] [", dst_bag_type, "]" )
	return false, recheck
	
end

local function FindNormalItem( src_loc_id_window, dst_loc_id, dst_bag_id, dst_bag_pos, dst_slot_id )
	
	-- any item at all
	-- from a normal bag
	
	local recheck = false
	
	local dst_loc_id = dst_loc_id or src_loc_id_window -- destination loc_id
	local dst_blizzard_id = dst_blizzard_id or 9999 -- destination blizzard_id
	local dst_bag_pos = dst_bag_pos or -1 -- destination bag position
	local dst_slot_id = dst_slot_id or -1 -- destination slot_id
	
	Restack_Yield( )
	
	--ArkInventory.OutputDebug( "FindNormalItem( ", src_loc_id_window, " / ", dst_loc_id, ".", dst_bag_id, "(", dst_bag_pos, ").", dst_slot_id, " )" )
	
	
	if src_loc_id_window == ArkInventory.Const.Location.Bag or src_loc_id_window == ArkInventory.Const.Location.Bank then
		
		local codex = ArkInventory.Codex.GetPlayer( )
		
		local bag_order = RestackBagOrder( src_loc_id_window )
		for bag_pos, blizzard_id in ArkInventory.reverse_ipairs( bag_order ) do
			
			Restack_Yield( )
			
			local map = ArkInventory.Util.MapGetBlizzard( blizzard_id )
			local bag_id_window = map.bag_id_window
			local loc_id_storage = map.loc_id_storage
			
			if not codex.player.data.option[src_loc_id_window].bag[bag_id_window].restack.ignore then
				
				local ab, bt, count = RestackBagCheck( blizzard_id )
				if ab then
					return ab
				end
				
				if bt == 0 then
					
					for slot_id = count, 1, -1 do
						
						Restack_Yield( )
						
						local ab = RestackBagCheck( blizzard_id )
						if ab then
							return ab
						end
						
						if ( src_loc_id_window ~= dst_loc_id ) or ( src_loc_id_window == dst_loc_id and bag_pos > dst_bag_pos ) or ( src_loc_id_window == dst_loc_id and bag_pos == dst_bag_pos and slot_id > dst_slot_id ) then
						-- ( different location ) or (same location and higher bag) or (same location and same bag and higher slot)
							
							local itemInfo = ArkInventory.CrossClient.GetContainerItemInfo( blizzard_id, slot_id )
							if itemInfo.hyperlink then
								
								if itemInfo.isLocked then
									
									--ArkInventory.Output( "normal> locked [", blizzard_id, ".", slot_id, "] ", itemInfo.hyperlink )
									recheck = true
									
								else
									
									local info = ArkInventory.GetObjectInfo( itemInfo.hyperlink )
									
									if IngoreItem( info.id ) then
										
										--ArkInventory.OutputDebug( "found "> ignored [", blizzard_id, ".", slot_id, "] ", itemInfo.hyperlink )
										
									else
										
										--ArkInventory.OutputDebug( "found> ", src_loc_id_window, ".", blizzard_id, ".", slot_id )
										return false, recheck, true, src_loc_id_window, bag_id_window, blizzard_id, slot_id
										
									end
									
								end
								
							end
							
						else
							
							break
							
						end
						
					end
					
				end
				
			end
			
		end
		
	end
	
	
	if recheck then
		--ArkInventory.OutputDebug( "normal> recheck" )
		--Restack_Yield( recheck )
		--return FindNormalItem( src_loc_id_window, dst_loc_id, dst_bag_id, dst_bag_pos, dst_slot_id )
	end
	
	
	--ArkInventory.OutputDebug( "nothing found, all slots empty" )
	return false, recheck
	
end


local function Stack( loc_id_window )
	
	-- find a partial stack
	-- find other partial stacks to steal from to make it a full stack
	-- if this bag is a profession, reagent, or account, bag then you can steal from full stacks
	
	--ArkInventory.Output( "stack> start [", loc_id_window, "]" )
	
	local codex = ArkInventory.Codex.GetPlayer( )
	
	local recheck = false
	
	local bag_order = RestackBagOrder( loc_id_window )
	for bag_pos, blizzard_id in ipairs( bag_order ) do
		
		Restack_Yield( )
		
		local map = ArkInventory.Util.MapGetBlizzard( blizzard_id )
		
		local bag_id_window = map.bag_id_window
		
		local loc_id_storage = map.loc_id_storage
	
		if ArkInventory.db.option.restack.stack[loc_id_storage].enable then
			
			--ArkInventory.OutputDebug( "[", bag_pos, "] [", loc_id_window, "].[", bag_id_window, "] - [", blizzard_id, "]" )
			
			if not codex.player.data.option[loc_id_window].bag[bag_id_window].restack.ignore then
				
				local ab, bt, slot_count = RestackBagCheck( blizzard_id )
				if ab then
					return ab
				end
				
				--Restack_Yield( )
				
				--ArkInventory.OutputDebug( "StackBags START [", loc_id_window, "].[", bag_id_window, "] - [", blizzard_id, "] [", bt, "] [", slot_count, "]" )
				
				if slot_count > 0 then
					
					for slot_id = 1, slot_count do
						
						Restack_Yield( )
						
						local ab = RestackBagCheck( blizzard_id )
						if ab then
							return ab
						end
						
						--ArkInventory.OutputDebug( "checking ", loc_id_window, ".", blizzard_id, ".", slot_id )
						
						local itemInfo
						if loc_id_window == ArkInventory.Const.Location.Vault then
							itemInfo = ArkInventory.CrossClient.GetGuildBankItemInfo( bag_id_window, slot_id )
						else
							itemInfo = ArkInventory.CrossClient.GetContainerItemInfo( blizzard_id, slot_id )
						end
						
						if itemInfo.hyperlink then
							
							if itemInfo.isLocked then
								
								--ArkInventory.Output( "stack> locked [", blizzard_id, ".", slot_id, "] ", itemInfo.hyperlink )
								recheck = true
								
							else
								
								local info = ArkInventory.GetObjectInfo( itemInfo.hyperlink )
								
								if itemInfo.stackCount < info.stacksize then
									
									--ArkInventory.OutputDebug( "partial stack of ", itemInfo.hyperlink, " x ", itemInfo.stackCount, " found at ", blizzard_id, ".", slot_id, " bt=", bt )
									
									local ab, rc, ok, loc_id_partial, bag_id_partial, blizzard_id_partial, slot_id_partial
									if bt == 0 then
										ab, rc, ok, loc_id_partial, bag_id_partial, blizzard_id_partial, slot_id_partial = FindItem( loc_id_window, loc_id_window, bag_id_window, bag_pos, slot_id, info.id, true )
									else
										ab, rc, ok, loc_id_partial, bag_id_partial, blizzard_id_partial, slot_id_partial = FindItem( loc_id_window, loc_id_window, bag_id_window, bag_pos, slot_id, info.id )
									end
									
									if ab then
										return ab
									end
									
									if rc then
										recheck = true
									end
									
									if ok then
										
										--ArkInventory.Output( "stack> merge> [", blizzard_id_partial, ".", slot_id_partial, "] > [", blizzard_id, ".", slot_id, "]" )
										
										ClearCursor( )
										
										local itemInfo_partial
										if loc_id_partial == ArkInventory.Const.Location.Vault then
											itemInfo_partial = ArkInventory.CrossClient.GetGuildBankItemInfo( bag_id_partial, slot_id_partial )
										else
											itemInfo_partial = ArkInventory.CrossClient.GetContainerItemInfo( blizzard_id_partial, slot_id_partial )
										end
										
										--ArkInventory.Output( "stack> theres ", itemInfo_partial.stackCount, " of ", info.h, " available" )
										
										local amount = info.stacksize - itemInfo.stackCount
										--ArkInventory.Output( "stack> need ", amount, " of ", info.h, " to fill stack" )
										
										
										if amount > itemInfo_partial.stackCount then
											
											amount = itemInfo_partial.stackCount
											--ArkInventory.Output( "stack> splitting ", amount, " from stack of ", itemInfo_partial.stackCount )
											
											if loc_id_partial == ArkInventory.Const.Location.Vault then
												ArkInventory.CrossClient.SplitGuildBankItem( bag_id_partial, slot_id_partial, amount )
											else
												ArkInventory.CrossClient.SplitContainerItem( blizzard_id_partial, slot_id_partial, amount )
											end
											
										else
											
											--ArkInventory.Output( "stack> picking up all ", itemInfo_partial.stackCount )
											
											if loc_id_window == ArkInventory.Const.Location.Vault then
												ArkInventory.CrossClient.PickupGuildBankItem( bag_id_partial, slot_id_partial )
											else
												ArkInventory.CrossClient.PickupContainerItem( blizzard_id_partial, slot_id_partial )
											end
											
										end
										
										
										-- drop
										if loc_id_window == ArkInventory.Const.Location.Vault then
											ArkInventory.CrossClient.PickupGuildBankItem( bag_id_window, slot_id )
										else
											ArkInventory.CrossClient.PickupContainerItem( blizzard_id, slot_id )
										end
										
										--ArkInventory.Output( "stack> merged ", amount, " of ", info.h )
										
										ClearCursor( )
										
										recheck = true
										
										if loc_id_window == ArkInventory.Const.Location.Vault then
											Restack_YieldEvent( "VAULT_UPDATE" )
										else
											Restack_Yield( recheck )
										end
										
									end
									
								end
								
							end
							
						end
						
					end
					
				end
				
				--ArkInventory.OutputDebug( "StackBags END [", loc_id_window, "].[", bag_id_window, "] - [", blizzard_id, "] [", bt, "] [", slot_count, "]" )
				
			end
			
		end
		
	end
	
	--ArkInventory.Output( "stack> end [", recheck, "]" )
	
	return false, recheck
	
end

local function ConsolidateSkip( blizzard_id )
	
	local skip = false
	
	local map = ArkInventory.Util.MapGetBlizzard( blizzard_id )
	
	local loc_id_storage = map.loc_id_storage
	
	if not ArkInventory.db.option.restack.consolidate[loc_id_storage].enable then
		ArkInventory.OutputDebug( "not enabled for consolidate [", map.loc_id_window, ".", map.bag_id_window, "] [", blizzard_id, "]" )
		skip = true
	end
	
	if not skip then
		
		local loc_id_window = map.loc_id_window
		local ab, bt = RestackBagCheck( blizzard_id )
		
		if bt < 0 then
			
			if no_more_crafting_items[loc_id_window] and no_more_crafting_items[ArkInventory.Const.Location.Bag] then
				ArkInventory.OutputDebug( "no more crafting items [", map.loc_id_window, ".", map.bag_id_window, "] [", blizzard_id, "] [", bt, "]" )
				skip = true
			end
			
		elseif bt > 0 then
			
			if not no_more_profession_items[ArkInventory.Const.Location.Bag] then
				no_more_profession_items[ArkInventory.Const.Location.Bag] = { }
			end
			
			if not no_more_profession_items[loc_id_window] then
				no_more_profession_items[loc_id_window] = { }
			end
			
			if no_more_profession_items[loc_id_window][bt] and no_more_profession_items[ArkInventory.Const.Location.Bag][bt] then
				ArkInventory.OutputDebug( "no more profession items [", map.loc_id_window, ".", map.bag_id_window, "] [", blizzard_id, "] [", bt, "]" )
				skip = true
			end
			
		end
		
	end
	
	return skip
	
end

local function Consolidate( loc_id_window )
	
	-- fill up empty slots from bank (profession), reagent bag, reagent bank, or account bank, slots with items from other bags, and items from your bag if enabled
	
	--ArkInventory.Output( "consolidate> start [", loc_id_window, "]" )
	
	local codex = ArkInventory.Codex.GetPlayer( )
	
	local recheck = false
	
	local bag_order = RestackBagOrder( loc_id_window )
	ArkInventory.OutputDebug( "bag order = ", bag_order )
	
	for bag_pos, blizzard_id in ipairs( bag_order ) do
		
		Restack_Yield( )
		
		local map = ArkInventory.Util.MapGetBlizzard( blizzard_id )
		local bag_id_window = map.bag_id_window
		local loc_id_storage = map.loc_id_storage
		
		if not codex.player.data.option[loc_id_window].bag[bag_id_window].restack.ignore then
			
			local ab, bt, count, free = RestackBagCheck( blizzard_id )
			if ab then
				return ab
			end
			
			if ConsolidateSkip( blizzard_id ) then
				
				ArkInventory.OutputDebug( "consolidate> skip1 [", blizzard_id, "] [", loc_id_window, "] [", bag_id_window, "] [", bag_pos, "] - [", bt, "] [", count, "] [", free, "]" )
				
			else
				
				ArkInventory.OutputDebug( "consolidate> start [", blizzard_id, "] [", loc_id_window, "] [", bag_id_window, "] [", bag_pos, "] - [", bt, "] [", count, "] [", free, "]" )
				
				for slot_id = 1, count do
					
					Restack_Yield( )
					
					if ConsolidateSkip( blizzard_id ) then
						--ArkInventory.Output( "consolidate> skip2 [", blizzard_id, "] [", loc_id_window, "] [", bag_id_window, "] [", bag_pos, "] - [", bt, "] [", count, "] [", free, "]" )
						break
					end
					
					Restack_Yield( )
					
					local ab = RestackBagCheck( blizzard_id )
					if ab then
						return ab
					end
					
					--ArkInventory.OutputDebug( "chk> [", loc_id_window, ".", blizzard_id, ".", slot_id, "]" )
					
					local itemInfo
					if loc_id_window == ArkInventory.Const.Location.Vault then
						itemInfo = ArkInventory.CrossClient.GetGuildBankItemInfo( bag_id_window, slot_id )
					else
						itemInfo = ArkInventory.CrossClient.GetContainerItemInfo( blizzard_id, slot_id )
					end
					
					if itemInfo.hyperlink then
						
						if itemInfo.isLocked then
							
							--ArkInventory.Output( "consolidate> locked [", blizzard_id, ".", slot_id, "] ", itemInfo.hyperlink )
							recheck = true
							
						end
						
					else
						
						--ArkInventory.OutputDebug( "empty slot found> ", "[", bag_pos, "] [", blizzard_id, "] [", loc_id_window, ".", bag_id_window, ".", slot_id, "]" )
						
						local ab, rc, ok, loc_id_partial, bag_id_partial, blizzard_id_partial, slot_id_partial
						if bt < 0 then
							ab, rc, ok, loc_id_partial, bag_id_partial, blizzard_id_partial, slot_id_partial = FindCraftingItem( loc_id_window, loc_id_window, bag_id_window, bag_pos, slot_id )
						elseif bt > 0 then
							ab, rc, ok, loc_id_partial, bag_id_partial, blizzard_id_partial, slot_id_partial = FindCraftingItem( loc_id_window, loc_id_window, bag_id_window, bag_pos, slot_id, bt )
						end
						
						if ab then
							return ab
						end
						
						if rc then
							recheck = true
						end
						
						if ok then
							
							--ArkInventory.Output( "consolidate> move [", blizzard_id_partial, ".", slot_id_partial, "] to [", blizzard_id, ".", slot_id, "]" )
							
							ClearCursor( )
							
							if loc_id_partial == ArkInventory.Const.Location.Vault then
								ArkInventory.CrossClient.PickupGuildBankItem( bag_id_partial, slot_id_partial )
							else
								ArkInventory.CrossClient.PickupContainerItem( blizzard_id_partial, slot_id_partial )
							end
							
							if loc_id_window == ArkInventory.Const.Location.Vault then
								ArkInventory.CrossClient.PickupGuildBankItem( bag_id_window, slot_id )
							else
								ArkInventory.CrossClient.PickupContainerItem( blizzard_id, slot_id )
							end
							
							ClearCursor( )
							
							recheck = true
							
							if loc_id_window == ArkInventory.Const.Location.Vault then
								Restack_YieldEvent( "VAULT_UPDATE" )
							else
								Restack_Yield( recheck )
							end
							
						end
						
					end
					
				end
				
				--ArkInventory.OutputDebug( "END> ConsolidateBag [", blizzard_id, "] [", loc_id_window, "] [", bag_id_window, "] [", bag_pos, "]" )
				
			end
			
		end
		
		
	end
	
	--ArkInventory.Output( "consolidate> end [", recheck, "]" )
	
	return false, recheck
	
end

local function CompactBag( loc_id, blizzard_id, bag_pos )
	
	--ArkInventory.OutputDebug( "CompactBag: ", ArkInventory.Global.Location[loc_id].Name )
	
	local codex = ArkInventory.Codex.GetPlayer( )
	
	local recheck = false
	
	if not codex.player.data.option[loc_id].bag[bag_pos].restack.ignore then
		
		Restack_Yield( )
		
		--ArkInventory.OutputDebug( "CompactBag( ", loc_id, ".", blizzard_id, " )" )
		
		local ab, bt, count = RestackBagCheck( blizzard_id )
		if ab then
			return ab
		end
		
		--ArkInventory.OutputDebug( "bag> ", loc_id, ".", blizzard_id, " (", bag_pos, ") ", bt, " / ", count )
		
		local ok = true
		
		for slot_id = 1, count do
			
			Restack_Yield( )
			
			local ab = RestackBagCheck( blizzard_id )
			if ab then
				return ab
			end
			
			--ArkInventory.OutputDebug( "chk> ", loc_id, ".", blizzard_id, ".", slot_id )
			
			local itemInfo = ArkInventory.CrossClient.GetContainerItemInfo( blizzard_id, slot_id )
			if not itemInfo.hyperlink then
				
				if itemInfo.isLocked then
					
					--ArkInventory.Output( "compact> locked [", blizzard_id, ".", slot_id, "] ", itemInfo.hyperlink )
					recheck = true
					
				else
					
					--ArkInventory.OutputDebug( "empty @ ", loc_id, ".", blizzard_id, ".", slot_id )
					
					local ab, rc, ok, loc_id_partial, bag_id_partial, blizzard_id_partial, slot_id_partial = FindNormalItem( loc_id, loc_id, blizzard_id, bag_pos, slot_id, bt )
					
					if ab then
						return ab
					end
					
					if rc then
						recheck = true
					end
					
					if ok then
						
						--ArkInventory.OutputDebug( "moving> ", blizzard_id_partial, ".", slot_id_partial, " to ", blizzard_id, ".", slot_id )
						
						--ClearCursor( )
						--ArkInventory.CrossClient.PickupContainerItem( blizzard_id_partial, slot_id_partial )
						--ArkInventory.CrossClient.PickupContainerItem( blizzard_id, slot_id )
						--ClearCursor( )
						
						recheck = true
						
						Restack_Yield( recheck )
						
					end
					
				end
				
			end
			
			if not ok then
				-- no item found so no point checking the rest of the slots for this bag
				break
			end
			
		end
		
	end
	
	return false, recheck
	
end

local function Compact( loc_id_window )
	
	if true then return end
	
	--ArkInventory.OutputDebug( "Compact: ", ArkInventory.Global.Location[loc_id_window].Name )
	
	local codex = ArkInventory.Codex.GetPlayer( )
	
	local recheck = false
	
	for bag_pos, map in ipairs( ArkInventory.Util.MapGetWindow( loc_id_window ) ) do
		
		Restack_Yield( )
		
		local blizzard_id = map.blizzard_id
		
		if not codex.player.data.option[loc_id_window].bag[bag_pos].restack.ignore then
			
			local ab, bt, count = RestackBagCheck( blizzard_id )
			if ab then
				return ab
			end
			
			if count > 0 and bt == 0 then
				
				--ArkInventory.OutputDebug( "Compact ", loc_id_window, ".", blizzard_id, " ", bt )
				
				local ab, rc = CompactBag( loc_id_window, blizzard_id, bag_pos )
				
				if ab then
					return ab
				end
				
				if rc then
					recheck = true
				end
				
			end
			
		end
		
	end
	
	
	return false, recheck
	
end


local function CleanupBag( )
	ArkInventory.CrossClient.SortBags( )
end

local function CleanupBank( )
	ArkInventory.CrossClient.SortBankBags( )
end

local function CleanupReagentBank( )
	
	if ArkInventory.CrossClient.IsReagentBankUnlocked( ) then
		
		if ArkInventory.db.option.cleanup.deposit[ArkInventory.Const.Location.ReagentBank] then
			
			ArkInventory.Output( ArkInventory.RestackString( ), ": ", REAGENTBANK_DEPOSIT, " " , ArkInventory.Localise["ENABLED"] )
			
			C_Timer.After(
				ArkInventory.db.option.cleanup.delay,
				function( )
					if ArkInventory.Global.Mode.Bank then
						ArkInventory.CrossClient.DepositReagentBank( )
					else
						RestackMessageAbort( ArkInventory.Const.Location.ReagentBank )
					end
				end
			)
			
		else
			ArkInventory.Output( ArkInventory.RestackString( ), ": ", REAGENTBANK_DEPOSIT, " " , ArkInventory.Localise["DISABLED"] )
		end
		
		local codex = ArkInventory.Codex.GetPlayer( )
		
		for bag_id_storage, map in ipairs( ArkInventory.Util.MapGetStorage( ArkInventory.Const.Location.ReagentBank ) ) do
			
			local loc_id_window = map.loc_id_window
			local bag_id_window = map.bag_id_window
			
			if not codex.player.data.option[loc_id_window].bag[bag_id_window].restack.ignore then
				C_Timer.After(
					0.6,
					function( )
						if ArkInventory.Global.Mode.Bank then
							ArkInventory.CrossClient.SortReagentBankBags( )
						else
							RestackMessageAbort( ArkInventory.Const.Location.ReagentBank )
						end
					end
				)
				
				break -- only run cleanup once, no matter how many reagent bank tabs there are
				
			end
			
		end
		
	end
	
end

local function CleanupAccountBank( )
	
	if ArkInventory.db.option.cleanup.deposit[ArkInventory.Const.Location.AccountBank] then
		
		ArkInventory.Output( ArkInventory.RestackString( ), ": ", ACCOUNT_BANK_DEPOSIT_BUTTON_LABEL, " " , ArkInventory.Localise["ENABLED"] )
		
		local cv_name = "bankAutoDepositReagents"
		local cv_value = ArkInventory.CrossClient.GetCVarBool( cv_name )
		if cv_value then
			ArkInventory.Output( ArkInventory.RestackString( ), ": ", BANK_DEPOSIT_INCLUDE_REAGENTS_CHECKBOX_LABEL, " " , ArkInventory.Localise["ENABLED"] )
		else
			ArkInventory.Output( ArkInventory.RestackString( ), ": ", BANK_DEPOSIT_INCLUDE_REAGENTS_CHECKBOX_LABEL, " " , ArkInventory.Localise["DISABLED"] )
		end
		
		C_Timer.After(
			ArkInventory.db.option.cleanup.delay,
			function( )
				if ArkInventory.Global.Mode.Bank or ArkInventory.Global.Mode.AccountBank then
					ArkInventory.CrossClient.DepositAccountBank( )
				else
					RestackMessageAbort( ArkInventory.Const.Location.AccountBank )
				end
			end
		)
		
	else
		
		ArkInventory.Output( ArkInventory.RestackString( ), ": ", ACCOUNT_BANK_DEPOSIT_BUTTON_LABEL, " " , ArkInventory.Localise["DISABLED"] )
		
	end
	
	
	if ArkInventory.Global.Mode.Bank or ArkInventory.Global.Mode.AccountBank then
		ArkInventory.CrossClient.SortAccountBankBags( )
	else
		RestackMessageAbort( ArkInventory.Const.Location.AccountBank )
	end
	
end

local function RestackRun_Threaded( loc_id_window )
	
	--ArkInventory.OutputDebug( "RestackRun_Threaded / ", time( ), " / ", GetTime( ) )
	
	-- DO NOT USE CACHED DATA FOR RESTACKING, PULL THE DATA DIRECTLY FROM WOW, THE UI WILL CATCH UP
	
	local codex = ArkInventory.Codex.GetPlayer( )
	
	local recheck
	
	ArkInventory.RestackInit( )
	
	RestackMessageStart( loc_id_window )
	
	if ArkInventory.ClientCheck( ArkInventory.ENUM.EXPANSION.WRATH ) and ArkInventory.db.option.cleanup.enable then -- FIX ME
		
		if loc_id_window == ArkInventory.Const.Location.Bag then
			
			CleanupBag( )
			
		end
		
		if loc_id_window == ArkInventory.Const.Location.Bank then
			
			if ArkInventory.Global.Mode.Bank or ArkInventory.Global.Mode.AccountBank then
				
				ArkInventory.CrossClient.SetSortBagsRightToLeft( ArkInventory.db.option.cleanup.reverse )
				
				if codex.player.data.panel.bank.combine.all then
					
					if ArkInventory.Global.Mode.Bank then
						CleanupBank( )
						CleanupReagentBank( )
					end
					
					if ArkInventory.Global.Mode.Bank or ArkInventory.Global.Mode.AccountBank then
						CleanupAccountBank( )
					end
					
				else
					
					local active_map = ArkInventory.Util.getWindowActiveMap( loc_id_window )
					local loc_id_storage = active_map.loc_id_storage
					
					if loc_id_storage == ArkInventory.Const.Location.Bank or loc_id_storage == ArkInventory.Const.Location.ReagentBank then
						
						if loc_id_storage == ArkInventory.Const.Location.Bank or codex.player.data.panel.bank.combine.reagent then
							if ArkInventory.Global.Mode.Bank then
								CleanupBank( )
							end
						end
						
						if loc_id_storage == ArkInventory.Const.Location.ReagentBank or codex.player.data.panel.bank.combine.reagent then
							if ArkInventory.Global.Mode.Bank then
								CleanupReagentBank( )
							end
						end
						
					end
					
					if loc_id_storage == ArkInventory.Const.Location.AccountBank then
						if ArkInventory.Global.Mode.Bank or ArkInventory.Global.Mode.AccountBank then
							CleanupAccountBank( )
						end
					end
					
				end
				
			end
			
		end
		
	else
		
		repeat
			
			recheck = false
			
			
			--ArkInventory.OutputDebug( "stack 1 ", time( ) )
			local ab, rc = Stack( loc_id_window )
			--ArkInventory.OutputDebug( "stack 2 ", time( ) )
			
			if ab then
				RestackMessageAbort( ab )
				break
			end
			
			if rc then
				recheck = true
				Restack_Yield( recheck )
			end
			
			
			--ArkInventory.OutputDebug( "consolidate 1 ", time( ) )
			ab, rc = Consolidate( loc_id_window )
			--ArkInventory.OutputDebug( "consolidate 2 ", time( ) )
			
			if ab then
				RestackMessageAbort( ab )
				break
			end
			
			if rc then
				recheck = true
				Restack_Yield( recheck )
			end
			
		until not recheck
		
	end
	
	RestackMessageComplete( loc_id_window )
	
	
	--ArkInventory.OutputDebug( "RestackRun_Threaded / ", time( ), " / ", GetTime( ) )
	
end

local function RestackRun( loc_id_window )
	
	if UnitIsDead( "player" ) then
		ArkInventory.OutputWarning( "cannot restack while dead.  release or resurrect first." )
		return
	end
	
	if ArkInventory.Global.Mode.Combat then
		ArkInventory.OutputWarning( "cannot restack while in combat." )
		return
	end
	
	local thread_id = ArkInventory.Global.Thread.Format.Restack
	
	if ArkInventory.ThreadRunning( thread_id ) then
		-- restack already in progress
		--ArkInventory.OutputError( ArkInventory.RestackString( ), ": ", ArkInventory.Global.Location[loc_id].Name, " " , ArkInventory.Localise["RESTACK_FAIL_WAIT"] )
		ArkInventory.OutputError( ArkInventory.RestackString( ), ": ", ArkInventory.Localise["RESTACK_FAIL_WAIT"] )
		return
	end
	
	local thread_func = function( )
		RestackRun_Threaded( loc_id_window )
	end
	
	ArkInventory.ThreadStart( thread_id, thread_func )
	
end

function ArkInventory.Restack( loc_id_window )
	if ArkInventory.db.option.restack.enable then
		if ArkInventory.Global.Thread.Use then
			RestackRun( loc_id_window )
		else
			ArkInventory.OutputWarning( "cannot restack when threads are disabled" )
		end
	else
		ArkInventory.OutputWarning( ArkInventory.RestackString( ), " is currently disabled.  Right click on the icon for options." )
	end
end

function ArkInventory.EmptyBag( src_loc_id, src_bag_id )
	
	local src_blizzard_id = ArkInventory.Util.getBlizzardBagIdFromWindowId( src_loc_id, src_bag_id )
	
	if not ( src_loc_id == ArkInventory.Const.Location.Bag or src_loc_id == ArkInventory.Const.Location.Bank ) then
		return
	end
	
	local _, src_bt = ArkInventory.CrossClient.GetContainerNumFreeSlots( src_blizzard_id )
	local src_slot_id = 0
	
	--ArkInventory.OutputDebug( "empty ", src_blizzard_id, " [", src_bt, "]" )
	
	for _, map in ipairs( ArkInventory.Util.MapGetWindow( src_loc_id ) ) do
		
		local dst_blizzard_id = map.blizzard_id
		
		local _, dst_bt = ArkInventory.CrossClient.GetContainerNumFreeSlots( dst_blizzard_id )
		
		if dst_blizzard_id ~= src_blizzard_id and ( dst_bt == 0 or dst_bt == src_bt ) then
			
			for dst_slot_id = 1, ArkInventory.CrossClient.GetContainerNumSlots( dst_blizzard_id ) do
				
				if src_loc_id == ArkInventory.Const.Location.Bank and not ArkInventory.Global.Mode.Bank then
					-- no longer at bank, abort
					return
				end
				
				local itemInfo = ArkInventory.CrossClient.GetContainerItemInfo( dst_blizzard_id, dst_slot_id )
				if not itemInfo.hyperlink then
					
					repeat
						src_slot_id = src_slot_id + 1
						itemInfo = ArkInventory.CrossClient.GetContainerItemInfo( src_blizzard_id, src_slot_id )
					until itemInfo.hyperlink or src_slot_id > ArkInventory.CrossClient.GetContainerNumSlots( src_blizzard_id )
					
					if itemInfo.hyperlink then
						
						--ArkInventory.OutputDebug( "empty> ", src_blizzard_id, ".", src_slot_id, " to ", dst_blizzard_id, ".", dst_slot_id )
						
						ClearCursor( )
						ArkInventory.CrossClient.PickupContainerItem( src_blizzard_id, src_slot_id )
						ArkInventory.CrossClient.PickupContainerItem( dst_blizzard_id, dst_slot_id )
						ClearCursor( )
						
						--Restack_Yield( )
						
					end
				
				end
				
			end
			
		end
		
	end
	
end
