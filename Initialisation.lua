local BM = BearMinimum
local AM = ANIMATION_MANAGER
local EM = EVENT_MANAGER
local WM = WINDOW_MANAGER

local function StatusFactory(objectPool, objectKey)
    local id = objectPool:GetNextControlId()
    local status = WM:CreateControlFromVirtual('BearMinimum_StatusControl', BearMinimum_StatusPanel, 'BearMinimum_Status', id)
    status.name = status:GetNamedChild('_Name')
    status.timer = status:GetNamedChild('_Timer')

    return status
end

-- Notification anchors are hooked to the bottom of each other,
-- so it is only necessary to transition the oldest (topmost) notification
-- to move all active notifications
local function TransitionActiveNotifications()
    local oldestNotification = BM.notificationPool.activeNotifications[1]
    local destination = not BearMinimum_Notifications_Count:IsHidden() and BearMinimum_Notifications_Count:GetBottom() or BearMinimum_Notifications:GetTop()
    local distanceFromDestination = oldestNotification:GetTop() - destination
    local translate = oldestNotification.slide:GetFirstAnimation()

    oldestNotification:SetAnchor(TOP, BearMinimum_Notifications, TOP, 0, distanceFromDestination)
    translate:SetDeltaOffsetY(-distanceFromDestination)
    oldestNotification.slide:PlayFromStart()
end

local function NotificationFactory(objectPool, objectKey)
    local id = objectPool:GetNextControlId()
    local notification = WM:CreateControlFromVirtual('BearMinimum_NotificationControl', BearMinimum_Notifications, 'BearMinimum_Notification', id)
    notification.fade = AM:CreateTimelineFromVirtual('BearMinimum_NotificationFade', notification)
    notification.slide = AM:CreateTimelineFromVirtual('BearMinimum_NotificationSlide', notification)

    notification.fade:SetHandler('OnStart', function()
        table.insert(objectPool.activeNotifications, notification)
        notification:SetAlpha(1)
    end)
    -- Auto handle object release
    notification.fade:SetHandler('OnStop', function()
        objectPool:ReleaseObject(objectKey)
        table.remove(objectPool.activeNotifications, 1)

        if #objectPool.m_Active > 0 and #objectPool.activeNotifications > 0 then
            TransitionActiveNotifications()

            for i = 1, #objectPool.m_Active do
                
            end
        end
    end)

    return notification
end

local function AlertFactory(objectPool, objectKey)
    local id = objectPool:GetNextControlId()
    local alert = WM:CreateControlFromVirtual('BearMinimum_AlertControl', BearMinimum_Alerts, 'BearMinimum_Alert', id)
    alert.name = alert:GetNamedChild('_Name')
    alert.icon = alert:GetNamedChild('_Icon')
    alert.iconRightBorder = alert:GetNamedChild('_IconRightBorder')
    alert.reactionLine = alert:GetNamedChild('_ReactionLine')
    alert.colour = alert:GetNamedChild('_Colour')

    -- Animations do not accept meassurement units in pixels so we do a little workaround
    alert.timeline = AM:CreateTimeline()
    local sizeAnimation = alert.timeline:InsertAnimation(ANIMATION_SIZE, alert.colour)
    local sizeHeight = alert.icon:GetHeight()
    sizeAnimation:SetStartAndEndHeight(sizeHeight, sizeHeight)
    sizeAnimation:SetEndWidth(6 * sizeHeight) -- Easiest way I've found to get the 'pizel width' in ui units

    -- Auto handle object release
    alert.timeline:SetHandler('OnStop', function() objectPool:ReleaseObject(objectKey) end)

    return alert
end

local function Reset(object, objectPool)
    object:ClearAnchors()
    object:SetHidden(true)
end

local function OnPlayerActivated(eventCode, initial)
    BM.TerminateOldZone()
    local zoneId = GetUnitWorldPosition('player')
    if BM.abilityData[zoneId] then BM.InitialiseZone(zoneId) end
end

local isPlayerInCombat = false
local function OnCombatStateChanged(eventCode, inCombat)
    if isPlayerInCombat ~= inCombat then
        if inCombat then
            isPlayerInCombat = true

            -- local currentHealth, maxHealth
            -- if DoesUnitExist('boss1') then currentHealth, maxHealth = GetUnitPower('boss1', POWERTYPE_HEALTH) end

            -- BM.callbackManager:FireCallbacks('CombatStateChange', isPlayerInCombat, maxHealth)

            -- HANDLE COMBAT START HERE
        else
            -- zo_callLater(function()
            --     if not IsUnitInCombat('player') then
            --         isPlayerInCombat = false
            --         BM.callbackManager:FireCallbacks('CombatStateChange', isPlayerInCombat)
            --     end
            -- end, 1000)

            --  HANDLE COMBAT END HERE
        end
    end
end

local function OnAddonLoaded(eventCode, addonName)
    if addonName == BM.name then
        EM:UnregisterForEvent(addonName, eventCode)

        BM.sv = ZO_SavedVars:NewAccountWide(BM.svName, BM.svVersion, nil, BM.defaults)
        if not BM.sv.isAccountWide then BM.sv = ZO_SavedVars:NewCharacterIdSettings(BM.svName, BM.svVersion, nil, BM.defaults) end

        BM.callbackManager = ZO_CallbackObject:New()

        -- Object pools explained: https://www.esoui.com/forums/showthread.php?t=143
        BM.statusPool = ZO_ObjectPool:New(StatusFactory, Reset)
        BM.notificationPool = ZO_ObjectPool:New(NotificationFactory, Reset)
        BM.notificationPool.activeNotifications = {}
        BM.alertPool = ZO_ObjectPool:New(AlertFactory, Reset)

        EM:RegisterForEvent(BM.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
        EM:RegisterForEvent(BM.name, EVENT_PLAYER_COMBAT_STATE, OnCombatStateChanged)
        local inCombat = IsUnitInCombat('player')
        OnCombatStateChanged(nil, inCombat) -- Player can be in combat after reloadui

        BM.BuildMenu()
    end
end

EM:RegisterForEvent(BM.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)