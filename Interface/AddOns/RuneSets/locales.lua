local addonName, addon = ...

local L = setmetatable({}, { __index = function(t, k)
  local v = tostring(k)
  rawset(t, k, v)
  return v
end })
addon.L = L
local LOCALE = GetLocale()

BINDING_HEADER_RUNESETS = addonName

-- replace the parts after = if you want to help with localization
if LOCALE == "ruRU" then
  L["%s: RuneSet %q Ready"] = "%s: RuneSet %q Ready"
  L["<empty RuneSet>"] = "<empty RuneSet>"
  L["<Modified-Click to Load on Cursor>"] = "<Modified-Click to Load on Cursor>"
  L["<Right-Click to %s %s>"] = "<Right-Click to %s %s>"
  L["<Right-Click to Quick Apply>"] = "<Right-Click to Quick Apply>"
  L["Add to Quickload Popup and Minimap Dropdown"] = "Add to Quickload Popup and Minimap Dropdown"
  L["Apply RuneSet 1"] = "Apply RuneSet 1"
  L["Apply RuneSet 2"] = "Apply RuneSet 2"
  L["Apply RuneSet 3"] = "Apply RuneSet 3"
  L["Apply RuneSet 4"] = "Apply RuneSet 4"
  L["Apply RuneSet 5"] = "Apply RuneSet 5"
  L["Apply RuneSet 6"] = "Apply RuneSet 6"
  L["Apply RuneSet 7"] = "Apply RuneSet 7"
  L["Apply RuneSet 8"] = "Apply RuneSet 8"
  L["Apply Set"] = "Apply Set"
  L["Auto Show"] = "Auto Show"
  L["Auto-Show Engraving Frame when equipping Unruned Items"] = "Auto-Show Engraving Frame when equipping Unruned Items"
  L["Checked: Configure Set"] = "Checked: Configure Set"
  L["Clear Selected"] = "Clear Selected"
  L["Clear this Set"] = "Clear this Set"
  L["<Modified-Click> on the left to load a Rune"] = "<Modified-Click> on the left to load a Rune"
  L["Drop with Right Button for Alternate Slot (eg. Finger2)"] = "Drop with Right Button for Alternate Slot (eg. Finger2)"
  L["Click to apply Set Runes"] = "Click to apply Set Runes"
  L["Click:"] = "Click:"
  L["Collapse the RuneSets Frame"] = "Collapse the RuneSets Frame"
  L["Configure"] = "Configure"
  L["Drop it with %s for unique or primary slot"] = "Drop it with %s for unique or primary slot"
  L["Drop it with %s for alternate slot (e.g. Finger2)"] = "Drop it with %s for alternate slot (e.g. Finger2)"
  L["Double-click the |cffffffffSet Label|r to edit Name"] = "Double-click the |cffffffffSet Label|r to edit Name"
  L["Dungeon"] = "Dungeon"
  L["Edit Mode"] = "Edit Mode"
  L["Edit Sets"] = "Edit Sets"
  L["Equipment-Set"] = "Equipment-Set"
  L["Expand the RuneSets Frame"] = "Expand the RuneSets Frame"
  L["Include in Menus"] = "Include in Menus"
  L["Link Set to Status"] = "Link Set to Status"
  L["Menus"] = "Menus"
  L["Middle-Click:"] = "Middle-Click:"
  L["Minimap Button"] = "Minimap Button"
  L["Minimap"] = "Minimap"
  L["%s item equipped without a Rune"] = "%s item equipped without a Rune"
  L["No-Rune Popup"] = "No-Rune Popup"
  L["PvP"] = "PvP"
  L["Raid"] = "Raid"
  L["Right-Click:"] = "Right-Click:"
  L["RuneSet Binds"] = "RuneSet Binds"
  L["Select Set"] = "Select Set"
  L["Show a MiniMap/Panel button"] = "Show a MiniMap/Panel button"
  L["Toggle Engraving Frame"] = "Toggle Engraving Frame"
  L["Toggle RuneSets"] = "Toggle RuneSets"
  L["Unchecked: Apply Set"] = "Unchecked: Apply Set"
  L["World-Party"] = "World-Party"
  L["World-Raid"] = "World-Raid"
  L["World-Solo"] = "World-Solo"
  L["You are removing %q Rune Set"] = "You are removing %q Rune Set"
