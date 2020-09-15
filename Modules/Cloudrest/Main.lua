BearStrength.Cloudrest = {
  name = "BearStrengthCloudrest",

  Default = {},
}

local BS = BearStrength
local C = BS.Cloudrest

local function RegisterEvents()
    for k, v in pairs(C.Data) do
        EVENT_MANAGER:RegisterForEvent(C.name .. k, EVENT_COMBAT_EVENT, v)
        EVENT_MANAGER:AddFilterForEvent(C.name .. k, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, k)
    end
end

function C.Initialise()
    if BS.SavedVariables.isAccountWide then C.SavedVariables = ZO_SavedVars:NewAccountWide(BS.svName, BS.svVersion, "Cloudrest", C.Default)
    else C.SavedVariables = ZO_SavedVars:NewCharacterIdSettings(BS.svName, BS.svVersion, "Cloudrest", C.Default) end

    RegisterEvents()
end