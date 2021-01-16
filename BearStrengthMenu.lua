local BS = BearStrength

function BS.BuildMenu()
  local panelData = {
    type = "panel",
    name = "Bear Strength",
    displayname = "Bear Strength",
    author = "|c00BFFFBjørn|r",
    version = BS.version,
    registerForRefresh = true,
  }

  local optionsTable = {
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

  LibAddonMenu2:RegisterAddonPanel(BS.name, panelData)
  LibAddonMenu2:RegisterOptionControls(BS.name, optionsTable)
end