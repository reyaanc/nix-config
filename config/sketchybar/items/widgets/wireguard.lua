local colors = require("colors")

sbar.add("event", "vpn_update")

local wireguard = sbar.add("item", "widgets.wireguard", {
  position = "right",
  icon = {
    string = ":wireguard:",
    font = "sketchybar-app-font:Regular:19.0",
    color = colors.muted,
    width = 32,
    align = "center",
    padding_left = 0,
    padding_right = 0,
  },
  label = { drawing = false },
})

-- The provider watches one VPN service by id, and only scutil maps the WireGuard app's tunnel to it.
wireguard:subscribe("forced", function()
  sbar.exec("scutil --nc list | grep -m1 com.wireguard.macos", function(line)
    local service = line:match("%x+%-%x+%-%x+%-%x+%-%x+")
    if service then
      sbar.exec("killall vpn_status >/dev/null; $CONFIG_DIR/helpers/event_providers/vpn_status/bin/vpn_status vpn_update " .. service)
    end
  end)
end)

wireguard:subscribe("vpn_update", function(env)
  wireguard:set({ icon = { color = env.connected == "true" and colors.blue or colors.muted } })
end)