elseif LOCALE == "frFR" then
  L["%s: RuneSet %q Ready"] = "%s: RuneSet %q Ready"
  L["<empty RuneSet>"] = "<empty RuneSet>"
  L["<Modified-Click to Load on Cursor>"] = "<Modified-Click to Load on Cursor>"
  L["<Right-Click to %s %s>"] = "<Right-Click to %s %s>"
  L["<Right-Click to Quick Apply>"] = "<Right-Click to Quick Apply>"
  L["Add to Quickload Popup and Minimap Dropdown"] = "Add to Quickload Popup and Minimap Dropdown"
  L["Apply RuneSet 1"] = "Apply RuneSet 1"
  L["Apply RuneSet 2"] = "Apply RuneSet 2"
  L["Apply RuneSet 3"] = "Apply RuneSet 3"
  L["Apply RuneSet 4"] = "Apply RuneSet 4"
  L["Apply RuneSet 5"] = "Apply RuneSet 5"
  L["Apply RuneSet 6"] = "Apply RuneSet 6"
  L["Apply RuneSet 7"] = "Apply RuneSet 7"
  L["Apply RuneSet 8"] = "Apply RuneSet 8"
  L["Apply Set"] = "Apply Set"
  L["Auto Show"] = "Auto Show"
  L["Auto-Show Engraving Frame when equipping Unruned Items"] = "Auto-Show Engraving Frame when equipping Unruned Items"
  L["Checked: Configure Set"] = "Checked: Configure Set"
  L["Clear Selected"] = "Clear Selected"
  L["Clear this Set"] = "Clear this Set"
  L["<Modified-Click> on the left to load a Rune"] = "<Modified-Click> on the left to load a Rune"
  L["Click to apply Set Runes"] = "Click to apply Set Runes"
  L["Click:"] = "Click:"
  L["Collapse the RuneSets Frame"] = "Collapse the RuneSets Frame"
  L["Configure"] = "Configure"
  L["Drop it with %s for unique or primary slot"] = "Drop it with %s for unique or primary slot"
  L["Drop it with %s for alternate slot (e.g. Finger2)"] = "Drop it with %s for alternate slot (e.g. Finger2)"
  L["Double-click the |cffffffffSet Label|r to edit Name"] = "Double-click the |cffffffffSet Label|r to edit Name"
  L["Dungeon"] = "Dungeon"
  L["Edit Mode"] = "Edit Mode"
  L["Edit Sets"] = "Edit Sets"
  L["Equipment-Set"] = "Equipment-Set"
  L["Expand the RuneSets Frame"] = "Expand the RuneSets Frame"
  L["Include in Menus"] = "Include in Menus"
  L["Link Set to Status"] = "Link Set to Status"
  L["Menus"] = "Menus"
  L["Middle-Click:"] = "Middle-Click:"
  L["Minimap Button"] = "Minimap Button"
  L["Minimap"] = "Minimap"
  L["%s item equipped without a Rune"] = "%s item equipped without a Rune"
  L["No-Rune Popup"] = "No-Rune Popup"
  L["PvP"] = "PvP"
  L["Raid"] = "Raid"
  L["Right-Click:"] = "Right-Click:"
  L["RuneSet Binds"] = "RuneSet Binds"
  L["Select Set"] = "Select Set"
  L["Show a MiniMap/Panel button"] = "Show a MiniMap/Panel button"
  L["Toggle Engraving Frame"] = "Toggle Engraving Frame"
  L["Toggle RuneSets"] = "Toggle RuneSets"
  L["Unchecked: Apply Set"] = "Unchecked: Apply Set"
  L["World-Party"] = "World-Party"
  L["World-Raid"] = "World-Raid"
  L["World-Solo"] = "World-Solo"
  L["You are removing %q Rune Set"] = "You are removing %q Rune Set"
