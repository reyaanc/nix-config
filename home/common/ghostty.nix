{ config, lib, ... }:
let
  t = config.theme;
  c = t.colors;
in
{
  programs.ghostty = {
    enable = true;

    settings = lib.mapAttrsRecursive (_: lib.mkDefault) {
      shell-integration-features = "ssh-env,ssh-terminfo";

      font-family = t.font.family;
      font-size = t.font.size;
      adjust-cell-height = "10%";
      window-padding-x = 12;
      window-padding-y = 10;
      window-padding-balance = true;

      theme = t.name;
      background = "#${c.bg}";
      foreground = "#${c.fg}";
      palette = lib.imap0 (i: hex: "${toString i}=#${hex}") t.ansi;
      background-opacity = 0.85;
      background-blur = 12;

      window-decoration = true;
      confirm-close-surface = false;
      mouse-hide-while-typing = true;

      notify-on-command-finish = "unfocused";
      notify-on-command-finish-action = "bell,notify";
      notify-on-command-finish-after = "15s";
    };
  };
}
