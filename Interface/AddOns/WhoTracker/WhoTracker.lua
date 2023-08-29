-- WhoTracker -- (c) 2009-2019 moorea@ymail.com (MooreaTv)
-- Covered by the GNU General Public License version 3 (GPLv3)
-- NO WARRANTY
-- (contact the author if you need a different license)
--
-- our name, our empty default anonymous ns (not used):
local addon, _ns = ...

-- Create table/namespace for most of this addon state
-- and functions (whoTrackerSaved containing the rest)
-- CreateFrame does create a namesake global class (table)
-- which we'll extend.
-- Note: this doesn't work if WhoTracker table already exists
-- (like if MoLib.lua is loaded first instead of second)
CreateFrame("frame", addon, UIParent)

-- Shortcut to not type WT everywhere

local WT = _G[addon]

-- to force debug from empty state, uncomment: (otherwise "/wt debug on" to turn on later
-- and /reload to get it save/start over)
-- WT.debug = 1

-- TODO: use all the new MoLib UI goodies to setup options panel, button etc...

function WT:Help(msg)
  WT:Print("WhoTracker: " .. msg .. "\n" .. "/wt pause --   stop tracking.\n" .. "/wt resume -- resume tracking\n" ..
             "/wt query ... -- who/what to track (n-playername z-zone g-guild c-class r-race lvl1-lvl2...)\n" ..
             "/wt history -- prints history")
end

function WT.Slash(arg) -- exception to our pattern, doesn't use : notation because it's a slash callback
  if #arg == 0 then
    WT:Help("commands")
    return
  end
  -- TODO: switch to/use tables
  local cmd = string.lower(string.sub(arg, 1, 1))
  local posRest = string.find(arg, " ")
  local rest = ""
  if not (posRest == nil) then
    rest = string.sub(arg, posRest + 1)
  end
  if cmd == "p" then
    -- off
    whoTrackerSaved.paused = 1
    WT:Print("WhoTracker now off")
  elseif cmd == "r" then
    -- resume
    whoTrackerSaved.paused = nil
    WT:Print("WhoTracker resuming tracking of " .. whoTrackerSaved.query)
    WT:Ticker()
  elseif cmd == "q" then
    -- query
    whoTrackerSaved.query = rest
    local msg = "WhoTracker now tracking " .. rest
    WT:Print(msg)
    table.insert(whoTrackerSaved.history, msg)
    whoTrackerSaved.paused = nil
    WT:Ticker()
  elseif cmd == "h" then
    -- history
    WT:Print("WhoTracker history:")
    for i = 1, #whoTrackerSaved.history do
      WT:Print(whoTrackerSaved.history[i])
    end
    -- for debug, needs exact match:
  elseif arg == "debug on" then
    -- debug
    whoTrackerSaved.debug = 1
    WT.debug = 1 -- the one actually used by MoLib
    if WT.whoLib then
      WT.whoLib:SetWhoLibDebug(true)
    end
    WT:Print("WhoTracker Debug ON")
  elseif arg == "debug off" then
    -- debug
    whoTrackerSaved.debug = nil
    WT.debug = nil
    if WT.whoLib then
      WT.whoLib:SetWhoLibDebug(false)
    end
    WT:Print("WhoTracker Debug OFF")
  elseif cmd == "d" then
    -- dump
    WT:Print("WhoTrackerDump = " .. WT:Dump(_G[rest]))
  else
    WT:Help("unknown command \"" .. arg .. "\", usage:")
  end
end

SlashCmdList["WhoTracker_Slash_Command"] = WT.Slash

SLASH_WhoTracker_Slash_Command1 = "/WhoTracker"
SLASH_WhoTracker_Slash_Command2 = "/wt"

