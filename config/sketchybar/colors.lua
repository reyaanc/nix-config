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

  -- Firefox profiles are told apart by avatar colour; red is left out since a red dot reads as an unread badge.
  profile = {
    heart = magenta,
    star = yellow,
    flower = green,
    book = blue,
    briefcase = orange,
    shopping = cyan,
  },

  brand = {
    Slack = 0xff611f69,
    Discord = 0xff5865f2,
    Ghostty = 0xff3551f3,
    Herdr = 0xff7aa2f7,
    ["Google Chrome"] = 0xfffbbc04,
    Firefox = 0xffff7139,
    Finder = 0xff1e9bf0,
    ["1Password"] = 0xff0572ec,
    Spotify = 0xff1db954,
    Todoist = 0xffe44332,
    Thunderbird = 0xff0a84ff,
    Postman = 0xffff6c37,
    Preview = 0xff5ac8fa,
    ["zoom.us"] = 0xff0b5cff,
    ["System Settings"] = 0xff8e8e93,
  },

  with_alpha = function(color, alpha)
    if alpha > 1.0 or alpha < 0.0 then return color end
    return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
  end,

  mix = function(a, b, p)
    local function channel(shift)
      return (((a >> shift) & 0xff) * (100 - p) + ((b >> shift) & 0xff) * p) // 100 << shift
    end
    return 0xff000000 | channel(16) | channel(8) | channel(0)
  end,
}
