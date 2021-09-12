if not BearMinimum then BearMinimum = {} end
local BM = BearMinimum

BM.name = 'BearMinimum'
BM.version = '0.1.0'
BM.svName = 'BearMinimumSV'
BM.svVersion = 1

BM.defaults = {
    isAccountWide = true,

    -- R, G, B, A
    alertDodgeColour = {1, 1, 0, 1},
    alertBlockColour = {1, 0, 0, 1},

    AetherianArchive = {
        enableLightningStorm = true,
        enableImpendingStorm = true,
        enableStormBound = false,
        enableBoulderStorm = true,
        enableMinions = false,
        enableBigQuake = false,
        enableMotherClone = true,
        enableCloneBlastOrigin = true,
        enableRainOfWisps = false,
        enableConjureAxe = true,
        enableConjuredMines = false,
        enableLevitateDown = true,
        enableBoulder = true,
        enableDummy = true,
        enableSlam = true,
    },
}

-- Local globals for faster reference
local AM = GetAnimationManager() -- https://www.esoui.com/forums/showthread.php?t=1191
local EM = GetEventManager()
local WM = GetWindowManager()

local isPlayerInCombat = false

local activeNotifications = {}

local zoneIds = {
    -- [635] = BearMinimum_InitialiseDragonstarArena,
    -- [636] = BearMinimum_InitialiseHelRaCitadel,
    -- [638] = BM.InitialiseAetherianArchive,
    -- [639] = BearMinimum_InitialiseSanctumOphidia,
    -- [677] = BearMinimum_InitialiseMaelstromArena,
    -- [725] = BearMinimum_InitialiseMawOfLorkhaj,
    -- [975] = BearMinimum_InitialiseHallsOfFabrication,
    -- [1000] = BearMinimum_InitialiseAsylumSanctorium,
    -- [1051] = BearMinimum_InitialiseCloudrest,
    -- [1082] = BearMinimum_InitialiseBlackrosePrison,
    -- [1121] = BearMinimum_InitialiseSunspire,
    -- [1196] = BearMinimum_InitialiseKynesAegis,
    -- [1227] = BearMinimum_InitialiseVateshranHollows,
    -- [1263] = BearMinimum_InitialiseRockgrove,
}

local function StatusPanelFactory(objectPool, objectKey)
    return WM:CreateControlFromVirtual('BearMinimum_StatusPanelTemplateControl', BearMinimum_StatusPanel, 'BearMinimum_StatusPanelTemplateControl', objectPool:GetNextControlId())
end

local function Reset(control)
    control:SetHidden(true)
    control:ClearAnchors()
end

-- Acquire any free object but use specified objectKey
local function AcquireUnusedObject(self, objectKey)
    local object, freeKey

    if #self.m_Free > 0 then
        freeKey, object = next(self.m_Free)
        self.m_Free[freeKey] = nil
    else object = self:m_Factory() end

    self.m_Active[objectKey] = object

    if self.customAcquireBehavior then self.customAcquireBehavior(object, objectKey) end

    return object
end

-- Shift up notifications when one disappears
local function TransitionActiveNotifications()
    local oldestNotification = activeNotifications[1]
    local distanceFromDestination = oldestNotification:GetTop() - BearMinimum_Notifications:GetTop()
    local translate = oldestNotification.slide:GetFirstAnimation()

    oldestNotification:SetAnchor(TOP, BearMinimum_Notifications, TOP, 0, distanceFromDestination)
    translate:SetDeltaOffsetY(-distanceFromDestination)
    oldestNotification.slide:PlayFromStart()
end

local function NotificationFactory(objectPool, objectKey)
    local notification = WM:CreateControlFromVirtual('BearMinimum_NotificationTemplateControl', BearMinimum_Notifications, 'BearMinimum_NotificationTemplateControl', objectPool:GetNextControlId())
    local timeline = AM:CreateTimelineFromVirtual('BearMinimum_NotificationAnimations', notification)
    local slide = AM:CreateTimelineFromVirtual('BearMinimum_NotificationSlide', notification)

    -- Auto release object handler
    timeline:SetHandler('OnStop', function()
        table.remove(activeNotifications, 1)
        BM.notificationPool:ReleaseObject(notification.key)

        if #activeNotifications > 0 then TransitionActiveNotifications() end
    end)

    notification.timeline = timeline
    notification.slide = slide

    return notification
end

local function AlertFactory(objectPool, objectKey)
    local alert = WM:CreateControlFromVirtual('BearMinimum_AlertTemplateControl', BearMinimum_Alerts, 'BearMinimum_AlertTemplateControl', objectPool:GetNextControlId())
    local colour = alert:GetNamedChild('_Colour')
    local timeline = AM:CreateTimelineFromVirtual('BearMinimum_AlertAnimation', colour)

    -- Auto release object handler
    timeline:SetHandler('OnStop', function() BM.alertPool:ReleaseObject(alert.key) end)

    colour.timeline = timeline

    return alert
end

