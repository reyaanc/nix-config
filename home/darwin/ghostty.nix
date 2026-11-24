{ config, ... }:
let
  c = config.theme.colors;
in
{
  programs.ghostty = {
    package = null;
    settings = {
      macos-window-shadow = false;
      macos-titlebar-style = "hidden";
      macos-icon = "custom-style";
      macos-icon-frame = "plastic";
      macos-icon-ghost-color = "#${c.blue}";
      macos-icon-screen-color = "#${c.bgDark},#${c.bg},#${c.bgHighlight}";
      macos-auto-secure-input = false;
      macos-option-as-alt = true;
      keybind = [ "global:alt+enter=new_window" ];
    };
  };
}
