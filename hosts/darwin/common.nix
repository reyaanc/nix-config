{ pkgs, ... }:
{
  environment.shells = [ pkgs.fish ];

  security.pam.services.sudo_local.touchIdAuth = true;

  system.defaults.spaces.spans-displays = false;

  system.defaults.dock = {
    tilesize = 1;
    orientation = "right";
    autohide = true;
    autohide-delay = 100000000.0;
  };

  homebrew = {
    enable = true;

    taps = [
      "felixkratz/formulae"
      "penso/tap"
    ];

    brews = [
      "basis_universal"
      "herdr"
      "felixkratz/formulae/sketchybar"
    ];

    casks = [
      "1password"
      "1password-cli"
      "claude-code@latest"
      "firefox"
      "ghostty"
      "google-chrome"
      "penso/tap/herdr-gpui"
      "marta"
      "openlogi"
      "orcaslicer"
      "postman"
      "slack"
      "tailscale-app"
      "thunderbird"
      "todoist-app"
      "vicinae"
      "zed"
    ];

    masApps = {
      Amphetamine = 937984704;
      Plash = 1494023538;
      WireGuard = 1451685025;
    };
  };
}
