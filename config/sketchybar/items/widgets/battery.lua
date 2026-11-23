local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

sbar.add("event", "power_update")

local battery = sbar.add("item", "widgets.battery", {
  position = "right",
  icon = { font = { size = 18.0 }, width = 42, align = "left", padding_left = 12, padding_right = 8 },
  label = { font = { family = settings.font.numbers }, width = 44, align = "left", padding_left = 0, padding_right = 12 },
  background = { color = colors.with_alpha(colors.bg2, 0.5), height = 32 },
  popup = { y_offset = 4 },
})

local details = sbar.add("item", {
  position = "popup." .. battery.name,
  icon = { drawing = false },
  label = { color = colors.subtext, padding_left = 12, padding_right = 12 },
  background = { height = 30 },
})

local function describe(env)
  local minutes = tonumber(env.remaining)
  local time = minutes >= 0 and string.format("%d:%02d", minutes // 60, minutes % 60) or nil
  if env.charging == "true" then
    return "Charging" .. (time and ", full in " .. time or "")
  elseif env.ac == "true" then
    return "Plugged in, not charging"
  end
  return "On battery" .. (time and ", " .. time .. " left" or "")
end

battery:subscribe("forced", function()
  sbar.exec("killall power_source >/dev/null; $CONFIG_DIR/helpers/event_providers/power_source/bin/power_source power_update")
end)

battery:subscribe("power_update", function(env)
  local percentage = tonumber(env.percentage)

  local icon = icons.battery._0
  if percentage >= 90 then
    icon = icons.battery._100
  elseif percentage >= 60 then
    icon = icons.battery._75
  elseif percentage >= 30 then
    icon = icons.battery._50
  elseif percentage >= 10 then
    icon = icons.battery._25
  end

  -- The bolt is narrower than the battery glyphs, so it's nudged right to sit centred where they do.
  local icon_pad = 12
  if env.ac == "true" then
    icon, icon_pad = icons.battery.charging, 15
  end

  local icon_color, label_color = colors.green, colors.subtext
  if percentage <= 10 then
    icon_color, label_color = colors.red, colors.red
  elseif percentage <= 20 then
    icon_color, label_color = colors.orange, colors.orange
  elseif percentage <= 50 then
    icon_color = colors.dull_green
  end

  battery:set({
    icon = { string = icon, padding_left = icon_pad, color = icon_color },
    label = { string = percentage .. "%", color = label_color },
  })
  details:set({ label = describe(env) })
end)

battery:subscribe("mouse.entered", function()
  battery:set({ popup = { drawing = true } })
end)

battery:subscribe("mouse.exited", function()
  battery:set({ popup = { drawing = false } })
end)
