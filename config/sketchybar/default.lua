local colors = require("colors")
local settings = require("settings")

sbar.default({
  updates = "when_shown",
  icon = {
    font = {
      family = settings.font.text,
      style = settings.font.style_map["Bold"],
      size = 14.0,
    },
    color = colors.white,
    padding_left = 6,
    padding_right = 4,
  },
  label = {
    font = {
      family = settings.font.text,
      style = settings.font.style_map["Bold"],
      size = 13.0,
      typographical_width = true,
    },
    color = colors.white,
    padding_left = 4,
    padding_right = 6,
  },
  popup = {
    align = "center",
    background = {
      border_width = 1,
      corner_radius = 8,
      border_color = colors.popup.border,
      color = colors.popup.bg,
    },
  },
})
