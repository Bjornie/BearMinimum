local BS = BearStrength

function BS.BuildMenu()
  local PanelData = {}

  local OptionsTable = {}

  LibAddonMenu2:RegisterAddonPanel(BS.name, PanelData)
  LibAddonMenu2:RegisterOptionControls(BS.name, OptionsTable)
end