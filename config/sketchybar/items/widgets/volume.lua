local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

sbar.add("event", "audio_update")

local volume = sbar.add("item", "widgets.volume", {
  position = "right",
  icon = { width = 36, align = "left", color = colors.magenta, padding_left = 12, padding_right = 8 },
  label = {
    font = { family = settings.font.numbers },
    width = 44,
    align = "left",
    color = colors.subtext,
    padding_left = 0,
    padding_right = 12,
  },
  background = { color = colors.with_alpha(colors.bg1, 0.5), height = 32 },
})

volume:subscribe("forced", function()
  sbar.exec("killall audio_output >/dev/null; $CONFIG_DIR/helpers/event_providers/audio_output/bin/audio_output audio_update")
end)

volume:subscribe("audio_update", function(env)
  local level = tonumber(env.volume)

  local icon, label = icons.volume._0, "mute"
  if env.muted ~= "true" then
    label = level .. "%"
    if level >= 50 then
      icon = icons.volume._100
    elseif level > 0 then
      icon = icons.volume._50
    end
  end
  if env.transport == "bluetooth" then icon = icons.volume.bluetooth end

  volume:set({ icon = icon, label = label })
end)

volume:subscribe("mouse.scrolled", function(env)
  sbar.exec("$CONFIG_DIR/helpers/volume/bin/volume step " .. env.INFO.delta * 2)
end)

volume:subscribe("mouse.clicked", function()
  sbar.exec("$CONFIG_DIR/helpers/volume/bin/volume mute")
end)
