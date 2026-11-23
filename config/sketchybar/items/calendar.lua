local colors = require("colors")
local settings = require("settings")

local clock = sbar.add("item", "clock", {
  position = "right",
  update_freq = 1,
  icon = { drawing = false },
  label = { font = { family = settings.font.numbers }, color = colors.white, padding_left = 14, padding_right = 24 },
  background = { color = colors.with_alpha(colors.bg3, 0.5), height = 32 },
  click_script = "open -a Calendar",
})

clock:subscribe({ "forced", "routine" }, function()
  clock:set({ label = os.date("%a, %d %b  %H:%M:%S") })
end)