local function OnCombatStateChanged(eventCode, inCombat)
    -- Player's combat state has changed
    if isPlayerInCombat ~= inCombat then
        -- Player has entered combat
        if inCombat then
            isPlayerInCombat = true
            -- Max health is used to identify bosses language independent
            local currentHealth, maxHealth = GetUnitPower('boss1', POWERTYPE_HEALTH)

            BearMinimum_StatusPanel:SetHidden(false)
            BM.callbackManager:FireCallbacks('OnCombatStateChanged', isPlayerInCombat, maxHealth)
        -- Player has potentially left combat, react later to ensure combat state change isn't false
        else
            zo_callLater(function()
                if not IsUnitInCombat('player') then
                    isPlayerInCombat = false

                    BearMinimum_StatusPanel:SetHidden(true)
                    BM.callbackManager:FireCallbacks('OnCombatStateChanged', isPlayerInCombat)
                end
            end, 3000)
        end
    end
end

local function OnPlayerActivated(eventCode, initial)
    BM.statusPanelPool:ReleaseAllObjects()
    BM.notificationPool:ReleaseAllObjects()
    BM.alertPool:ReleaseAllObjects()

    local zoneId = GetUnitWorldPosition('player')
    local initFunction = zoneIds[zoneId]

    if initFunction then initFunction() end
end

local function RegisterEvents()
    EM:RegisterForEvent(BM.name, EVENT_PLAYER_COMBAT_STATE, OnCombatStateChanged)
    EM:RegisterForEvent(BM.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end

function BM:RegisterMechanicsForEvent(zoneName, mechanicTable)
    for abilityId, functionName in pairs(mechanicTable) do
        local eventNamespace = 'BearMinimum_' .. zoneName .. abilityId

        EM:RegisterForEvent(eventNamespace, EVENT_COMBAT_EVENT, functionName)
        EM:AddFilterForEvent(eventNamespace, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, abilityId)
    end
end

function BM:CreateStatusPanelControls(table)
    for abilityId, notificationText in pairs(table) do
        local object = BM.statusPanelPool:AcquireUnusedObject(abilityId)

        object.key = abilityId
        object:GetNamedChild('_Name'):SetText(notificationText)
    end
end

function BM:AddNotification(text, notificationType)
    local object, objectKey = BM.notificationPool:AcquireObject()
    local mostRecentNotification = activeNotifications[#activeNotifications]

    object.key = objectKey
    table.insert(activeNotifications, object)

    if mostRecentNotification then object:SetAnchor(TOP, mostRecentNotification, BOTTOM, 0, 100)
    else object:SetAnchor(TOP, BearMinimum_Notifications, TOP, 0, 100) end

    object:SetText(text)
    object:SetHidden(false)
    object.timeline:PlayFromStart()
end

function BM:AddAlert(text, isDodgeable, duration)
    local object, objectKey = BM.alertPool:AcquireObject()
    local name = object:GetNamedChild('_Name')
    local icon = object:GetNamedChild('_Icon')
    local reactionLine = object:GetNamedChild('_ReactionLine')
    local colour = object:GetNamedChild('_Colour')
    local sizeAnimation = colour.timeline:GetFirstAnimation()
    local numActiveAlerts = #BM.alertPool.m_Active

    object.key = objectKey
    reactionLine:SetAnchor(LEFT, icon, RIGHT, 1 + 200 * (1 - 1000 / duration))

    if numActiveAlerts > 1 then object:SetAnchor(TOPLEFT, BearMinimum_Alerts, nil, (numActiveAlerts - 1) * 250)
    else object:SetAnchor(TOPLEFT, BearMinimum_Alerts) end

    if isDodgeable then
        icon:SetTexture('esoui/art/icons/ability_armor_002.dds')
        colour:SetCenterColor(unpack(BM.sv.alertDodgeColour))
    else
        icon:SetTexture('esoui/art/icons/ability_1handed_004.dds')
        colour:SetCenterColor(unpack(BM.sv.alertBlockColour))
    end

    name:SetText(text)
    sizeAnimation:SetDuration(duration)
    object:SetHidden(false)
    colour.timeline:PlayFromStart()
end

local function OnAddonLoaded(eventCode, addonName)
    if addonName == BM.name then
        EM:UnregisterForEvent(BM.name, eventCode)

        BM.sv = ZO_SavedVars:NewAccountWide(BM.svName, BM.svVersion, nil, BM.defaults)
        if not BM.sv.isAccountWide then BM.sv = ZO_SavedVars:NewCharacterIdSettings(BM.svName, BM.svVersion, nil, BM.defaults) end

        BM.callbackManager = ZO_CallbackObject:New()

        BM.statusPanelPool = ZO_ObjectPool:New(StatusPanelFactory, Reset)
        BM.statusPanelPool.AcquireUnusedObject = AcquireUnusedObject

        BM.notificationPool = ZO_ObjectPool:New(NotificationFactory, Reset)

        BM.alertPool = ZO_ObjectPool:New(AlertFactory, Reset)

        RegisterEvents()

        BM:BuildMenu()
    end
end

EM:RegisterForEvent(BM.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)