﻿-- Not translations
MkQL_MAX_REWARDS						= 10
MONKEYQUESTLOG_TITLE					= "MonkeyQuestLog"
MONKEYQUESTLOG_VERSION					= "0.12.0"
MONKEYQUESTLOG_TITLE_VERSION			= MONKEYQUESTLOG_TITLE .. " v" .. MONKEYQUESTLOG_VERSION
MONKEYQUESTLOG_INFO_COLOUR				= "|cffffff00"

-- English, the default
MONKEYQUESTLOG_DESCRIPTION				= "Displays the full quest description for MonkeyQuest"
MONKEYQUESTLOG_LOADED_MSG				= MONKEYQUESTLOG_INFO_COLOUR .. MONKEYQUESTLOG_TITLE .. " v" .. MONKEYQUESTLOG_VERSION .. " loaded"

MONKEYQUESTLOG_DESC_HEADER				= "Description"
MONKEYQUESTLOG_REWARDS_HEADER			= "Rewards"
MkQL_REWARDSCHOOSE_TXT					= "Choose one of:"
MkQL_REWARDSRECEIVE_TXT					= "Receive all of:"
MkQL_SHARE_TXT							= "Share"
MkQL_ABANDON_TXT						= "Abandon"


if (GetLocale() == "deDE") then

MONKEYQUESTLOG_DESCRIPTION				= "Zeigt die volle Quest Beschreibung für MonkeyQuest an"
MONKEYQUESTLOG_LOADED_MSG				= MONKEYQUESTLOG_INFO_COLOUR .. MONKEYQUESTLOG_TITLE .. " v" .. MONKEYQUESTLOG_VERSION .. " geladen"

MONKEYQUESTLOG_DESC_HEADER				= "Beschreibung"
MONKEYQUESTLOG_REWARDS_HEADER			= "Belohnungen"
MkQL_REWARDSCHOOSE_TXT					= "Auf Euch wartet eine dieser Belohnungen:"
MkQL_REWARDSRECEIVE_TXT					= "Ihr bekommt:"
MkQL_SHARE_TXT							= "Teilen"
MkQL_ABANDON_TXT						= "Abbrechen"

elseif (GetLocale() == "ruRU") then

MONKEYQUESTLOG_DESCRIPTION				= "Отображает полное описание квеста для MonkeyQuest"
MONKEYQUESTLOG_LOADED_MSG				= MONKEYQUESTLOG_INFO_COLOUR .. MONKEYQUESTLOG_TITLE .. " v" .. MONKEYQUESTLOG_VERSION .. " загрузка"

MONKEYQUESTLOG_DESC_HEADER				= "Описание"
MONKEYQUESTLOG_REWARDS_HEADER			= "Награды"
MkQL_REWARDSCHOOSE_TXT					= "Выберите один из:"
MkQL_REWARDSRECEIVE_TXT					= "Получить все:"
MkQL_SHARE_TXT							= "Предложить"
MkQL_ABANDON_TXT						= "Отменить"

elseif (GetLocale() == "zhTW") then

MONKEYQUESTLOG_DESCRIPTION				= "為MonkeyQuest顯示完整的任務描述"
MONKEYQUESTLOG_LOADED_MSG				= MONKEYQUESTLOG_INFO_COLOUR .. MONKEYQUESTLOG_TITLE .. " v" .. MONKEYQUESTLOG_VERSION .. " 載入"

MONKEYQUESTLOG_DESC_HEADER				= "描述"
MONKEYQUESTLOG_REWARDS_HEADER			= "獎金"
MkQL_REWARDSCHOOSE_TXT					= "下列擇一："
MkQL_REWARDSRECEIVE_TXT					= "下列所有："
MkQL_SHARE_TXT							= "分享"
MkQL_ABANDON_TXT						= "放棄"

elseif (GetLocale() == "zhCN") then

MONKEYQUESTLOG_DESCRIPTION				= "为MonkeyQuest显示完整的任务描述"
MONKEYQUESTLOG_LOADED_MSG				= MONKEYQUESTLOG_INFO_COLOUR .. MONKEYQUESTLOG_TITLE .. " v" .. MONKEYQUESTLOG_VERSION .. " 载入"

MONKEYQUESTLOG_DESC_HEADER				= "描述"
MONKEYQUESTLOG_REWARDS_HEADER			= "奖金"
MkQL_REWARDSCHOOSE_TXT					= "下列择一："
MkQL_REWARDSRECEIVE_TXT					= "下列所有："
MkQL_SHARE_TXT							= "分享"
MkQL_ABANDON_TXT						= "放弃"

end