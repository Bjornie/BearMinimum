BearStrength = {
  name = "BearStrength",
  version = "0.1.1",
  svName = "BearStrengthSV",
  svVersion = 1,

  Default = {
    isFoodEnabled = true,
    FoodReminderInterval = 60,
    FoodReminderThreshold = 10,
  },
}

local BS = BearStrength

local noFood = true

local function Feared(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
  BearStrengthFeared:SetHidden(false)
  d(targetType)
end

local function Knockback(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
  BearStrengthKnockback:SetHidden(false)
  d(targetType)
end

local function Rooted(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
  BearStrengthRooted:SetHidden(false)
  d(targetType)
end

local function Silenced(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
  BearStrengthSilenced:SetHidden(false)
  d(targetType)
end

local function Stunned(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
  BearStrengthStunned:SetHidden(false)
  d(targetType)
end
-- number eventCode, number ActionResult result, boolean isError, string abilityName, number abilityGraphic, number ActionSlotType abilityActionSlotType, string sourceName, number CombatUnitType sourceType, string targetName, number CombatUnitType targetType, number hitValue, number CombatMechanicType powerType, number DamageType damageType, boolean log, number sourceUnitId, number targetUnitId, number abilityId, number overflow
local function InitiateCCEvents()
  EVENT_MANAGER:RegisterForEvent(BS.name .. "Feared", EVENT_COMBAT_EVENT, Feared)
  EVENT_MANAGER:AddFilterForEvent(BS.name .. "Feared", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_FEARED)

  EVENT_MANAGER:RegisterForEvent(BS.name .. "Knockback", EVENT_COMBAT_EVENT, Knockback)
  EVENT_MANAGER:AddFilterForEvent(BS.name .. "Knockback", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_KNOCKBACK)

  EVENT_MANAGER:RegisterForEvent(BS.name .. "Rooted", EVENT_COMBAT_EVENT, Rooted)
  EVENT_MANAGER:AddFilterForEvent(BS.name .. "Rooted", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_ROOTED)

  EVENT_MANAGER:RegisterForEvent(BS.name .. "Silenced", EVENT_COMBAT_EVENT, Silenced)
  EVENT_MANAGER:AddFilterForEvent(BS.name .. "Silenced", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_SILENCED)

  EVENT_MANAGER:RegisterForEvent(BS.name .. "Stunned", EVENT_COMBAT_EVENT, Stunned)
  EVENT_MANAGER:AddFilterForEvent(BS.name .. "Stunned", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_STUNNED)
end

-- Lure Allure - 107748
local function FoodReminder()
  noFood = true

  if GetNumBuffs("player") > 0 then
    for i = 1, GetNumBuffs("player") do
      local _, _, finish, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo("player", i)
      if abilityId == 107748 then
        noFood = false

        local buffFoodRemaining = finish - GetGameTimeMilliseconds() / 1000
        local formattedTime = ZO_FormatTime(buffFoodRemaining, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_SECONDS)

        if buffFoodRemaining <= (BS.SavedVariables.FoodReminderThreshold * 60) then
          d("|c00BFFFYour food buff is expiring in: |r" .. formattedTime)
        end
      end
    end
  end

  if noFood then d("|cFF0000You have no food buff!|r") end
end

local function Initialise()
  BS.SavedVariables = ZO_SavedVars:NewAccountWide(BS.svName, BS.svVersion, nil, BS.Default)

  --InitiateCCEvents()
  BS.BuildMenu()

  EVENT_MANAGER:RegisterForUpdate(BS.name .. "Food", BS.SavedVariables.FoodReminderInterval * 1000, FoodReminder)
end

local function OnAddonLoaded(_, addonName)
  if addonName == BS.name then
    EVENT_MANAGER:UnregisterForEvent(BS.name, EVENT_ADD_ON_LOADED)
    Initialise()
  end
end

EVENT_MANAGER:RegisterForEvent(BS.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)