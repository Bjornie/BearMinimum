BearStrength.Sunspire = {
    name = "BearStrengthSunspire",

    Default = {},
}

local BS = BearStrength
local S = BS.Sunspire

local breathTimerControl = BearStrengthBreath:GetNamedChild("Timer")

local beamTimerControl = BearStrengthBeam:GetNamedChild("Timer")
local tombTimerControl = BearStengthTomb:GetNamedChild("Timer")

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

-- Triggered when someone enters and leaves a Frozen Tomb
local function SecondIceReady(_, changeType)
    if changeType == EFFECT_RESULT_FADED and BearStengthTomb:GetNamedChild("PersonB"):GetText() == "Tomb B: Wait" then
        BearStengthTomb:GetNamedChild("PersonB"):SetText("Tomb B: Safe")
    elseif changeType == EFFECT_RESULT_GAINED and BearStrengthTomb:GetNamedChild("PersonB"):GetText() == "Tomb B: Safe" then
        BearStengthTomb:SetHidden(true)
        EVENT_MANAGER:UnregisterForEvent(S.name .. "IceB")
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

    --[[
    currentIce = currentIce % 3 + 1

    BearStengthTomb:SetHidden(false)
    BearStengthTomb:GetNamedChild("Label"):SetText("Frozen Tomb " .. currentIce .. ": ")
    BearStengthTomb:GetNamedChild("Timer"):SetText("Spawning")
    BearStengthTomb:GetNamedChild("PersonATimer"):SetText("Safe")
    BearStengthTomb:GetNamedChild("PersonBTimer"):SetText("Wait")
    zo_callLater(function()
        tombTimerControl:SetText("10.0")
        EVENT_MANAGER:RegisterForUpdate(S.name .. "Tomb", 100, TombCountdown)
        EVENT_MANAGER:RegisterForEvent(S.name .. "IceB", EVENT_EFFECT_CHANGED, SecondIceReady)
        EVENT_MANAGER:AddFilterForEvent(S.name .. "IceB", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, frozenPrison)
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