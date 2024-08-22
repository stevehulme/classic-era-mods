local _, PKG = ...

local Debug = PKG.Debug

-- global API for this addon
DEMODAL_ADDON = {}
DEMODAL_ADDON.VERSION_STRING = "DeModal 0.8.1"
DEMODAL_ADDON.VERSION = "0.8.1"

-- version ID stuff
PKG.gameVersion = "mainline"
local tocv = select(4, GetBuildInfo())
if tocv < 20000 then
    PKG.gameVersion = "vanilla"
elseif tocv < 30000 then
    PKG.gameVersion = "tbc"
elseif tocv < 40000 then
    PKG.gameVersion = "wrath"
elseif tocv < 50000 then
    PKG.gameVersion = "cata"
end
Debug("TOC V", tocv, PKG.gameVersion)

-- load all the things
PKG.LoadSlashCommands()
PKG.SettingsMixin.Init()
PKG.DeModalMixin.Init()
