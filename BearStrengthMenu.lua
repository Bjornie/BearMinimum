local BS = BearStrength

function BS.BuildMenu()
  local PanelData = {
    type = "panel",
    name = "Bear Strength",
    displayname = "Bear Strength",
    author = "|c00BFFFBjørn|r",
    version = BS.version,
    registerForRefresh = true,
  }

  local OptionsTable = {
    {
      type = "header",
      name = "|cFFFACDGeneral|r",
    },
    {
      type = "checkbox",
      name = "Account-Wide Settings",
      getFunc = function() return BearStrengthSV.Default[GetDisplayName()]["$AccountWide"].isAccountWide end,
      setFunc = function(value) BearStrengthSV.Default[GetDisplayName()]["$AccountWide"].isAccountWide = value end,
      requiresReload = true,
    },
  }

  LibAddonMenu2:RegisterAddonPanel(BS.name, PanelData)
  LibAddonMenu2:RegisterOptionControls(BS.name, OptionsTable)
end