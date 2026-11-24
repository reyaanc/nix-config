{ config, lib, pkgs, ... }:
let
  t = config.theme;
  c = t.colors;
  toml = pkgs.formats.toml { };
  hex = name: "#${c.${name}}";
in
{
  xdg.configFile = {
    "herdr/config.toml" = {
      force = true;
      source = toml.generate "herdr-config.toml" {
        onboarding = false;
        theme = {
          name = "kanagawa";
          auto_switch = false;
          custom = lib.mapAttrs (_: hex) {
            accent = "blue";
            panel_bg = "bg";
            sidebar_bg = "bgDark";
            active_row_bg = "bgHighlight";
            selection_bg = "bgLight";
            surface0 = "bgHighlight";
            surface1 = "bgLight";
            surface_dim = "bgDark";
            overlay0 = "comment";
            overlay1 = "border";
            text = "fg";
            subtext0 = "fgDim";
            mauve = "violet";
            green = "green";
            yellow = "yellow";
            red = "red";
            blue = "blue";
            teal = "aqua";
            peach = "orange";
          };
        };
        worktrees.directory = "~/Worktrees";
      };
    };

    "herdr/config-gpui.local.toml" = {
      force = true;
      source = toml.generate "herdr-config-gpui.local.toml" {
        layout = "comfortable-rounded";
        show_listening_ports = false;
        theme = "${config.xdg.configHome}/herdr/ghostty-theme";
        contrast = "standard";
        remove_merged_worktrees = true;
        sidebar.family = t.font.family;
        tabs.family = t.font.family;
        terminal.family = t.font.family;
        ui.family = t.font.family;
        backdrop.opacity = 0.94;
      };
    };

    "herdr/ghostty-theme".text =
      lib.concatImapStrings (i: color: "palette = ${toString (i - 1)}=#${color}\n") t.ansi + ''
        background = ${hex "bg"}
        foreground = ${hex "fg"}
        cursor-color = #${builtins.elemAt t.ansi 7}
        cursor-text = ${hex "bg"}
        selection-background = ${hex "fg"}
        selection-foreground = ${hex "bg"}
      '';
  };
}
