local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local awake_bin = os.getenv("HOME") .. "/.local/bin/awake"
local max_rows = 6
local project_chars = 10
local title_chars = 29
local row_end_padding = 12
local app_font = "sketchybar-app-font:Regular:14.0"
local glyph_font = { family = settings.font.text, style = settings.font.style_map["Bold"], size = 14.0 }

sbar.add("event", "awake_change")

-- The awake popup must touch the bar: crossing any gap between them fires mouse.exited.global and closes it.
local awake = sbar.add("item", "widgets.awake", {
  position = "right",
  padding_right = 8,
  update_freq = 30,
  icon = { string = icons.cup, width = 32, align = "center", padding_left = 0, padding_right = 0 },
  label = {
    drawing = false,
    font = { size = 7.0 },
    width = 0,
    y_offset = 5,
    padding_left = -12,
    padding_right = 12,
    color = colors.subtext,
  },
  popup = { height = 28 },
})

-- Rows are created once and only ever set: removing a popup's items destroys its window, which closes it under the cursor.
local rows, actions = {}, {}
for i = 1, max_rows + 1 do
  local row = sbar.add("item", {
    position = "popup." .. awake.name,
    icon = { width = 34, padding_left = 10, padding_right = 0 },
    label = { font = { style = settings.font.style_map["Semibold"], size = 13.0 }, padding_left = 0, padding_right = 0 },
    background = {
      height = 24,
      corner_radius = 6,
      color = colors.bg2,
      drawing = false,
      padding_left = 5,
      padding_right = 5,
    },
  })
  row:subscribe("mouse.entered", function() row:set({ background = { drawing = true } }) end)
  row:subscribe("mouse.exited", function() row:set({ background = { drawing = false } }) end)
  row:subscribe("mouse.clicked", function()
    if actions[i] then actions[i]() end
  end)
  rows[i] = row
end

local function length(text)
  return utf8.len(text) or #text
end

local function cut(text, chars)
  if length(text) <= chars then return text end
  return text:sub(1, utf8.offset(text, chars) - 1):gsub("%s+$", "") .. "…"
end

local function pad_right(text, chars)
  return text .. string.rep(" ", chars - length(text))
end

