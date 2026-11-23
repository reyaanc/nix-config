local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local soon_minutes = 10
local calendar_url = "https://calendar.google.com/calendar/r/day"
local notch_width = 200
local reserved_width = 54
local min_label_chars = 10
local max_label_chars = 36
local scroll_speed = 40

sbar.add("event", "agenda_scroll")

local agenda = sbar.add("item", "agenda", {
  position = "q",
  drawing = false,
  updates = true,
  update_freq = 60,
  padding_right = 10,
  icon = { string = icons.calendar },
})

-- A query answered mid-reload, or naming a display the other doesn't list, must not stop the label updating.
local function label_room()
  local displays, spaces = sbar.query("displays"), sbar.query("spaces")
  if type(displays) ~= "table" or type(spaces) ~= "table" or not spaces.bounding_rects then return 0 end

  local frames = {}
  for _, display in ipairs(displays) do
    frames["display-" .. display["arrangement-id"]] = display.frame
  end

  local room
  for key, rect in pairs(spaces.bounding_rects) do
    local frame = frames[key]
    if frame then
      local free = frame.x + (frame.w - notch_width) / 2 - rect.origin[1] - rect.size[1]
      room = room and math.min(room, free) or free
    end
  end
  return room and math.floor((room - reserved_width) / settings.char_width) or 0
end

local function update()
  sbar.exec("$CONFIG_DIR/helpers/agenda.py", function(meeting)
    local room = label_room()
    if type(meeting) ~= "table" or room < min_label_chars then
      agenda:set({ drawing = false })
      return
    end

    local when, color = "now", colors.blue
    if meeting.minutes > 0 then
      when = "in " .. math.floor(meeting.minutes + 0.999) .. "m"
      color = meeting.minutes <= soon_minutes and colors.yellow or colors.subtext
    end
    local target = meeting.location:find("^http") and meeting.location or calendar_url
    local chars = math.min(room, max_label_chars)

    agenda:set({
      drawing = true,
      icon = { color = color },
      label = {
        string = when .. "  " .. meeting.title,
        color = color,
        max_chars = chars,
        scroll_duration = math.floor(chars * settings.char_width * 60 / scroll_speed),
      },
      click_script = "open '" .. target .. "'",
    })
  end)
end

agenda:subscribe({ "forced", "routine", "system_woke", "workspaces_change" }, update)

-- Sketchybar only starts a scroll on an update right after the item's script ran; agenda_scroll is that update.
agenda:subscribe("mouse.entered", function()
  agenda:set({ scroll_texts = true })
  sbar.trigger("agenda_scroll")
end)
agenda:subscribe("mouse.exited", function()
  agenda:set({ scroll_texts = false })
end)
agenda:subscribe("agenda_scroll", function() end)
