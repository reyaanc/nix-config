local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

local slots = 8
local app_font = "sketchybar-app-font:Regular:15.0"

sbar.add("event", "aerospace_workspace_change")
sbar.add("event", "workspaces_change")

local scrolling = false
local function scroll(env)
  if scrolling then return end
  scrolling = true
  local direction = env.INFO.delta < 0 and "prev" or "next"
  sbar.exec("aerospace list-workspaces --monitor focused --empty no | aerospace workspace --stdin --wrap-around " .. direction .. "; sleep 0.4", function()
    scrolling = false
  end)
end

local spaces = {}
for sid = 1, 9 do
  local function click(env)
    local command = env.BUTTON == "right" and "move-node-to-workspace" or "workspace"
    sbar.exec("aerospace " .. command .. " " .. sid)
  end

  local space = sbar.add("item", "space." .. sid, {
    icon = { string = sid, align = "left", width = 21, padding_left = 7, padding_right = 0, color = colors.grey },
    label = { string = "-", width = 21, align = "center", padding_left = 0, padding_right = 0, color = colors.grey },
    background = { color = colors.with_alpha(colors.bg3, 0.85), height = 32 },
  })
  space:subscribe("mouse.clicked", click)
  space:subscribe("mouse.scrolled", scroll)

  local apps = {}
  for slot = 1, slots do
    local app = sbar.add("item", "space." .. sid .. "." .. slot, {
      drawing = false,
      icon = { font = app_font, padding_left = 0, padding_right = 0 },
      label = { string = icons.dot, font = { size = 7.0 }, width = 0, y_offset = 5, drawing = false },
      background = { color = colors.with_alpha(colors.bg3, 0.85), height = 32 },
    })
    app:subscribe("mouse.clicked", click)
    app:subscribe("mouse.scrolled", scroll)
    apps[slot] = app
  end

  spaces[sid] = { item = space, apps = apps }
end

sbar.add("bracket", "spaces", { "/space\\..*/" }, {
  background = { color = colors.with_alpha(colors.bg1, 0.19), height = 32 },
})

-- Positions outlive a reload, since a window on a hidden workspace can't be measured until it's next shown
local positions_file = "/tmp/sketchybar/positions"
local positions, positions_text = {}, nil
local file = io.open(positions_file)
if file then
  positions_text = file:read("a")
  file:close()
  for id, x, y, size in positions_text:gmatch("(%d+)|(-?%d+)|(-?%d+)|(-?%d+)") do
    positions[id] = { x = tonumber(x), y = tonumber(y), size = tonumber(size) }
  end
end
local badges, badges_text = {}, nil
local avatars, avatars_text = {}, nil

