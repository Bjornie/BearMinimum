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

local defaultDodgeAlert = {type = -1, filters = {[REGISTER_FILTER_COMBAT_RESULT] = ACTION_RESULT_BEGIN, [REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE] = COMBAT_UNIT_TYPE_PLAYER}, isDodgeable = true}
local defaultBlockAlert = {type = -1, filters = {[REGISTER_FILTER_COMBAT_RESULT] = ACTION_RESULT_BEGIN, [REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE] = COMBAT_UNIT_TYPE_PLAYER}, isDodgeable = false}

BearMinimum = {
    name = 'BearMinimum',
    svName = 'BearMinimumSV',
    svVersion = 1,

    defaults = {
        -- R, G, B, A
        alertDodgeColour = {1, 1, 0, 1},
        alertBlockColour = {1, 0, 0, 1},
    },

    abilityData = {},

    statusData = {},

    testData = {
        count = {type = 3, text = 'This is a test countdown', startTime = 5, endTime = 0, increment = -1},
        noti = {type = 2, text = 'This is a test notification'},
        dodge = defaultDodgeAlert,
        block = defaultBlockAlert
    }
}