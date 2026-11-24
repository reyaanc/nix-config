local black = 0xff0d0c0c
local green = 0xff8a9a7b
local blue = 0xff8ba4b0
local cyan = 0xff8ea4a2
local yellow = 0xffc4b28a
local orange = 0xffc49c80
local magenta = 0xffa292a3

return {
  black = black,
  white = 0xffc5c9c5,
  red = 0xffc4746e,
  green = green,
  blue = blue,
  cyan = cyan,
  yellow = yellow,
  orange = orange,
  magenta = magenta,
  grey = 0xffb5b7b0,
  muted = 0xffacada4,
  subtext = 0xffc8c093,
  dull_green = 0xff929d84,
  transparent = 0x00000000,

  bar = { bg = 0x990d0c0c },
  popup = { bg = black, border = 0xff575652 },
  bg1 = 0xff21201f,
  bg2 = 0xff373533,
  bg3 = 0xff575652,

  with_alpha = function(color, alpha)
    if alpha > 1.0 or alpha < 0.0 then return color end
    return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
  end,
}
