local colors = require("colors")

-- Hidden until spaces first reads OmniWM, which starts after the bar at login; until then the bar would draw half-filled.
sbar.bar({
  position = "top",
  height = 32,
  color = colors.bar.bg,
  blur_radius = 30,
  padding_left = 0,
  padding_right = 0,
  hidden = true,
})

-- If OmniWM never starts or its IPC is off, spaces never draws, so the bar is shown anyway after a grace period
sbar.delay(20, function()
  sbar.bar({ hidden = false })
end)