function WT.OnEvent(this, event) -- already has "this" and is an event handler so no :
  WT:Debug("called for % e=% q=% numr=% numur=%", this:GetName(), event, WT.inQueryFlag, #WT.registered,
           #WT.unregistered)
  if (event == "PLAYER_LOGIN") then
    WT:Ticker() -- initial query/init
    return
  end
  if (event == "PLAYER_LOGOUT") then
    local ts = date("%a %b %d %H:%M end of tracking (logout)")
    WT:Print(ts, 0, 0, 1)
    table.insert(whoTrackerSaved.history, ts)
    return
  end
  if WT.inQueryFlag == 0 then
    return
  end
  -- restore other handlers
  for i = 1, #WT.unregistered do
    WT.unregistered[i]:RegisterEvent("WHO_LIST_UPDATE")
  end
  WT.registered = {}
  WT.unregistered = {}
  WT:UnregisterEvent("WHO_LIST_UPDATE")
  -- check results
  local numWhos, totalCount = C_FriendList.GetNumWhoResults()
  local res = {}
  for i = 1, numWhos do
    local info = C_FriendList.GetWhoInfo(i)
    local levelNum = tonumber(info.level)
    local data = {level = levelNum, zone = info.area}
    table.insert(res, data)
  end
  WT:ProcessResult(totalCount, res)
  WT.inQueryFlag = 0
end

-- Common part between libwho/no libwho:
function WT:ProcessResult(totalCount, data)
  local levels = {}
  local zones = {}
  local minl = 999
  local maxl = 0
  local zoneList = {}
  for i = 1, #data do
    local level = data[i].level
    local zone = data[i].zone
    if level < minl then
      minl = level
    end
    if level > maxl then
      maxl = level
    end
    if levels[level] == nil then
      levels[level] = 1
    else
      levels[level] = levels[level] + 1
    end
    if zones[zone] == nil then
      zones[zone] = 1
      table.insert(zoneList, zone)
    else
      zones[zone] = zones[zone] + 1
    end
  end
  local msg = ""
  local first = 1
  table.sort(zoneList)
  for level = minl, maxl do
    local count = levels[level]
    if not (count == nil) then
      if first == 1 then
        first = 0
      else
        msg = msg .. ", "
      end
      msg = msg .. count .. " x lvl " .. level
    end
  end
  table.sort(zoneList)
  for i = 1, #zoneList do
    local zone = zoneList[i]
    local count = zones[zone]
    msg = msg .. ", " .. count .. " in " .. zone
  end
  if not (msg == WT.prevStatus) then
    WT.prevStatus = msg
    local ts = date("%a %b %d %H:%M ")
    local tsMsg = ts .. totalCount .. " online. " .. msg
    WT:Print(tsMsg, 1, 0, 0)
    table.insert(whoTrackerSaved.history, tsMsg)
    PlaySound(SOUNDKIT.AUCTION_WINDOW_CLOSE)
  else
    -- print("unchanged");
  end
  -- end
  -- print("---");
end

WT.refresh = 60
WT.prevStatus = "x"
WT.inQueryFlag = 0

function WT:Init()
  WT:Debug("Init called!")
  if WT:MoLibInit() then -- already initialized
    return
  end
  -- saved vars handling
  local version = "(" .. addon .. " " .. WT.manifestVersion .. ")"
  if whoTrackerSaved == nil then
    whoTrackerSaved = {}
    WT:Print("Welcome to WhoTracker " .. version .. ":\n" .. "type \"/wt query g-MyGuild\" for instance" ..
               " to start tracking characters in guild \"MyGuild\"" .. " - \"/wt pause\" to stop tracking")
    whoTrackerSaved.query = "g-ChangeThis"
    whoTrackerSaved.paused = 1
    whoTrackerSaved.history = {}
  else
    if whoTrackerSaved.history == nil then
      WT:Warning("WhoTracker: warning - new history version/reset!")
      whoTrackerSaved.history = {}
    end
    if whoTrackerSaved.paused == 1 then
      WT:Print("WhoTracker is paused.  /wt resume or /wt query [query] to resume.")
    else
      WT:Print("WhoTracker " .. version .. " loaded.  Will track \"" .. whoTrackerSaved.query ..
                 "\" - type /wt pause to stop .")
    end
  end
  if whoTrackerSaved.debug then
    WT.debug = 1
  else
    WT.debug = nil
  end
  WT:Debug("whoTrackerSaved = " .. WT:Dump(whoTrackerSaved))
  -- end save vars
  WT:RegisterEvent("PLAYER_LOGOUT")
  WT.whoLib = nil
  if LibStub then
    WT.whoLib = LibStub:GetLibrary('LibWho-2.0', true)
  end
  if WT.whoLib then
    WT:Debug("LibWho found!")
    if WT.debug then
      WT.whoLib:SetWhoLibDebug(true)
    end
  else
    WT:Debug("LibWho not found!")
  end
end

function WT:Ticker()
  WT:Debug("WhoTracker periodic ticker called")
  WT:Init()
  if not (whoTrackerSaved.paused == 1) then
    WT:SendWho()
  end
end

function WT:SetRegistered(...)
  WT.registered = {}
  for i = 1, select("#", ...) do
    WT.registered[i] = select(i, ...)
  end
end

function WT:WhoLibCallBack(query, results, complete)
  -- WT.lastLR = results
  WT:Debug("WhoLibCallBack q=% rsize % complete %", query, #results, complete)
  -- WT:Debug("results is " .. WT:Dump(results))
  local totalCount = #results
  local res = {}
  for i = 1, totalCount do
    local info = results[i]
    local data = {level = info.Level, zone = info.Zone}
    table.insert(res, data)
  end
  WT:ProcessResult(totalCount, res)
end

-- Now using WhoLib if it's here (and hopefully it's a working one)
function WT:SendWho()
  if WT.whoLib then
    WT:Debug("Using WhoLib")
    local opts = {callback = WT.WhoLibCallBack}
    WT.whoLib:Who(whoTrackerSaved.query, opts)
    return
  end
  if (WT.inQueryFlag == 1) or (#WT.registered > 0) or (#WT.unregistered > 0) then
    -- shouldn't happen... something is wrong/slow/... if it does, restore other handlers
    WT.inQueryFlag = 0
    WT:Print("WhoTracker found unexpected state i=" .. WT.inQueryFlag .. " r=" .. #WT.registered .. " u=" ..
               #WT.unregistered, 1, .6, .6)
    for i = 1, #WT.unregistered do
      WT.registered[i]:RegisterEvent("WHO_LIST_UPDATE")
    end
    WT.registered = {}
    WT.unregistered = {}
    WT:UnregisterEvent("WHO_LIST_UPDATE")
    WT.inQueryFlag = 0
    return
  end
  WT.inQueryFlag = 1
  WT:SetRegistered(GetFramesRegisteredForEvent("WHO_LIST_UPDATE"))
  WT.unregistered = {}
  local friendsFrame = nil
  for i = 1, #WT.registered do
    friendsFrame = WT.registered[i]
    local fname = friendsFrame:GetName()
    if fname == nil then
      WT:Debug("who events registered to nil name #%", i)
    else
      WT:Debug("who events registered for % #%", fname, i)
    end
    friendsFrame:UnregisterEvent("WHO_LIST_UPDATE")
    table.insert(WT.unregistered, friendsFrame)
  end
  WT:RegisterEvent("WHO_LIST_UPDATE")
  C_FriendList.SetWhoToUi(1)
  -- set regular /who ui in case the user wants to repeat/get detailed
  -- of the search, but only if there isn't another search in there
  -- note that the results aren't displayed (the list is unchanged)
  if #WhoFrameEditBox:GetText() == 0 or WhoFrameEditBox:GetText() == WT.prevQuery then
    WhoFrameEditBox:SetText(whoTrackerSaved.query)
    WT.prevQuery = WhoFrameEditBox:GetText()
    WhoFrameEditBox:HighlightText()
    if WhoFrame:IsVisible() then
      -- TODO: friendsFrame is the last of the registered handler, not necessarily the right one...
      if friendsFrame == nil then
        WT:Print("WhoFrame visible but FriendsFrame wasn't registered", 1, .6, .6)
      else
        -- put it back
        friendsFrame:RegisterEvent("WHO_LIST_UPDATE")
        WT:Debug("put back FriendsFrame event hdlr")
      end
    end
  end
  C_FriendList.SendWho(whoTrackerSaved.query)
end

WT.registered = {}
WT.unregistered = {}
WT.ticker = C_Timer.NewTicker(WT.refresh, WT.Ticker)

WT:SetScript("OnEvent", WT.OnEvent)
WT:RegisterEvent("PLAYER_LOGIN")
