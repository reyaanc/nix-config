{ config, lib, ... }:
let
  c = config.theme.colors;
  ansi = config.theme.ansi;
in
{
  programs.spicetify = {
    enable = true;
    theme = lib.mkDefault {
      name = "text";
      src = ../../config/spicetify/Themes/text;
      additionalCss = '':root { --font-family: "${config.theme.font.family}", monospace; }'';
    };
    customColorScheme = lib.mapAttrs (_: lib.mkDefault) {
      accent = c.green;
      accent-active = builtins.elemAt ansi 10;
      accent-inactive = c.bg;
      banner = c.yellow;
      border-active = c.green;
      border-inactive = c.bgHighlight;
      header = c.comment;
      highlight = c.bgLight;
      main = c.bg;
      notification = c.blue;
      notification-error = c.red;
      subtext = c.fgDim;
      text = c.fg;
    };
    experimentalFeatures = lib.mkDefault true;
    enabledExtensions = [
      {
        src = ../../config/spicetify/Extensions;
        name = "noControls.js";
      }
      {
        src = ../../config/spicetify/Extensions;
        name = "oneko.js";
      }
    ];
  };
}
