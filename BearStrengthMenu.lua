local BS = BearStrength

function BS.BuildMenu()
  local PanelData = {
    type = "panel",
    name = "Bear Strength",
    displayname = "Bear Strength",
    author = "|c00BFFFBjørnTheBurr|r",
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
      name = "Food Reminder",
      width = "half",
      getFunc = function() return BS.SavedVariables.isFoodEnabled end,
      setFunc = function(value) BS.SavedVariables.isFoodEnabled = value end,
    },
    {
      type = "slider",
      name = "Reminder Interval (seconds)",
      min = 1,
      max = 60,
      step = 1,
      default = 60,
      getFunc = function() return BS.SavedVariables.FoodReminderInterval end,
      setFunc = function(value) BS.SavedVariables.FoodReminderInterval = value end,
      requiresReload = true,
    },
    {
      type = "slider",
      name = "Reminder Threshold (minutes)",
      min = 1,
      max = 120,
      step = 1,
      default = 10,
      getFunc = function() return BS.SavedVariables.FoodReminderThreshold end,
      setFunc = function(value) BS.SavedVariables.FoodReminderThreshold = value end,
    }
  }

  LibAddonMenu2:RegisterAddonPanel(BS.name, PanelData)
  LibAddonMenu2:RegisterOptionControls(BS.name, OptionsTable)
end