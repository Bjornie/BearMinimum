if not BearMinimum then BearMinimum = {} end

local BM = BearMinimum
local LAM = LibAddonMenu2

function BM:BuildMenu()
    local panelData = {
        type = 'panel',
        name = 'Bear Minimum',
        displayname = 'Bear Minimum',
        author = '|c00BFFFBjørn|r',
        version = BM.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local optionsTable = {
        {
            type = 'header',
            name = '|cc4c29eGeneral|r',
        },
        {
            type = 'colorpicker',
            name = 'Alert Dodgeable Attack Colour',
            getFunc = function() return unpack(BM.sv.alertDodgeColour) end,
            setFunc = function(r, g, b, a) BM.sv.alertDodgeColour = {r, g, b, a} end,
            default = BM.defaults.alertDodgeColour,
        },
        {
            type = 'colorpicker',
            name = 'Alert Non-Dodgeable Attack Colour',
            getFunc = function() return unpack(BM.sv.alertBlockColour) end,
            setFunc = function(r, g, b, a) BM.sv.alertBlockColour = {r, g, b, a} end,
            default = BM.defaults.alertBlockColour,
        },
        {
            type = 'submenu',
            name = '|cc4c29eAetherian Archive|r',
            controls = {
                {
                    type = 'header',
                    name = 'Lightning Storm Atronach',
                },
                {
                    type = 'checkbox',
                    name = 'Lightning Storm',
                    getFunc = function() return BM.sv.aetherianArchive.enableLightningStorm end,
                    setFunc = function(value) BM.sv.aetherianArchive.enableLightningStorm = value end,
                    tooltip = 'Status panel cooldown timer for boss channeling AoE explosions',
                    default = BM.defaults.aetherianArchive.enableLightningStorm,
                },
                {
                    type = 'checkbox',
                    name = 'Impending Storm',
                    getFunc = function() return BM.sv.aetherianArchive.enableImpendingStorm end,
                    setFunc = function(value) BM.sv.aetherianArchive.enableImpendingStorm = value end,
                    tooltip = 'Status panel cooldown timer for boss chargeup lightning explosion',
                    default = BM.defaults.aetherianArchive.enableImpendingStorm,
                },
                {
                    type = 'checkbox',
                    name = 'Storm Bound',
                    getFunc = function() return BM.sv.aetherianArchive.enableStormBound end,
                    setFunc = function(value) BM.sv.aetherianArchive.enableStormBound = value end,
                    tooltip = 'Notification for random target single target DoT and snare',
                    default = BM.defaults.aetherianArchive.enableStormBound,
                },
                {
                    type = 'header',
                    name = 'Foundation Stone Atronach',
                },
                {
                    type = 'checkbox',
                    name = 'Boulder Storm',
                    getFunc = function() return BM.sv.aetherianArchive.enableBoulderStorm end,
                    setFunc = function(value) BM.sv.aetherianArchive.enableBoulderStorm = value end,
                    tooltip = 'Status panel cooldown timer for boss channeling boulder spawns',
                    default = BM.defaults.aetherianArchive.enableBoulderStorm,
                },
                {
                    type = 'checkbox',
                    name = 'Boulder',
                    getFunc = function() return BM.sv.aetherianArchive.enableBoulder end,
                    setFunc = function(value) BM.sv.aetherianArchive.enableBoulder = value end,
                    tooltip = 'Alert for when a boulder is about to knock you down',
                    default = BM.defaults.aetherianArchive.enableBoulder,
                },
                {
                    type = 'checkbox',
                    name = 'Minions',
                    getFunc = function() return BM.sv.aetherianArchive.enableMinions end,
                    setFunc = function(value) BM.sv.aetherianArchive.enableMinions = value end,
                    tooltip = 'Notification for adds spawn',
                    default = BM.defaults.aetherianArchive.enableMinions,
                },
                {
                    type = 'checkbox',
                    name = 'Big Quake',
                    getFunc = function() return BM.sv.aetherianArchive.enableBigQuake end,
                    setFunc = function(value) BM.sv.aetherianArchive.enableBigQuake = value end,
                    tooltip = 'Status panel cooldown timer for boss stomps',
                    default = BM.defaults.aetherianArchive.enableBigQuake,
                },
                {
                    type = 'header',
                    name = 'Varlariel',
                },
                {
                    type = 'checkbox',
                    name = 'Mother Clone',
                    getFunc = function() return BM.sv.aetherianArchive.enableMotherClone end,
                    setFunc = function(value) BM.sv.aetherianArchive.enableMotherClone = value end,
                    tooltip = 'Status panel cooldown timer for boss clone split',
                    default = BM.defaults.aetherianArchive.enableMotherClone,
                },
                {
                    type = 'checkbox',
                    name = 'Combustion',
                    getFunc = function() return BM.sv.aetherianArchive.enableCloneBlastOrigin end,
                    setFunc = function(value) BM.sv.aetherianArchive.enableCloneBlastOrigin = value end,
                    tooltip = 'Alert for when boss is about to explode',
                    default = BM.defaults.aetherianArchive.enableCloneBlastOrigin,
                },
                {
                    type = 'checkbox',
                    name = 'Rain of Wisps',
                    getFunc = function() return BM.sv.aetherianArchive.enableRainOfWisps end,
                    setFunc = function(value) BM.sv.aetherianArchive.enableRainOfWisps = value end,
                    tooltip = 'Notification for small aoe explosions',
                    default = BM.defaults.aetherianArchive.enableRainOfWisps,
                },
                {
                    type = 'header',
                    name = 'The Mage',
                },
                {
                    type = 'checkbox',
                    name = 'Conjure Axe',
                    getFunc = function() return BM.sv.aetherianArchive.enableConjureAxe end,
                    setFunc = function(value) BM.sv.aetherianArchive.enableConjureAxe = value end,
                    tooltip = 'Notification for axe spawn',
                    default = BM.defaults.aetherianArchive.enableConjureAxe,
                },
                {
                    type = 'checkbox',
                    name = 'Conjured Mines',
                    getFunc = function() return BM.sv.aetherianArchive.enableConjuredMines end,
                    setFunc = function(value) BM.sv.aetherianArchive.enableConjuredMines = value end,
                    tooltip = 'Notification for boss placing mines on the ground',
                    default = BM.defaults.aetherianArchive.enableConjuredMines,
                },
                {
                    type = 'checkbox',
                    name = 'Levitate Down',
                    getFunc = function() return BM.sv.aetherianArchive.enableLevitateDown end,
                    setFunc = function(value) BM.sv.aetherianArchive.enableLevitateDown = value end,
                    tooltip = 'Notification for boss spawning',
                    default = BM.defaults.aetherianArchive.enableLevitateDown,
                },
                {
                    type = 'checkbox',
                    name = 'Mini Mage',
                    getFunc = function() return BM.sv.aetherianArchive.enableDummy end,
                    setFunc = function(value) BM.sv.aetherianArchive.enableDummy = value end,
                    tooltip = 'Notification for mini mage spawns',
                    default = BM.defaults.aetherianArchive.enableDummy,
                },
                {
                    type = 'checkbox',
                    name = 'Axe Slam',
                    getFunc = function() return BM.sv.aetherianArchive.enableSlam end,
                    setFunc = function(value) BM.sv.aetherianArchive.enableSlam = value end,
                    tooltip = 'Alert for when an axe is about to knock you down',
                    default = BM.defaults.aetherianArchive.enableSlam,
                },
            },
        },
    }

    LAM:RegisterAddonPanel(BM.name .. 'Options', panelData)
    LAM:RegisterOptionControls(BM.name .. 'Options', optionsTable)
end