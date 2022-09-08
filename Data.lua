BearMinimum = {}
local BM = BearMinimum

BM.name = 'BearMinimum'
BM.svName = 'BearMinimumSV'
BM.svVersion = 1

local defaultDodgeAlert = {type = -1, filters = {[REGISTER_FILTER_COMBAT_RESULT] = ACTION_RESULT_BEGIN, [REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE] = combat_unit_type_player}, isDodgeable = true}
local defaultBlockAlert = {type = -1, filters = {[REGISTER_FILTER_COMBAT_RESULT] = ACTION_RESULT_BEGIN, [REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE] = combat_unit_type_player}, isDodgeable = false}

--[[
    colours:
        physical: e5cc80
        poison: d1fa99
        disease: 7cb856
        bleed: c5bf9e
        magic: 8ff2ff
        fire: eb4561
        lightning: bfbfbf
        frost: 4a80ff
--]]
--[[
    type: notification type
        0 = status
        1 = small notification
        2 = large notification
        3 = countdown
        4 = countup
        -1 = alert
    filters: table of eventFilter, filterParameter pairs
    cooldown: integer representing status cooldown
    text: label for status and notification
    startTime: used by status and count notification. For statuses it indicates the cooldown from combat start until first cast. For count it indicates the starting value
    endTime: used by count notification
    increment: positive or negative (yes var name is misleading) integer. Used by count notification to in-/decrement
    isDodgeable: boolean determining alert colour and icon
    offset: integer offset (milliseconds) to hitValue for alerts
--]]
BM.abilityData = {
    -- Fang Lair
    [1009] = {
        [92892] = defaultDodgeAlert,
        [98667] = defaultDodgeAlert,
        [98809] = defaultBlockAlert,
        [98959] = defaultDodgeAlert,
    },

    -- Scalecaller Peak
    [1010] = {
        [99460] = defaultDodgeAlert,
        [99527] = defaultDodgeAlert,
        [101685] = defaultDodgeAlert,
    },

    -- March of Sacrifices
    [1055] = {},

    -- Lair of Maarselok
    [1123] = {
        --[[
            TODO:
                Breath
                Cleanse
        --]]
        [122984] = defaultDodgeAlert,
        [123242] = defaultDodgeAlert,
        [123334] = defaultDodgeAlert, -- TODO: offset
        [123402] = defaultDodgeAlert,
        [123825] = {type = 2, text = '|cd1fa99Selene|r Is Channeling |cd1fa99Poison Bolt|r'},
        [123840] = {type = 2, text = '|cd1fa99Poison Wave|r On <<1>>'},
        [123906] = defaultDodgeAlert,
        [124008] = defaultBlockAlert, -- TODO: fix, something, anything
        [124432] = defaultDodgeAlert,
        [126530] = defaultDodgeAlert,
        [126695] = defaultDodgeAlert,
        [127139] = defaultDodgeAlert,
        [128667] = defaultDodgeAlert,
        [129133] = defaultDodgeAlert,
    },
}

BM.defaults = {
    isAccountWide = true,
    -- isUILocked = true,

    -- statusLeft = 200,
    -- statusTop = 200,
    -- notificationLeft = 0,
    -- notificationTop = 200,
    -- alertLeft = 0,
    -- alertTop = -100,

    -- R, G, B, A
    alertDodgeColour = {1, 1, 0, 1},
    alertBlockColour = {1, 0, 0, 1},

    -- Aetherian Archive
    [47898] = true, -- Lightning Storm, Lightning Storm Atronach
    [48240] = true, -- Boulder Storm, Foundation Stone Atronach
    [49098] = false, -- Big Quake, Foundation Stone Atronach
    [49311] = true, -- Boulder, Boulder
    [49417] = false, -- Dummy, Conjured Reflection
    [49506] = false, -- Conjure Axe, The Mage
    [49583] = false, -- Impending Storm, Lightning Storm Atronach
    [49669] = false, -- Conjure Axe, The Mage
    [49747] = true, -- Clone Blast Origin, Varlariel
    [50547] = true, -- Slam, Conjured Axe
    [56426] = false, -- Atronach Spawn in, Storm Atronach
    [58218] = true, -- Overcharged, Firstmage Overcharger
    [79390] = true, -- Call Lightning, Firstmage Overcharger

    -- Fang Lair
    [92892] = true, -- Clash of Bones, Bone Colossus
    [98667] = true, -- Uppercut, Ulfnor
    [98809] = true, -- Draconic Smash, Ulfnor
    [98959] = true, -- Death Grip, Cadaverous Senche-Tiger

    -- Scalecaller Peak
    [99460] = true, -- Crushing Blow, Orzun the Foul-Smelling
    [99527] = true, -- Lacerate, Doylemish Ironheart
    [101685] = true, -- Power Bash, Mortieu's Guard

    -- Lair of Maarselok
    [122984] = true, -- Chomp, Maarselok
    [123242] = true, -- Azureblight Spume, Maarselok
    [123334] = true, -- Unrelenting Force, Maarselok
    [123402] = true, -- Crushing Limbs, Azureblight Lurcher
    [123825] = true, -- Poison Bolt, Selene
    [123840] = true, -- Poison Wave, Selene
    [123906] = true, -- Venomous Fangs, Selene's Fangs
    [124008] = true, -- Azureblight Sputum, Maarselok
    [124432] = true, -- Crushing Limbs, Azureblight Lurcher
    [126530] = true, -- Devastate, Azureblight Corruptor
    [126695] = true, -- Deadly Strike, Azureblight Vitiate
    [127139] = true, -- Sickening Smash, Azureblight Infestor
    [128667] = true, -- Sickening Smash, Azureblight Infestor
    [129133] = true, -- Icy Blast, Azureblight Frostmage
}