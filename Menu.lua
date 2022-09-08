local BM = BearMinimum
local LAM = LibAddonMenu2

local function GetPanelData(name)
    return {
        type = 'panel',
        name = name and string.format('Bear Minimum - %s', name) or 'Bear Minimum',
        displayname = name and string.format('Bear Minimum - %s', name) or 'Bear Minimum',
        author = '|c00BFFFBjørn|r',
        version = '0.3.0',
        registerForRefresh = true,
        registerForDefaults = true,
    }
end

function BM.BuildMenu()
    local panelDataMain = GetPanelData()

    local optionsTableMain = {
        {
            type = 'header',
            name= '|cc4c29eGeneral|r',
        },
        {
            type = 'checkbox',
            name = 'Account-Wide Settings',
            getFunc = function() return BearMinimumSV.Default[GetDisplayName()]['$AccountWide'].isAccountWide end,
            setFunc = function(value)
                BearMinimumSV.Default[GetDisplayName()]['$AccountWide'].isAccountWide = value

                if value then BM.sv = ZO_SavedVars:NewAccountWide(BM.svName, BM.svVersion, nil, BM.defaults)
                else BM.sv = ZO_SavedVars:NewCharacterIdSettings(BM.svName, BM.svVersion, nil, BM.defaults) end
            end,
            default = BM.defaults.isAccountWide,
        },
        {
            type = 'colorpicker',
            name = 'Dodge-Alert Colour',
            getFunc = function() return unpack(BM.sv.alertDodgeColour) end,
            setFunc = function(r, g, b, a) BM.sv.alertDodgeColour = {r, g, b, a} end,
            default = BM.defaults.alertDodgeColour,
        },
        {
            type = 'colorpicker',
            name = 'Block-Alert Colour',
            getFunc = function() return unpack(BM.sv.alertBlockColour) end,
            setFunc = function(r, g, b, a) BM.sv.alertBlockColour = {r, g, b, a} end,
            default = BM.defaults.alertBlockColour,
        },
    }

    local panelDataDungeons = GetPanelData('Dungeons')

    local optionsTableDungeons = {}

    local panelDataArenas = GetPanelData('Arenas')

    local optionsTableArenas = {}

    local panelDataTrials = GetPanelData('Trials')

    local optionsTableTrials = {}

    LAM:RegisterAddonPanel(BM.name .. '_SettingsMain', panelDataMain)
    LAM:RegisterOptionControls(BM.name .. '_SettingsMain', optionsTableMain)

    LAM:RegisterAddonPanel(BM.name .. '_SettingsDungeons', panelDataDungeons)
    LAM:RegisterOptionControls(BM.name .. '_SettingsDungeons', optionsTableDungeons)

    LAM:RegisterAddonPanel(BM.name .. '_SettingsArenas', panelDataArenas)
    LAM:RegisterOptionControls(BM.name .. '_SettingsArenas', optionsTableArenas)

    LAM:RegisterAddonPanel(BM.name .. '_SettingsTrials', panelDataTrials)
    LAM:RegisterOptionControls(BM.name .. '_SettingsTrials', optionsTableTrials)
end