local function elapsed(since)
  local minutes = math.max(0, os.time() - since) // 60
  if minutes < 1 then return "<1m" end
  if minutes < 60 then return minutes .. "m" end
  if minutes < 1440 then return string.format("%dh%02dm", minutes // 60, minutes % 60) end
  return string.format("%dd%02dh", minutes // 1440, minutes % 1440 // 60)
end

local function parse_holds(list)
  local held = {}
  for line in list:gmatch("[^\n]+") do
    local id, label, detail, since = line:match("^([^\t]*)\t([^\t]*)\t([^\t]*)\t(%d+)")
    if id then table.insert(held, { id = id, label = label, detail = detail, since = tonumber(since) }) end
  end
  table.sort(held, function(a, b)
    if (a.id == "manual") ~= (b.id == "manual") then return b.id == "manual" end
    return a.since < b.since
  end)
  return held
end

-- Claude Code animates the glyph in front of the session title while a turn runs, so only what follows it is matched.
local function parse_windows(list)
  local found = {}
  for wid, title in list:gmatch("(%d+)|([^\n]*)") do
    found[title:match("^[^ ]* (.*)$") or title] = wid
  end
  return found
end

local function close_popup()
  awake:set({ popup = { drawing = false } })
end

local function release_manual()
  sbar.exec(awake_bin .. " release manual", function()
    sbar.trigger("awake_change")
  end)
end

local hovering = false

local function draw(held, on, found, open)
  local automatic = 0
  for _, hold in ipairs(held) do
    if hold.id ~= "manual" then automatic = automatic + 1 end
  end
  awake:set({
    icon = { color = on and colors.blue or colors.muted },
    label = { string = automatic, drawing = automatic > 0 },
  })

  local shown = { table.unpack(held, 1, max_rows) }
  local widest_label, widest_detail, widest_any, any_detail = 0, 0, 0, false
  for _, hold in ipairs(shown) do
    widest_any = math.max(widest_any, length(hold.label))
    if hold.detail ~= "" then
      any_detail = true
      widest_label = math.max(widest_label, length(hold.label))
      widest_detail = math.max(widest_detail, length(hold.detail))
    end
  end
  local label_chars = math.min(project_chars, widest_label)
  local detail_chars = math.min(title_chars, widest_detail)
  local first_chars = any_detail and label_chars + 2 + detail_chars or widest_any

  local lines = {}
  for _, hold in ipairs(shown) do
    local text
    if hold.detail ~= "" then
      text = pad_right(cut(hold.label, label_chars), label_chars) .. "  " .. pad_right(cut(hold.detail, detail_chars), detail_chars)
    else
      text = pad_right(cut(hold.label, first_chars), first_chars)
    end
    text = text .. "  " .. string.format("%5s", elapsed(hold.since))

    if hold.id:find("^claude%-") then
      local wid = found[hold.detail]
      local action = wid and function()
        close_popup()
        sbar.exec("aerospace focus --window-id " .. wid)
      end
      table.insert(lines, { icon = ":claude:", font = app_font, color = colors.orange, text = text, action = action })
    elseif hold.id == "manual" then
      table.insert(lines, { icon = icons.hand, font = glyph_font, color = colors.blue, text = text, action = release_manual })
    else
      table.insert(lines, { icon = icons.terminal, font = glyph_font, color = colors.green, text = text })
    end
  end
  if #held == 0 and on then
    table.insert(lines, { icon = icons.cup, font = glyph_font, color = colors.grey, text = "Started elsewhere" })
  end

  local hidden = #held - #shown
  local footer = hidden > 0 and "+" .. hidden .. " more" or ""
  local chars = length(footer)
  for _, line in ipairs(lines) do chars = math.max(chars, length(line.text)) end
  local width = math.floor(chars * settings.char_width) + row_end_padding

  for i = 1, max_rows do
    local line = lines[i]
    actions[i] = line and line.action
    if line then
      -- Rows only show their hover background when clicking them does something.
      rows[i]:set({
        drawing = true,
        icon = { string = line.icon, font = line.font, color = line.color },
        label = { string = line.text, color = colors.subtext, width = width },
        background = { color = line.action and colors.bg2 or colors.transparent },
      })
    else
      rows[i]:set({ drawing = false })
    end
  end
  rows[max_rows + 1]:set({
    drawing = footer ~= "",
    icon = { drawing = false },
    label = { string = footer, color = colors.grey, width = width },
    background = { color = colors.transparent },
  })

  if #lines == 0 then
    close_popup()
  elseif open then
    awake:set({ popup = { drawing = true } })
  end
end

local function update(env)
  -- The backend can take a moment to report a session it was just asked to start or end, so holds alone count as on,
  -- and right after they change they alone decide: an ending session would otherwise show as started elsewhere.
  local changed = env.SENDER == "mouse.clicked" or env.SENDER == "awake_change"
  local open = changed or env.SENDER == "mouse.entered"
  local command = awake_bin .. " list; echo ---; " .. awake_bin .. " active >/dev/null && echo on; echo ---;"
    .. " aerospace list-windows --all --format '%{window-id}|%{window-title}'"

  sbar.exec(command, function(output)
    local list, active, windows = ("\n" .. output):match("^(.-)\n%-%-%-\n(.-)%-%-%-\n(.*)$")
    local held = parse_holds(list)
    local on = #held > 0 or not changed and active:find("on") ~= nil
    draw(held, on, parse_windows(windows), open and (hovering or changed))
  end)
end

awake:subscribe({ "forced", "routine", "awake_change" }, update)

awake:subscribe("mouse.entered", function(env)
  hovering = true
  update(env)
end)

awake:subscribe("mouse.clicked", function(env)
  sbar.exec(awake_bin .. " toggle manual --label Manual --ttl 1800", function()
    update(env)
  end)
end)

awake:subscribe("mouse.exited.global", function()
  hovering = false
  close_popup()
end)
