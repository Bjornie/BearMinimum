local BM = BearMinimum
local EM = EVENT_MANAGER

local currentZoneId

local notificationFonts = {
    "esoui/common/fonts/Univers67.otf|30|soft-shadow-thick",
    "esoui/common/fonts/Univers67.otf|45|soft-shadow-thick",
}

local function OnCombatStateChanged(inCombat, bossMaxHealth)
    
end

local function UpdateCount(increment, endTime)
    local time = BearMinimum_Notifications_Count_Timer:GetText()
    time = tonumber(time) + increment

    if time == endTime then
        EM:UnregisterForUpdate('BearMinimum_UpdateCount')
        BearMinimum_Notifications_Count:SetHidden(true)
    else BearMinimum_Notifications_Count_Timer:SetText(time) end
end

local testTable = {}
local testVar

local function OnCombatEvent(data, eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    if not overflow then
        abilityActionSlotType = abilityActionSlotType:lower()
        if string.find(abilityActionSlotType, 'maarselok', nil, true) and result == ACTION_RESULT_BEGIN and not BM.defaults[targetUnitId] and not testTable[targetUnitId] then
            testTable[targetUnitId] = true
            d('-----')
            d('abilityName: ' .. isError)
            d('hitValue: ' .. targetType)
        end

        if targetUnitId == 123334 and (result == ACTION_RESULT_DODGED or result == ACTION_RESULT_BLOCKED) then
            testVar[1] = GetGameTimeMilliseconds() - testVar[1]
            d('Unrelenting Force offset: ' .. (testVar[1] - testVar[2]))
        end

        return
    end

    if data.type == 0 then -- Status
        
    elseif data.type > 0 then -- Notification
        local text = LocalizeString(data.text, targetName)

        if data.type > 2 then -- Count
            BearMinimum_Notifications_Count_Text:SetText(text)
            BearMinimum_Notifications_Count_Timer:SetText(data.startTime)

            local oldestNotification = BM.notificationPool.activeNotifications[1]
            oldestNotification:SetAnchor(TPO, BearMinimum_Notifications_Count, BOTTOM)

            BearMinimum_Notifications_Count:SetHidden(false)

            EM:RegisterForUpdate('BearMinimum_UpdateCount', 1000, function() UpdateCount(data.increment, data.endTime) end)
        else -- Small/large notification
            local object = BM.notificationPool:AcquireObject()
            local font = notificationFonts[data.type]
            local newestNotification = BM.notificationPool.activeNotifications[#BM.notificationPool.activeNotifications]

            object:SetAnchor(TOP, newestNotification or BearMinimum_Notifications, newestNotification and BOTTOM or TOP)
            object:SetFont(font)
            object:SetText(text)
            object:SetHidden(false)
            object.fade:PlayFromStart()
        end
    else -- data.type < 0, Alert
        local object = BM.alertPool:AcquireObject()
        local colour = data.isDodgeable and BM.sv.alertDodgeColour or BM.sv.alertBlockColour
        local r, g, b, a = unpack(colour)
        local sizeAnimation = object.timeline:GetFirstAnimation()

        object:SetAnchor(TOPLEFT, BearMinimum_Alerts, TOPLEFT, (#BM.alertPool.m_Active - 1) * 200 .. 'px')
        object.reactionLine:SetAnchor(LEFT, object.iconRightBorder, RIGHT, 150 * (1 - 1000 / hitValue) .. 'px')
        object.icon:SetTexture(data.isDodgeable and 'esoui/art/icons/ability_armor_002.dds' or 'esoui/art/icons/ability_1handed_004.dds')
        object.colour:SetColor(r, g, b, a)
        object.name:SetText(abilityName)
        sizeAnimation:SetDuration(hitValue)
        object:SetHidden(false)
        object.timeline:PlayFromStart()

        if abilityId == 123334 then testVar = {GetGameTimeMilliseconds(), hitValue} end
    end
end

local function UnregisterAbilities()
    for key, data in pairs(BM.abilityData[currentZoneId]) do
        local namespace = 'BearMinimum_AbilityId' .. key
        EM:UnregisterForEvent(namespace, EVENT_COMBAT_EVENT)
    end
end

local function RegisterAbilities()
    for key, data in pairs(BM.abilityData[currentZoneId]) do
        local namespace = 'BearMinimum_AbilityId' .. key
        EM:RegisterForEvent(namespace, EVENT_COMBAT_EVENT, function(...) OnCombatEvent(data, ...) end)
        EM:AddFilterForEvent(namespace, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, key)

        -- if data.type < 0 then
        --     EM:AddFilterForEvent(namespace, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
        -- end

        if data.filters then
            for filterType, filterParameter in pairs(data.filters) do
                EM:AddFilterForEvent(namespace, EVENT_COMBAT_EVENT, filterType, filterParameter)
            end
        end
    end

    -- EM:RegisterForEvent('BearMinimum_Test', EVENT_COMBAT_EVENT, OnCombatEvent)
end

function BM.TerminateOldZone()
    UnregisterAbilities()
end

function BM.InitialiseZone(zoneId)
    currentZoneId = zoneId
    BM.callbackManager:RegisterCallback('CombatStateChange', OnCombatStateChanged)
    RegisterAbilities()
end