local bearMin = BearMinimum
local evtMgr = GetEventManager()
local winMgr = GetWindowManager()
local aniMgr = GetAnimationManager()

local activeZone

local function AlertFactory(objectPool, objectKey)
    local id = objectPool:GetNextControlId()
    local alert = winMgr:CreateControlFromVirtual('BearMinimum_Alert', BearMinimum_AlertsContainer, 'BearMinimum_Alert', id)
    alert.name = alert:GetNamedChild('_Name')
    alert.icon = alert:GetNamedChild('_Icon')
    alert.iconRightBorder = alert:GetNamedChild('_IconRightBorder')
    alert.reactionLine = alert:GetNamedChild('_ReactionLine')
    alert.animationBar = alert:GetNamedChild('_AnimationBar')
    alert.timeline = aniMgr:CreateTimeline()
    local sizeAnimation = alert.timeline:InsertAnimation(ANIMATION_SIZE, alert.animationBar)
    sizeAnimation:SetStartAndEndHeight(35, 35)
    sizeAnimation:SetEndWidth(200)

    -- Auto handle object release
    alert.timeline:SetHandler('OnStop', function() objectPool:ReleaseObject(objectKey) end)

    return alert
end

local function StatusFactory(objectPool, objectKey)
    local id = objectPool:GetNextControlId()
    local status = winMgr:CreateControlFromVirtual('BearMinimum_Status', BearMinimum_StatusPanel, 'BearMinimum_Status', id)
    status.name = status:GetNamedChild('_Name')
    status.timer = status:GetNamedChild('_Timer')

    return status
end

local function NotificationFactory(objectPool, objectKey)
    local id = objectPool:GetNextControlId()
    local notification = winMgr:CreateControlFromVirtual('BearMinimum_Notification', BearMinimum_NotificationsContainer, 'BearMinimum_Notification', id)
    notification.fade = aniMgr:CreateTimelineFromVirtual('BearMinimum_NotificationFade', notification)
    notification.slide = aniMgr:CreateTimelineFromVirtual('BearMinimum_NotificationSlide', notification)

    notification.fade:SetHandler('OnPlay', function()
        table.insert(objectPool.activeNotifications, notification)
        notification:SetAlpha(1)
    end)

    -- Auto handle object release
    notification.fade:SetHandler('OnStop', function()
        objectPool:ReleaseObject(objectKey)
        table.remove(objectPool.activeNotifications, 1)
        
        if #objectPool.activeNotifications > 0 then
            bearMin.TransitionActiveNotifications()
        end
    end)

    return notification
end

local function Reset(object, objectPool)
    object:ClearAnchors()
    object:SetHidden(true)
end

local function OnPlayerActivated(eventCode, initial)
    local data = bearMin.abilityData[activeZone]

    if data then bearMin.TerminateZone(data) end

    activeZone = GetUnitWorldPosition('player')
    data = bearMin.abilityData[activeZone]

    if data then bearMin.InitialiseZone(data) end
end

-- Notification anchors are hooked to the bottom of each other,
-- so it is only necessary to transition the oldest (topmost) notification
-- to move all active notifications
function bearMin.TransitionActiveNotifications()
    local oldestNotification = bearMin.notificationPool.activeNotifications[1]
    local isCountHidden = BearMinimum_NotificationsContainer_Count:IsHidden()
    local relativeAnchor = not isCountHidden and BearMinimum_NotificationsContainer_Count or BearMinimum_NotificationsContainer
    local destination = not isCountHidden and BearMinimum_NotificationsContainer_Count:GetBottom() or BearMinimum_NotificationsContainer:GetTop()
    local distanceFromDestination = oldestNotification:GetTop() - destination
    local translate = oldestNotification.slide:GetFirstAnimation()

    oldestNotification:SetAnchor(TOP, relativeAnchor, isCountHidden and TOP or BOTTOM, 0, distanceFromDestination)
    translate:SetDeltaOffsetY(-distanceFromDestination)
    oldestNotification.slide:PlayFromStart()
end

local function OnAddonLoaded(eventCode, addonName)
    if addonName == bearMin.name then
        evtMgr:UnregisterForEvent(bearMin.name, eventCode)

        bearMin.sv = ZO_SavedVars:NewAccountWide(bearMin.svName, bearMin.svVersion, nil, bearMin.defaults)
        if not bearMin.sv.isAccountWide then bearMin.sv = ZO_SavedVars:NewCharacterIdSettings(bearMin.svName, bearMin.svVersion, nil, bearMin.defaults) end

        -- Object pools explained: https://www.esoui.com/forums/showthread.php?t=143
        bearMin.alertPool = ZO_ObjectPool:New(AlertFactory, Reset)
        bearMin.statusPool = ZO_ObjectPool:New(StatusFactory, Reset)
        bearMin.notificationPool = ZO_ObjectPool:New(NotificationFactory, Reset)
        -- There's no reliable way to get the newest object through m_Active,
        -- so we use our own table with table.insert and table.remove
        bearMin.notificationPool.activeNotifications = {}

        evtMgr:RegisterForEvent(bearMin.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    end
end

evtMgr:RegisterForEvent(bearMin.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)