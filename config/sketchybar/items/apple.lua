local colors = require("colors")
local icons = require("icons")

sbar.add("item", "apple", {
  icon = {
    string = icons.apple,
    font = { size = 16.0 },
    color = colors.subtext,
    width = 44,
    align = "center",
    padding_left = 0,
    padding_right = 0,
  },
  label = { drawing = false },
  background = { color = colors.transparent, height = 32 },
  click_script = "open raycast://extensions/raycast/navigation/search-menu-items",
})
