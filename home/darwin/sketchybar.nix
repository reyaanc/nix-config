{ config, pkgs, dotfile, ... }:
{
  programs.sketchybar = {
    enable = true;
    configType = "lua";
    extraPackages = with pkgs; [ uv config.programs.omniwm.package ];
  };

  xdg.configFile.sketchybar.source = dotfile "sketchybar";
}
