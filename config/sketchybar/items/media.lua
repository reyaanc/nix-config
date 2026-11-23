local colors = require("colors")
local icons = require("icons")

local music_width = 255
local title_width = music_width - 30

sbar.add("event", "spotify_change", "com.spotify.client.PlaybackStateChanged")
sbar.add("event", "spotify_scroll")

local progress = sbar.add("slider", "spotify.progress", music_width, {
  position = "e",
  drawing = false,
  width = 0,
  y_offset = -14,
  icon = { drawing = false },
  label = { drawing = false },
  slider = { background = { height = 2, color = colors.muted } },
})

local icon = sbar.add("item", "spotify.icon", {
  position = "e",
  drawing = false,
  icon = { string = icons.media.play },
  label = { drawing = false },
})

local title = sbar.add("item", "spotify", {
  position = "e",
  drawing = false,
  updates = true,
  icon = { drawing = false },
  label = {
    width = title_width,
    max_chars = title_width * 10 // 78,
    scroll_duration = title_width * 60 // 40,
    padding_left = 0,
    padding_right = 0,
  },
})

local status_script = [[osascript \
  -e 'if application "Spotify" is running then' \
  -e 'tell application "Spotify"' \
  -e 'if player state is not stopped then return (player state as text) & "|" & (player position * 1000 div 1) & "|" & (duration of current track) & "|" & (name of current track) & " — " & (artist of current track)' \
  -e 'end tell' \
  -e 'end if']]

local playback

local function percentage(position, duration)
  return position * 100 // math.max(duration, 1)
end

local function query()
  sbar.exec(status_script, function(status)
    local state, position, duration, track = status:match("^(%a+)|(%d+)|(%d+)|(.-)%s*$")
    position, duration = tonumber(position), tonumber(duration)

    if state == "playing" then
      title:set({ drawing = true, update_freq = 5, label = { string = track, color = colors.subtext } })
      icon:set({ drawing = true, icon = { string = icons.media.play, font = { size = 14 }, color = colors.blue } })
      progress:set({ slider = { highlight_color = colors.blue } })
    elseif state == "paused" then
      title:set({ drawing = true, update_freq = 0, label = { string = track, color = colors.grey } })
      icon:set({ drawing = true, icon = { string = icons.media.pause, font = { size = 13 }, color = colors.grey } })
      progress:set({ slider = { highlight_color = colors.grey } })
    else
      playback = nil
      title:set({ drawing = false, update_freq = 0 })
      icon:set({ drawing = false })
      progress:set({ drawing = false })
      return
    end

    playback = { read_at = os.time(), position = position, duration = duration }
    progress:set({ drawing = true, slider = { percentage = percentage(position, duration) } })
  end)
end

local function click(env)
  local command = env.BUTTON == "right" and "next track" or "playpause"
  sbar.exec("osascript -e 'tell application \"Spotify\" to " .. command .. "'", query)
end

-- Spotify posts no notification for seeks or for time passing, so between reads the bar extrapolates from the last one,
-- asking Spotify again only every 30s to pick up a seek.
title:subscribe("routine", function()
  if playback and os.time() - playback.read_at < 30 then
    local position = (os.time() - playback.read_at) * 1000 + playback.position
    sbar.animate("linear", 30, function()
      progress:set({ slider = { percentage = percentage(position, playback.duration) } })
    end)
  else
    query()
  end
end)

title:subscribe({ "forced", "spotify_change" }, query)
title:subscribe("mouse.clicked", click)
icon:subscribe("mouse.clicked", click)

-- Sketchybar only starts a scroll on an update right after the item's script ran; spotify_scroll is that update.
title:subscribe("mouse.entered", function()
  title:set({ scroll_texts = true })
  sbar.trigger("spotify_scroll")
end)
title:subscribe("mouse.exited", function()
  title:set({ scroll_texts = false })
end)
title:subscribe("spotify_scroll", function() end)
