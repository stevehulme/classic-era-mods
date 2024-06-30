# Quartz

## [3.7.10](https://github.com/Nevcairiel/Quartz/tree/3.7.10) (2024-06-19)
[Full Changelog](https://github.com/Nevcairiel/Quartz/compare/3.7.9...3.7.10) [Previous Releases](https://github.com/Nevcairiel/Quartz/releases)

- Check if CR\_HASTE\_SPELL is available before using it  
- Update APIs for 11.0  
- Load LibDualSpec on all clients  
- Update TOC for 10.2.7 and 11.0.0  
- Fix luacheck  
- Spell Tick fixes for Cataclysm Classic  
- Prevent `C\_TradeSkillUI.CraftRecipe` error in Cataclysm Classic  
    Check for `C\_TradeSkillUI.CraftRecipe` before trying to hook it, since Cataclysm Classic has `C\_TradeSkillUI` but does not have `C\_TradeSkillUI.CraftRecipe`.  