BearStrength.Sunspire = {
    name = "BearStrengthSunspire",

    Default = {},
}

local BS = BearStrength
local S = BS.Sunspire

local breathTimerControl = BearStrengthBreath:GetNamedChild("Timer")

local beamTimerControl = BearStrengthBeam:GetNamedChild("Timer")
local tombTimerControl = BearStengthTomb:GetNamedChild("Timer")
local personATimerControl = BearStrengthTomb:GetNamedChild("PersonATimer")
local personBTimerControl = BearStrengthTomb:GetNamedChild("PersonBTimer")

local currentIce = 0
local frozenPrison = 116025

local function BreathCountdown()
    if breathTimerControl:GetText() ~= "0.0" then breathTimerControl:SetText(string.format("%.1f", tonumber(breathTimerControl:GetText()) - 0.1)) end

    if breathTimerControl:GetText() == "0.0" then
        BearStrengthBreath:SetHidden(true)
        EVENT_MANAGER:UnregisterForUpdate(S.name .. "Breath")
    end
end

local function Breath(_, result, _, abilityName, _, _, _, _, _, _, _, _, _, _, _, _, abilityId)
    d("----------")
    d("result: " .. result)
    d("abilityName: " .. abilityName)
    d("abilityId: " .. abilityId)

    --[[
    BearStrengthBreath:SetHidden(false)
    BearStrengthBreath:GetNamedChild("Timer"):SetText("4.2")

    EVENT_MANAGER:RegisterForUpdate(S.name .. "Breath", 100, BreathCountdown)
    --]]
end

-- Timer for when Frozen Prison will explode
local function PrisonCountdown()
    if personATimerControl:GetText() ~= "0.0" then personATimerControl:SetText(string.format("%.1f", tonumber(personATimerControl:GetText()) - 0.1))
    elseif personBTimerControl:GetText() ~= "0.0" then personBTimerControl:SetText(string.format("%.1f", tonumber(personBTimerControl:GetText()) - 0.1)) end

    if personATimerControl:GetText() == "0.0" or personBTimerControl:GetText() == "0.0" then BearStrengthTomb:SetHidden(true) end
end

-- endtime == seconds or gametime? Possibly endTime - beginTime
-- Triggered when someone enters and leaves a Frozen Tomb
local function FrozenPrison(_, changeType, _, _, _, beginTime, endTime)
    -- Person A enters a Frozen Tomb
    if changeType == EFFECT_RESULT_GAINED and personATimerControl:GetText() == "Safe" then
        personATimerControl:SetText(endTime)
        EVENT_MANAGER:RegisterForUpdate(S.name .. "PrisonCountdown", 100, PrisonCountdown)
    -- Person A leaves the Frozen Tomb
    elseif changeType == EFFECT_RESULT_FADED and personBTimerControl:GetText() == "Wait" then
        BearStrengthTomb:GetNamedChild("PersonALabel"):SetColor(150, 150, 150, 0.7)
        personATimerControl:SetText("")
        personBTimerControl:SetText("Safe")
        EVENT_MANAGER:UnregisterForUpdate(S.name .. "PrisonCountdown")
    -- Person B enters a Frozen Tomb
    elseif changeType == EFFECT_RESULT_GAINED and personBTimerControl:GetText() == "Safe" then
        personBTimerControl:SetText(endTime)
        EVENT_MANAGER:RegisterForUpdate(S.name .. "PrisonCountdown", 100, PrisonCountdown)
    -- Person B leaves the Frozen Tomb
    else
        BearStrengthTomb:SetHidden(true)
        EVENT_MANAGER:UnregisterForUpdate(S.name .. "PrisonCountdown")
    end
end

-- Timer for when Frozen Tombs will explode
local function TombCountdown()
    if tombTimerControl:GetText() ~= "0.0" then tombTimerControl:SetText(string.format("%.1f", tonumber(tombTimerControl:GetText()) - 0.1)) end

    if tombTimerControl:GetText() == "0.0" then
        BearStengthTomb:SetHidden(true)
        EVENT_MANAGER:UnregisterForUpdate(S.name .. "Tomb")
    end
end

-- Triggered when Frozen Tombs starts
local function FrozenTomb(_, result, _, abilityName, _, _, _, _, _, _, _, _, _, _, _, _, abilityId)
    d("----------")
    d("result: " .. result)
    d("abilityName: " .. abilityName)
    d("abilityId: " .. abilityId)

    ---[[
    currentIce = currentIce % 3 + 1

    BearStrengthTomb:SetHidden(false)
    BearStrengthTomb:GetNamedChild("Label"):SetText("Frozen Tomb " .. currentIce .. ": ")
    tombTimerControl:SetText("Spawning")
    personATimerControl:SetText("Safe")
    personBTimerControl:SetText("Wait")
    zo_callLater(function()
        tombTimerControl:SetText("10.0")
        EVENT_MANAGER:RegisterForUpdate(S.name .. "TombCountdown", 100, TombCountdown)
        EVENT_MANAGER:RegisterForEvent(S.name .. "FrozenPrison", EVENT_EFFECT_CHANGED, FrozenPrison)
        EVENT_MANAGER:AddFilterForEvent(S.name .. "FrozenPrison", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, frozenPrison)
    end, 4000)
    --]]
end

-- Timer for beam during trash phases
local function BeamCountdown()
    if beamTimerControl:GetText() ~= "0" then beamTimerControl:SetText(string.format("%d", tonumber(beamTimerControl:GetText()) - 1)) end

    if beamTimerControl:GetText() == "0" then
        beamTimerControl:SetText("Now")
        zo_callLater(function() BearStrengthBeam:SetHidden(true) end, 10000)
        EVENT_MANAGER:UnregisterForUpdate(S.name .. "Beam")
    end
end

-- Triggered when Lokkestiiz takes flight
local function Gravechill(_, result, _, abilityName, _, _, _, _, _, _, _, _, _, _, _, _, abilityId)
    d("----------")
    d("result: " .. result)
    d("abilityName: " .. abilityName)
    d("abilityId: " .. abilityId)

    --[[
    local beamTimer

    -- First trash phase
    if abilityId == 122820 then beamTimer = 40
    -- Second trash phase
    elseif abilityId == 122821 then beamTimer = 10
    -- Third trash phase
    else beamTimer = 34 end

    BearStrengthBeam:SetHidden(false)
    BearStrengthBeam:GetNamedChild("Timer"):SetText(beamTimer)

    EVENT_MANAGER:RegisterForUpdate(S.name .. "Beam", 1000, BeamCountdown)
    --]]
end

local function RegisterEvents()
    for k, v in pairs(S.Data) do
        EVENT_MANAGER:RegisterForEvent(S.name .. k, EVENT_COMBAT_EVENT, v)
        EVENT_MANAGER:AddFilterForEvent(S.name .. k, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, k)
    end
end

function S.Initialise()
    if BS.SavedVariables.isAccountWide then S.SavedVariables = ZO_SavedVars:NewAccountWide(BS.svName, BS.svVersion, "Sunspire", S.Default)
    else S.SavedVariables = ZO_SavedVars:NewCharacterIdSettings(BS.svName, BS.svVersion, "Sunspire", S.Default) end

    RegisterEvents()
end