elseif LOCALE == "deDE" then
  L["%s: RuneSet %q Ready"] = "%s: RuneSet %q Ready"
  L["<empty RuneSet>"] = "<empty RuneSet>"
  L["<Modified-Click to Load on Cursor>"] = "<Modified-Click to Load on Cursor>"
  L["<Right-Click to %s %s>"] = "<Right-Click to %s %s>"
  L["<Right-Click to Quick Apply>"] = "<Right-Click to Quick Apply>"
  L["Add to Quickload Popup and Minimap Dropdown"] = "Add to Quickload Popup and Minimap Dropdown"
  L["Apply RuneSet 1"] = "Apply RuneSet 1"
  L["Apply RuneSet 2"] = "Apply RuneSet 2"
  L["Apply RuneSet 3"] = "Apply RuneSet 3"
  L["Apply RuneSet 4"] = "Apply RuneSet 4"
  L["Apply RuneSet 5"] = "Apply RuneSet 5"
  L["Apply RuneSet 6"] = "Apply RuneSet 6"
  L["Apply RuneSet 7"] = "Apply RuneSet 7"
  L["Apply RuneSet 8"] = "Apply RuneSet 8"
  L["Apply Set"] = "Apply Set"
  L["Auto Show"] = "Auto Show"
  L["Auto-Show Engraving Frame when equipping Unruned Items"] = "Auto-Show Engraving Frame when equipping Unruned Items"
  L["Checked: Configure Set"] = "Checked: Configure Set"
  L["Clear Selected"] = "Clear Selected"
  L["Clear this Set"] = "Clear this Set"
  L["<Modified-Click> on the left to load a Rune"] = "<Modified-Click> on the left to load a Rune"
  L["Click to apply Set Runes"] = "Click to apply Set Runes"
  L["Click:"] = "Click:"
  L["Collapse the RuneSets Frame"] = "Collapse the RuneSets Frame"
  L["Configure"] = "Configure"
  L["Drop it with %s for unique or primary slot"] = "Drop it with %s for unique or primary slot"
  L["Drop it with %s for alternate slot (e.g. Finger2)"] = "Drop it with %s for alternate slot (e.g. Finger2)"
  L["Double-click the |cffffffffSet Label|r to edit Name"] = "Double-click the |cffffffffSet Label|r to edit Name"
  L["Dungeon"] = "Dungeon"
  L["Edit Mode"] = "Edit Mode"
  L["Edit Sets"] = "Edit Sets"
  L["Equipment-Set"] = "Equipment-Set"
  L["Expand the RuneSets Frame"] = "Expand the RuneSets Frame"
  L["Include in Menus"] = "Include in Menus"
  L["Link Set to Status"] = "Link Set to Status"
  L["Menus"] = "Menus"
  L["Middle-Click:"] = "Middle-Click:"
  L["Minimap Button"] = "Minimap Button"
  L["Minimap"] = "Minimap"
  L["%s item equipped without a Rune"] = "%s item equipped without a Rune"
  L["No-Rune Popup"] = "No-Rune Popup"
  L["PvP"] = "PvP"
  L["Raid"] = "Raid"
  L["Right-Click:"] = "Right-Click:"
  L["RuneSet Binds"] = "RuneSet Binds"
  L["Select Set"] = "Select Set"
  L["Show a MiniMap/Panel button"] = "Show a MiniMap/Panel button"
  L["Toggle Engraving Frame"] = "Toggle Engraving Frame"
  L["Toggle RuneSets"] = "Toggle RuneSets"
  L["Unchecked: Apply Set"] = "Unchecked: Apply Set"
  L["World-Party"] = "World-Party"
  L["World-Raid"] = "World-Raid"
  L["World-Solo"] = "World-Solo"
  L["You are removing %q Rune Set"] = "You are removing %q Rune Set"
else -- default

end

BINDING_HEADER_RUNESETSBINDS = L["RuneSet Binds"]
BINDING_NAME_RUNESETSTOGGLE = L["Toggle Engraving Frame"]
BINDING_NAME_RUNESET1 = L["Apply RuneSet 1"]
BINDING_NAME_RUNESET2 = L["Apply RuneSet 2"]
BINDING_NAME_RUNESET3 = L["Apply RuneSet 3"]
BINDING_NAME_RUNESET4 = L["Apply RuneSet 4"]
BINDING_NAME_RUNESET5 = L["Apply RuneSet 5"]
BINDING_NAME_RUNESET6 = L["Apply RuneSet 6"]
BINDING_NAME_RUNESET7 = L["Apply RuneSet 7"]
BINDING_NAME_RUNESET8 = L["Apply RuneSet 8"]
