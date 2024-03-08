local bearMin = BearMinimum
local evtMgr = GetEventManager()

local notificationFonts = {
    "esoui/common/fonts/Univers67.otf|30|soft-shadow-thick",
    "esoui/common/fonts/Univers67.otf|45|soft-shadow-thick",
}

local activeStatus = {}

local function UpdateStatus(abilityId)
    local object = activeStatus[abilityId]
    local time = object.timer:GetText()
    time = tonumber(time) - 1

    object.timer:SetText(time)

    if time == 5 then
        object.timer:SetColor(1, 0.65, 0, 1)
    elseif time == 0 then
        evtMgr:UnregisterForUpdate('BearMinimum_UpdateStatus' .. abilityId)
        object.timer:SetColor(0, 1, 0, 1)
    end
end

local function UpdateCount(increment, endTime)
    local time = BearMinimum_NotificationsContainer_Count_Timer:GetText()
    time = tonumber(time) + increment

    if time == endTime then
        evtMgr:UnregisterForUpdate('BearMinimum_UpdateCount')
        BearMinimum_NotificationsContainer_Count:SetHidden(true)

        -- Move notifications back up now that the count is gone
        if #bearMin.notificationPool.activeNotifications > 0 then
            bearMin.TransitionActiveNotifications()
        end
    else BearMinimum_NotificationsContainer_Count_Timer:SetText(time) end
end

local function OnCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType,
                             hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow, data)
    if data.type == 0 then -- Status
        local object = activeStatus[abilityId]

        object.timer:SetText(data.cooldown)
        object.timer:SetColor(1, 0, 0, 1)

        evtMgr:RegisterForUpdate('BearMinimum_UpdateStatus' .. abilityId, 1000, function() UpdateStatus(abilityId) end)
    elseif data.type > 0 then -- Notification
        local text = LocalizeString(data.text, targetName)

        if data.type > 2 then -- Count
            BearMinimum_NotificationsContainer_Count_Text:SetText(text)
            BearMinimum_NotificationsContainer_Count_Timer:SetText(data.startTime)
            BearMinimum_NotificationsContainer_Count:SetHidden(false)

            -- Transition active notifications down to make space for count
            if #bearMin.notificationPool.activeNotifications > 0 then
                bearMin.TransitionActiveNotifications()
            end

            evtMgr:RegisterForUpdate('BearMinimum_UpdateCount', 1000, function() UpdateCount(data.increment, data.endTime) end)
        else -- Small/large notification
            local object = bearMin.notificationPool:AcquireObject()
            local font = notificationFonts[data.type]
            -- Relative anchor priority order: bottom notification, bottom count, top container
            local newestNotification = bearMin.notificationPool.activeNotifications[#bearMin.notificationPool.activeNotifications]
            local count = not BearMinimum_NotificationsContainer_Count:IsHidden() and BearMinimum_NotificationsContainer_Count

            object:SetAnchor(TOP, newestNotification or count or BearMinimum_NotificationsContainer, (newestNotification or count) and BOTTOM or TOP)
            object:SetFont(font)
            object:SetText(text)
            object:SetHidden(false)
            object.fade:PlayFromStart()
        end
    else -- data.type < 0, Alert
        local object = bearMin.alertPool:AcquireObject()
        local colour = data.isDodgeable and bearMin.sv.alertDodgeColour or bearMin.sv.alertBlockColour
        local r, g, b, a = unpack(colour)
        local sizeAnimation = object.timeline:GetFirstAnimation()

        object:SetAnchor(TOPLEFT, BearMinimum_AlertsContainer, TOPLEFT, (#bearMin.alertPool.m_Active - 1) * 250)
        object.reactionLine:SetAnchor(LEFT, object.iconRightBorder, RIGHT, 200 * (1 - 1000 / hitValue))
        object.icon:SetTexture(data.isDodgeable and 'esoui/art/icons/ability_armor_002.dds' or 'esoui/art/icons/ability_1handed_004.dds')
        object.animationBar:SetColor(r, g, b, a)
        object.name:SetText(abilityName)
        sizeAnimation:SetDuration(hitValue)
        object:SetHidden(false)
        object.timeline:PlayFromStart()
    end
end

local function OnBossChange(eventCode, forceReset)
    local bossName = string.lower(GetUnitName('boss1'))

    for index, abilityId in ipairs(bearMin.statusData[bossName]) do
        activeStatus[abilityId] = bearMin.statusPool:AcquireObject()
    end
end

function bearMin.TerminateZone(abilityData)
    for key, data in pairs(abilityData) do
        local namespace = 'BearMinimum_AbilityId' .. key
        evtMgr:UnregisterForEvent(namespace, EVENT_COMBAT_EVENT)
    end
end

function bearMin.InitialiseZone(abilityData)
    for key, data in pairs(abilityData) do
        local namespace = 'BearMinimum_AbilityId' .. key
        evtMgr:RegisterForEvent(namespace, EVENT_COMBAT_EVENT, function(...) OnCombatEvent(..., data) end)
        evtMgr:AddFilterForEvent(namespace, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, key)

        if data.filters then
            for filterType, filterParameter in pairs(data.filters) do
                evtMgr:AddFilterForEvent(namespace, EVENT_COMBAT_EVENT, filterType, filterParameter)
            end
        end
    end

    evtMgr:RegisterForEvent(bearMin.name, EVENT_BOSS_CHANGED, OnBossChange)
end

-- /script BearMinimum.TestCount()
function bearMin.TestCount()
    OnCombatEvent(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, bearMin.testData.count)
end

-- /script BearMinimum.TestNoti()
function bearMin.TestNoti()
    OnCombatEvent(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, bearMin.testData.noti)
end

-- /script BearMinimum.TestAlert()
function bearMin.TestAlert(bool)
    if bool then
        OnCombatEvent(_, _, _, 'Test Alert', _, _, _, _, _, _, 3000, _, _, _, _, _, _, _, bearMin.testData.dodge)
    else
        OnCombatEvent(_, _, _, 'Test Alert', _, _, _, _, _, _, 3000, _, _, _, _, _, _, _, bearMin.testData.block)
    end
end