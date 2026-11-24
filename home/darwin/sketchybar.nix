{ config, pkgs, dotfile, ... }:
{
  programs.sketchybar = {
    enable = true;
    configType = "lua";
    extraPackages = with pkgs; [ librsvg uv config.programs.omniwm.package ];
  };

  xdg.configFile.sketchybar.source = dotfile "sketchybar";

  launchd.agents.sketchybar-omniwm = {
    enable = true;
    config = {
      ProgramArguments = [
        "${config.programs.omniwm.package}/bin/omniwmctl"
        "watch"
        "active-workspace,windows-changed,focused-monitor,layout-changed"
        "--reconnect"
        "--exec"
        "${config.programs.sketchybar.finalPackage}/bin/sketchybar"
        "--trigger"
        "omniwm_change"
      ];
      KeepAlive = true;
      RunAtLoad = true;
    };
  };
}
