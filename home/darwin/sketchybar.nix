{ pkgs, dotfile, ... }:
{
  programs.sketchybar = {
    enable = true;
    configType = "lua";
    extraPackages = with pkgs; [ librsvg uv ];
  };

  xdg.configFile.sketchybar.source = dotfile "sketchybar";
}
