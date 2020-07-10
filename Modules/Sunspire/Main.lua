BearStrength.Sunspire = {
  Default = {},
}

local BS = BearStrength
local S = BS.Sunspire

local function BeamCountdown()
  BearStrengthSunspireBeam:SetHidden(false)
  
end

function S.Initialise()
  if BS.SavedVariables.isAccountWide then
    S.SavedVariables = ZO_SavedVars:NewAccountWide(BS.svName, BS.svVersion, "Sunspire", S.Default)
  else
    S.SavedVariables = ZO_SavedVars:NewCharacterIdSettings(BS.svName, BS.svVersion, "Sunspire", S.Default)
  end
end

-- Lokke Take Flight: 122820, 122821, 122822