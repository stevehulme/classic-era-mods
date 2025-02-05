--[===[ File
This file contains Config 'recent changes' and notes.
It should be updated for each Titan release!

These are in a seperate file to
1) Increase the chance these strings get updated
2) Decrease the chance of breaking the code :).
--]===]

--[[ Var Release Notes
Detail changes for last 4 - 5 releases.
Format :
Gold - version & date
Green - 'header' - Titan or plugin
Highlight - notes. tips. and details
--]]
Titan_Global.recent_changes = ""
.. TitanUtils_GetGoldText("8.2.0 : 2025/01/03\n")
.. TitanUtils_GetGreenText("Titan : \n")
.. TitanUtils_GetHighlightText(""
.. "- Internal fixes to prevent timing issues for built-in plugins on init - any splash screen ."
)
.. "\n\n"
.. TitanUtils_GetGoldText("8.1.7 : 2024/12/22\n")
.. TitanUtils_GetGreenText("Gold : \n")
.. TitanUtils_GetHighlightText(""
.. "- Hopefully fix an error on character start ocurring on some systems."
)
.. "\n\n"
.. TitanUtils_GetGoldText("8.1.6 : 2024/12/09\n")
.. TitanUtils_GetGreenText("Gold : \n")
.. TitanUtils_GetHighlightText(""
.. "- Warband gold updated properly in tooltip."
)
.. TitanUtils_GetGreenText("Titan : \n")
.. TitanUtils_GetHighlightText(""
.. "- Update ACE3 libs."
.. "- Bars - Config Color picker now works; changed in 10.2.5 (Jan 2024)."
.. "- Bars - Config when selecting Skin vs Color the 'other' controls are disabled."
)
.. "\n\n"
.. TitanUtils_GetGoldText("8.1.5 : 2024/11/20\n")
.. TitanUtils_GetGreenText("Loot - Classic Era : \n")
.. TitanUtils_GetHighlightText(""
.. "- Code changes per change in API."
.. "- Code changes per change in XML parsing."
)
.. TitanUtils_GetGreenText("Titan : \n")
.. TitanUtils_GetHighlightText(""
.. "- Retail TOC to 11.0.5."
.. "- Cata TOC to 4.4.1."
.. "- Classic Era TOC to 1.15.5"
)
.. "\n\n"

--[[ Var Notes
Use for important notes in the Titan Config About
--]]
Titan_Global.config_notes = ""
    .. TitanUtils_GetGoldText("Notes:\n")
    .. TitanUtils_GetHighlightText(""
        ..
        "- Changing Titan Scaling : Short bars will move on screen. They should not go off screen. If Short bars move then drag to desired location. You may have to Reset the Short bar or temporarily disable top or bottom bars to drag the Short bar.\n"
    )
    .. "\n"
    .. TitanUtils_GetGoldText("Known Issues:\n")
    .. TitanUtils_GetHighlightText(""
    .. "- Cata : Titan right-click menu may stay visible even if click elsewhere. Hit Esc twice. Investigating...\n"
)
