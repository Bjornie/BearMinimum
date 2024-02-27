local bearMin = BearMinimum
local evtMgr = GetEventManager()

local notificationFonts = {
    "esoui/common/fonts/Univers67.otf|30|soft-shadow-thick",
    "esoui/common/fonts/Univers67.otf|45|soft-shadow-thick",
}

local function UpdateCount(increment, endTime)
    local time = BearMinimum_NotificationsContainer_Count_Timer:GetText()
    time = tonumber(time) + increment

    if time == endTime then
        evtMgr:UnregisterForUpdate('BearMinimum_UpdateCount')
        BearMinimum_NotificationsContainer_Count:SetHidden(true)
    else BearMinimum_NotificationsContainer_Count_Timer:SetText(time) end
end

local function OnCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType,
                             hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow, data)
    if data.type == 0 then -- Status

    elseif data.type > 0 then -- Notification
        local text = LocalizeString(data.text, targetName)

        if data.type > 2 then -- Count
            BearMinimum_NotificationsContainer_Count_Text:SetText(text)
            BearMinimum_NotificationsContainer_Count_Timer:SetText(data.startTime)

            -- Transition active notifications down to make space for count
            if #bearMin.notificationPool.activeNotifications > 0 then
                local oldestNotification = bearMin.notificationPool.activeNotifications[1]
                local destination = BearMinimum_NotificationsContainer_Count:GetBottom()
                local distanceFromDestination = oldestNotification:GetTop() - destination
                local translate = oldestNotification.slide:GetFirstAnimation()

                oldestNotification:SetAnchor(TOP, BearMinimum_NotificationsContainer, TOP)
                translate:SetDeltaOffsetY(-distanceFromDestination)
                oldestNotification.slide:PlayFromStart()
            end

            BearMinimum_NotificationsContainer_Count:SetHidden(false)
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

        -- TODO: Fix multiple alerts (potential fix: change container anchor from center to topleft)
        object:SetAnchor(TOPLEFT, BearMinimum_AlertsContainer, TOPLEFT, (#bearMin.alertPool.m_Active - 1) * 200 .. 'px')
        object.reactionLine:SetAnchor(LEFT, object.iconRightBorder, RIGHT, 150 * (1 - 1000 / hitValue) .. 'px')
        object.icon:SetTexture(data.isDodgeable and 'esoui/art/icons/ability_armor_002.dds' or 'esoui/art/icons/ability_1handed_004.dds')
        object.animationBar:SetColor(r, g, b, a)
        object.name:SetText(abilityName)
        sizeAnimation:SetDuration(hitValue)
        object:SetHidden(false)
        object.timeline:PlayFromStart()
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
end