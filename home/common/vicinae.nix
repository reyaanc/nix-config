{ config, lib, pkgs, dotfile, ... }:
let
  t = config.theme;
  c = t.colors;
in
{
  xdg.configFile = {
    "vicinae/settings.json".source = dotfile "vicinae/settings.json";

    "vicinae/home-manager.json".text = builtins.toJSON ({
      theme = {
        dark.name = "theme";
        light.name = "theme";
      };
      font.normal.family = t.font.family;
      keybinding = "vim";
      pop_to_root_on_close = true;
      close_on_focus_loss = true;
      favicon_service = "twenty";
      telemetry.system_info = false;
      tray.enabled = false;
      launcher_window = {
        opacity = 0.85;
        material = "blur";
      };
      favorites = [ "clipboard:history" ];
    } // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
      global_shortcuts.toggle = "cmd+super+alt+space";
      providers = {
        applications.entrypoints = lib.mapAttrs (_: shortcut: { inherit shortcut; }) {
          "org.mozilla.firefox" = "cmd+super+alt+w";
          "org.yanex.marta" = "cmd+super+alt+e";
          "dev.zed.Zed" = "cmd+super+alt+c";
        };
        clipboard.entrypoints.history.shortcut = "cmd+super+alt+v";
        core.entrypoints.search-emojis.shortcut = "cmd+super+alt+.";
      };
    });
  };

  xdg.dataFile."vicinae/themes/theme.toml".source = (pkgs.formats.toml { }).generate "vicinae-theme" {
    meta = {
      version = 1;
      inherit (t) name;
      description = "Generated from theme.nix";
      variant = "dark";
      inherits = "vicinae-dark";
    };
    colors = {
      core = {
        background = "#${c.bg}";
        foreground = "#${c.fg}";
        secondary_background = "#${c.bgDark}";
        border = "#${c.bgHighlight}";
        accent = "#${c.blue}";
      };
      accents = {
        blue = "#${c.blue}";
        green = "#${c.green}";
        magenta = "#${c.pink}";
        orange = "#${c.orange}";
        purple = "#${c.violet}";
        red = "#${c.red}";
        yellow = "#${c.yellow}";
        cyan = "#${c.aqua}";
      };
      list.item.selection = {
        background = "#${c.bgHighlight}";
        secondary_background = "#${c.bgLight}";
      };
      grid.item.background = "#${c.bgHighlight}";
    };
  };
}
