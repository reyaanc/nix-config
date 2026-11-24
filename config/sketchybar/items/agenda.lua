local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local meeting_window_minutes = 60
local soon_minutes = 10
local refresh_seconds = 600
local retry_seconds = 120
local calendar_url = "https://calendar.google.com/calendar/r/day"
local max_label_chars = 36
local scroll_speed = 40

sbar.add("event", "agenda_scroll")

local agenda = sbar.add("item", "agenda", {
  position = "e",
  drawing = false,
  updates = true,
  update_freq = 60,
  padding_right = 10,
  icon = { string = icons.calendar },
})

local events = {}
local fetching, next_fetch = false, 0

local function next_meeting(now)
  for _, event in ipairs(events) do
    if event["end"] > now then
      local minutes = (event.start - now) / 60
      if minutes <= meeting_window_minutes then return event, minutes end
      return nil
    end
  end
end

local function draw()
  local meeting, minutes = next_meeting(os.time())
  if not meeting then
    agenda:set({ drawing = false })
    return
  end

  local when, color = "now", colors.blue
  if minutes > 0 then
    when = "in " .. math.ceil(minutes) .. "m"
    color = minutes <= soon_minutes and colors.yellow or colors.subtext
  end
  agenda:set({
    drawing = true,
    icon = { color = color },
    label = {
      string = when .. "  " .. meeting.title,
      color = color,
      max_chars = max_label_chars,
      scroll_duration = math.floor(max_label_chars * settings.char_width * 60 / scroll_speed),
    },
    click_script = "open '" .. (meeting.url ~= "" and meeting.url or calendar_url) .. "'",
  })
end

-- Offline, a fetch fails after its timeout, so the next try waits a couple of minutes rather than the full refresh.
local function fetch()
  if fetching then return end
  fetching = true
  sbar.exec("$CONFIG_DIR/helpers/agenda.py", function(result, exit_code)
    fetching = false
    if exit_code == 0 and type(result) == "table" then
      events = result
      next_fetch = os.time() + refresh_seconds
    else
      next_fetch = os.time() + retry_seconds
    end
    draw()
  end)
end

-- The last fetch is drawn straight away, so a slow or offline start still shows the next meeting.
agenda:subscribe("forced", function()
  sbar.exec("cat ~/.local/share/sketchybar/events.json", function(cached)
    if type(cached) == "table" then
      events = cached
      draw()
    end
    fetch()
  end)
end)

agenda:subscribe("routine", function()
  if os.time() >= next_fetch then fetch() end
  draw()
end)

agenda:subscribe("system_woke", fetch)

-- Sketchybar only starts a scroll on an update right after the item's script ran; agenda_scroll is that update.
agenda:subscribe("mouse.entered", function()
  agenda:set({ scroll_texts = true })
  sbar.trigger("agenda_scroll")
end)
agenda:subscribe("mouse.exited", function()
  agenda:set({ scroll_texts = false })
end)
agenda:subscribe("agenda_scroll", function() end)
