local colors = require("colors")

sbar.add("event", "aerospace_mode_change")

local mode = sbar.add("item", "mode", {
  drawing = false,
  updates = true,
  icon = { drawing = false },
  label = { string = "SERVICE", color = colors.black, padding_left = 10, padding_right = 10 },
  background = { color = colors.yellow, height = 32 },
})

mode:subscribe("aerospace_mode_change", function(env)
  mode:set({ drawing = env.MODE ~= nil and env.MODE ~= "" and env.MODE ~= "main" })
end)
