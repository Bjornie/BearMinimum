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
                    getFunc = function() return BM.sv.AetherianArchive.enableLightningStorm end,
                    setFunc = function(value) BM.sv.AetherianArchive.enableLightningStorm = value end,
                    tooltip = 'Status panel cooldown timer for boss channeling AoE explosions',
                    default = BM.defaults.AetherianArchive.enableLightningStorm,
                },
                {
                    type = 'checkbox',
                    name = 'Impending Storm',
                    getFunc = function() return BM.sv.AetherianArchive.enableImpendingStorm end,
                    setFunc = function(value) BM.sv.AetherianArchive.enableImpendingStorm = value end,
                    tooltip = 'Status panel cooldown timer for boss chargeup lightning explosion',
                    default = BM.defaults.AetherianArchive.enableImpendingStorm,
                },
                {
                    type = 'checkbox',
                    name = 'Storm Bound',
                    getFunc = function() return BM.sv.AetherianArchive.enableStormBound end,
                    setFunc = function(value) BM.sv.AetherianArchive.enableStormBound = value end,
                    tooltip = 'Notification for random target single target DoT and snare',
                    default = BM.defaults.AetherianArchive.enableStormBound,
                },
                {
                    type = 'header',
                    name = 'Foundation Stone Atronach',
                },
                {
                    type = 'checkbox',
                    name = 'Boulder Storm',
                    getFunc = function() return BM.sv.AetherianArchive.enableBoulderStorm end,
                    setFunc = function(value) BM.sv.AetherianArchive.enableBoulderStorm = value end,
                    tooltip = 'Status panel cooldown timer for boss channeling boulder spawns',
                    default = BM.defaults.AetherianArchive.enableBoulderStorm,
                },
                {
                    type = 'checkbox',
                    name = 'Boulder',
                    getFunc = function() return BM.sv.AetherianArchive.enableBoulder end,
                    setFunc = function(value) BM.sv.AetherianArchive.enableBoulder = value end,
                    tooltip = 'Alert for when a boulder is about to knock you down',
                    default = BM.defaults.AetherianArchive.enableBoulder,
                },
                {
                    type = 'checkbox',
                    name = 'Minions',
                    getFunc = function() return BM.sv.AetherianArchive.enableMinions end,
                    setFunc = function(value) BM.sv.AetherianArchive.enableMinions = value end,
                    tooltip = 'Notification for adds spawn',
                    default = BM.defaults.AetherianArchive.enableMinions,
                },
                {
                    type = 'checkbox',
                    name = 'Big Quake',
                    getFunc = function() return BM.sv.AetherianArchive.enableBigQuake end,
                    setFunc = function(value) BM.sv.AetherianArchive.enableBigQuake = value end,
                    tooltip = 'Status panel cooldown timer for boss stomps',
                    default = BM.defaults.AetherianArchive.enableBigQuake,
                },
                {
                    type = 'header',
                    name = 'Varlariel',
                },
                {
                    type = 'checkbox',
                    name = 'Mother Clone',
                    getFunc = function() return BM.sv.AetherianArchive.enableMotherClone end,
                    setFunc = function(value) BM.sv.AetherianArchive.enableMotherClone = value end,
                    tooltip = 'Status panel cooldown timer for boss clone split',
                    default = BM.defaults.AetherianArchive.enableMotherClone,
                },
                {
                    type = 'checkbox',
                    name = 'Combustion',
                    getFunc = function() return BM.sv.AetherianArchive.enableCloneBlastOrigin end,
                    setFunc = function(value) BM.sv.AetherianArchive.enableCloneBlastOrigin = value end,
                    tooltip = 'Alert for when boss is about to explode',
                    default = BM.defaults.AetherianArchive.enableCloneBlastOrigin,
                },
                {
                    type = 'checkbox',
                    name = 'Rain of Wisps',
                    getFunc = function() return BM.sv.AetherianArchive.enableRainOfWisps end,
                    setFunc = function(value) BM.sv.AetherianArchive.enableRainOfWisps = value end,
                    tooltip = 'Notification for small aoe explosions',
                    default = BM.defaults.AetherianArchive.enableRainOfWisps,
                },
                {
                    type = 'header',
                    name = 'The Mage',
                },
                {
                    type = 'checkbox',
                    name = 'Conjure Axe',
                    getFunc = function() return BM.sv.AetherianArchive.enableConjureAxe end,
                    setFunc = function(value) BM.sv.AetherianArchive.enableConjureAxe = value end,
                    tooltip = 'Notification for axe spawn',
                    default = BM.defaults.AetherianArchive.enableConjureAxe,
                },
                {
                    type = 'checkbox',
                    name = 'Conjured Mines',
                    getFunc = function() return BM.sv.AetherianArchive.enableConjuredMines end,
                    setFunc = function(value) BM.sv.AetherianArchive.enableConjuredMines = value end,
                    tooltip = 'Notification for boss placing mines on the ground',
                    default = BM.defaults.AetherianArchive.enableConjuredMines,
                },
                {
                    type = 'checkbox',
                    name = 'Levitate Down',
                    getFunc = function() return BM.sv.AetherianArchive.enableLevitateDown end,
                    setFunc = function(value) BM.sv.AetherianArchive.enableLevitateDown = value end,
                    tooltip = 'Notification for boss spawning',
                    default = BM.defaults.AetherianArchive.enableLevitateDown,
                },
                {
                    type = 'checkbox',
                    name = 'Mini Mage',
                    getFunc = function() return BM.sv.AetherianArchive.enableDummy end,
                    setFunc = function(value) BM.sv.AetherianArchive.enableDummy = value end,
                    tooltip = 'Notification for mini mage spawns',
                    default = BM.defaults.AetherianArchive.enableDummy,
                },
                {
                    type = 'checkbox',
                    name = 'Axe Slam',
                    getFunc = function() return BM.sv.AetherianArchive.enableSlam end,
                    setFunc = function(value) BM.sv.AetherianArchive.enableSlam = value end,
                    tooltip = 'Alert for when an axe is about to knock you down',
                    default = BM.defaults.AetherianArchive.enableSlam,
                },
            },
        },
    }

    LAM:RegisterAddonPanel(BM.name .. 'Options', panelData)
    LAM:RegisterOptionControls(BM.name .. 'Options', optionsTable)
end