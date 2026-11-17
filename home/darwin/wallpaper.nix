{ config, dotfile, ... }:
let
  home = config.home.homeDirectory;
  walls = "${home}/Pictures/wallpapers";
in
{
  home.sessionVariables.WALLPAPERS = walls;

  home.file = {
    "Pictures/wallpapers/theme.css".text = config.theme.css;
    "Pictures/wallpapers/index.html".source = dotfile "wallpaper/index.html";
    "Pictures/wallpapers/style.css".source = dotfile "wallpaper/style.css";
    "Pictures/wallpapers/server.py".source = dotfile "wallpaper/server.py";
    "Pictures/wallpapers/wallpaper.sh".source = dotfile "wallpaper/wallpaper.sh";
  };

  launchd.agents = {
    wallpaper = {
      enable = true;
      config = {
        ProgramArguments = [ "${walls}/wallpaper.sh" ];
        EnvironmentVariables.WALLPAPERS = walls;
        StartInterval = 1800;
        RunAtLoad = true;
        StandardErrorPath = "${home}/Library/Logs/wallpaper.log";
      };
    };

    wallpaper-server = {
      enable = true;
      config = {
        ProgramArguments = [
          "/usr/bin/python3"
          "${walls}/server.py"
        ];
        EnvironmentVariables.WALLPAPERS = walls;
        KeepAlive = true;
        RunAtLoad = true;
        StandardErrorPath = "${home}/Library/Logs/wallpaper-server.log";
      };
    };
  };
}