local function serialize(value)
  if type(value) ~= "table" then return tostring(value) end
  local keys = {}
  for key in pairs(value) do keys[#keys + 1] = key end
  table.sort(keys)
  local parts = {}
  for _, key in ipairs(keys) do parts[#parts + 1] = key .. "=" .. serialize(value[key]) end
  return "{" .. table.concat(parts, ",") .. "}"
end

-- One icon per app (and Firefox profile) per workspace, placed by its top-left window
local function group(windows)
  local groups, shown, small = {}, {}, {}

  local function add(window)
    local avatar = avatars[window.pid]
    local key = window.ws .. "|" .. window.app .. "|" .. (avatar or "")
    local entry = groups[key]
    if not entry then
      entry = { ws = window.ws, app = window.app, avatar = avatar, x = 1e9, y = 1e9 }
      groups[key] = entry
    end
    local position = positions[window.id]
    if position and (position.x < entry.x or position.x == entry.x and position.y < entry.y) then
      entry.x, entry.y = position.x, position.y
    end
  end

  for _, window in ipairs(windows) do
    local position = positions[window.id]
    -- Windows covering under 30% of their screen (popups, pickers, small floats) get no icon, unless the workspace has nothing bigger
    if position and position.size < 30 then
      local biggest = small[window.ws]
      if not biggest or position.size > positions[biggest.id].size then small[window.ws] = window end
    else
      shown[window.ws] = true
      add(window)
    end
  end
  for ws, window in pairs(small) do
    if not shown[ws] then add(window) end
  end

  local by_ws = {}
  for _, entry in pairs(groups) do
    by_ws[entry.ws] = by_ws[entry.ws] or {}
    table.insert(by_ws[entry.ws], entry)
  end
  for _, list in pairs(by_ws) do
    table.sort(list, function(a, b)
      if a.x ~= b.x then return a.x < b.x end
      if a.y ~= b.y then return a.y < b.y end
      return a.app < b.app
    end)
  end
  return by_ws
end

local render

-- The app font has no Herdr glyph, so Herdr's own ram logo is drawn as an image, rendered once per tint
local function herdr_logo(tint)
  local hex = string.format("%06x", tint & 0xffffff)
  local png = "/tmp/sketchybar/herdr-" .. hex .. ".png"
  local file = io.open(png)
  if file then
    file:close()
    return png
  end
  sbar.exec("sed 's/#303438/#" .. hex .. "/' \"$CONFIG_DIR/icons/herdr.svg\" | rsvg-convert -h 30 -o " .. png, function()
    render()
  end)
end

local function app_props(entry, index, count, focused)
  local base, fade = colors.grey, 60
  if focused then base, fade = colors.white, 45 end
  local tint = colors.mix(colors.brand[entry.app] or base, base, fade)

  local glyph = app_icons[entry.app] or app_icons["Default"]
  local font = app_font
  local width = index == count and 23 or 21
  local logo

  -- The app font draws iPhone Mirroring as a hairline outline, so it borrows the bolder nf-md-cellphone
  if entry.app == "iPhone Mirroring" then
    glyph, font, width = icons.cellphone, { family = settings.font.text, style = settings.font.style_map["Bold"], size = 16.0 }, width - 9
  elseif entry.app == "Herdr" then
    glyph, logo = "", herdr_logo(tint)
  -- Thunderbird's bird-and-envelope glyph breaks up into noise at bar size
  elseif entry.app == "Thunderbird" then
    glyph = ":mail:"
  end

  local badge, badge_color, mark, mark_y = false, colors.red, icons.dot, 5
  local label = badges[entry.app]
  if label then
    badge = true
    -- A bare dot is unread activity with nothing aimed at you (Slack channels), so it stays quiet; counts are mentions and DMs.
    if label == "•" then badge_color = colors.subtext end
  end
  local profile = colors.profile[entry.avatar]
  -- A Firefox window outside the default profile gets a square of its colour, bottom right so it can't pass for a badge
  if not badge and profile then
    badge, badge_color, mark, mark_y = true, profile, icons.square, -6
  end

  local icon = { string = glyph, font = font, color = tint, width = width, background = { drawing = logo ~= nil } }
  if logo then
    icon.background.image = { string = logo, scale = 0.5 }
    icon.background.color = colors.transparent
  end

  return {
    drawing = true,
    icon = icon,
    label = {
      string = mark,
      y_offset = mark_y,
      drawing = badge,
      color = badge_color,
      padding_left = 12 - width,
      padding_right = width - 12,
    },
    background = { drawing = focused },
  }
end

local rendering, dirty, drawn, layout = false, false, nil, nil

local function draw(windows, workspaces)
  local by_ws = group(windows)
  local updates, next_layout = {}, ""

  for sid = 1, 9 do
    local ws = tostring(sid)
    local entries = by_ws[ws] or {}
    local count = math.min(#entries, slots)
    local focused = workspaces[ws] ~= nil and workspaces[ws].focused
    local side = workspaces[ws] ~= nil and not workspaces[ws].main
    next_layout = next_layout .. count .. " " .. (side and "m" or "")

    table.insert(updates, { spaces[sid].item, {
      background = { drawing = focused },
      icon = {
        string = side and sid .. " " .. icons.monitor or ws,
        width = side and 37 or 21,
        color = focused and colors.blue or colors.grey,
      },
      label = { drawing = count == 0 },
    } })

    for slot = 1, slots do
      local props = { drawing = false }
      if slot <= count then props = app_props(entries[slot], slot, count, focused) end
      table.insert(updates, { spaces[sid].apps[slot], props })
    end
  end

  local function apply()
    for _, update in ipairs(updates) do update[1]:set(update[2]) end
  end

  -- Most triggers are focus changes that leave the bar as it was, and redrawing every icon is the slowest step
  local parts = {}
  for _, update in ipairs(updates) do parts[#parts + 1] = update[1].name .. serialize(update[2]) end
  local state = table.concat(parts)
  if state ~= drawn then
    -- The first draw after a (re)load fills the bar bar.lua kept hidden, all at once and without animating in
    if drawn then
      sbar.animate("tanh", 3, apply)
    else
      apply()
      sbar.bar({ hidden = false })
    end
    drawn = state
  end

  -- agenda fits its label to the room the spaces leave, which only changes with how many icons each one shows.
  if next_layout ~= layout then
    layout = next_layout
    sbar.trigger("workspaces_change")
  end
end

-- Reading profiles means a Python start and a SQLite read, so it only happens when a Firefox process comes or goes.
local firefox_pids
local function update_avatars(windows)
  local pids, seen = {}, {}
  for _, window in ipairs(windows) do
    if window.app == "Firefox" and not seen[window.pid] then
      seen[window.pid] = true
      table.insert(pids, window.pid)
    end
  end
  table.sort(pids)
  local key = table.concat(pids, " ")
  if key == firefox_pids then return end
  firefox_pids = key

  sbar.exec("$CONFIG_DIR/helpers/firefox.py " .. key, function(output)
    if output == avatars_text then return end
    avatars, avatars_text = {}, output
    for pid, avatar in output:gmatch("(%d+)|([^\n]+)") do
      avatars[pid] = avatar
    end
    render()
  end)
end

local query = "aerospace list-windows --all --format '%{window-id}|%{workspace}|%{app-pid}|%{app-name}|%{window-title}'"
  .. " && echo --- && aerospace list-workspaces --all --format '%{workspace}|%{monitor-is-main}|%{workspace-is-focused}'"

-- Events arrive in bursts (a window move fires several), so one landing mid-render only marks the bar dirty and the render in flight runs once more.
function render()
  if rendering then
    dirty = true
    return
  end
  rendering, dirty = true, false

  sbar.exec(query, function(output, exit_code)
    if exit_code == 0 then
      local window_lines, workspace_lines = ("\n" .. output):match("^(.-)\n%-%-%-\n(.*)$")
      local windows, workspaces = {}, {}
      for line in window_lines:gmatch("[^\n]+") do
        local id, ws, pid, app, title = line:match("^([^|]*)|([^|]*)|([^|]*)|([^|]*)|(.*)$")
        -- herdr titles its Ghostty window "herdr · {workspace}", so it shares the Herdr app's icon
        if app == "Ghostty" and title:find("^herdr · ") then app = "Herdr" end
        table.insert(windows, { id = id, ws = ws, pid = pid, app = app })
      end
      for ws, main, focused in workspace_lines:gmatch("([^|\n]+)|(%a+)|(%a+)") do
        workspaces[ws] = { main = main == "true", focused = focused == "true" }
      end
      update_avatars(windows)
      draw(windows, workspaces)
    end

    rendering = false
    if dirty then render() end
  end)
end

local function update_positions()
  sbar.exec("aerospace list-windows --all --format '%{window-id}|%{workspace-is-visible}'", function(windows)
    sbar.exec("$CONFIG_DIR/helpers/window_positions/bin/window_positions", function(helper)
      local live = {}
      for id, x, y, size in helper:gmatch("(%d+)|(-?%d+)|(-?%d+)|(-?%d+)") do
        live[id] = { x = tonumber(x), y = tonumber(y), size = tonumber(size) }
      end

      local order, visible, parked = {}, {}, {}
      for id, is_visible in windows:gmatch("(%d+)|(%a+)") do
        table.insert(order, id)
        visible[id] = is_visible == "true"
        if not visible[id] and live[id] then parked[live[id].x .. "|" .. live[id].y] = true end
      end

      local seen, lines = {}, {}
      for _, id in ipairs(order) do
        local window = live[id]
        -- Hidden workspaces are parked in a screen corner, so their windows keep the position last seen while visible
        if visible[id] and window and not parked[window.x .. "|" .. window.y] then
          seen[id] = window
        else
          seen[id] = positions[id]
        end
        if seen[id] then
          table.insert(lines, id .. "|" .. seen[id].x .. "|" .. seen[id].y .. "|" .. seen[id].size)
        end
      end

      local text = table.concat(lines, "\n")
      if text == positions_text then return end
      positions, positions_text = seen, text
      local file = io.open(positions_file, "w")
      file:write(text)
      file:close()
      render()
    end)
  end)
end

local function update_badges()
  sbar.exec([[aerospace list-apps --format '%{app-name}' | while IFS= read -r app; do
    label=$(lsappinfo info -only StatusLabel "$app" | sed -n 's/.*"label"="\(.*\)".*/\1/p')
    [ -n "$label" ] && echo "$app|$label"
  done]], function(output)
    if output == badges_text then return end
    badges, badges_text = {}, output
    for app, label in output:gmatch("([^\n|]+)|([^\n]+)") do
      -- Ghostty's badge is app-wide and would mark every one of its windows
      if app ~= "Ghostty" then badges[app] = label end
    end
    render()
  end)
end

local observer = sbar.add("item", "spaces.observer", { drawing = false, updates = true, update_freq = 15 })

observer:subscribe("forced", function()
  render()
  update_positions()
  update_badges()
end)
observer:subscribe("routine", function()
  update_positions()
  update_badges()
end)
observer:subscribe("aerospace_workspace_change", function()
  render()
  update_positions()
end)
observer:subscribe("space_windows_change", function()
  render()
  update_positions()
end)
observer:subscribe("aerospace_mode_change", update_positions)
observer:subscribe("display_change", render)
