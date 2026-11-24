{ lib, pkgs, ... }:
{
  environment.shells = [ pkgs.fish ];

  users.users.reyaan.home = "/Users/reyaan";

  security.pam.services.sudo_local = {
    touchIdAuth = true;
    reattach = true;
  };

  system = {
    primaryUser = "reyaan";
    defaults = {
      spaces.spans-displays = false;
      NSGlobalDomain = {
        _HIHideMenuBar = true;
        AppleInterfaceStyle = "Dark";
        AppleKeyboardUIMode = 2;
        KeyRepeat = 2;
        InitialKeyRepeat = 15;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        NSAutomaticInlinePredictionEnabled = false;
        AppleSpacesSwitchOnActivate = false;
        NSWindowShouldDragOnGesture = true;
        AppleEnableSwipeNavigateWithScrolls = false;
      };
      ".GlobalPreferences"."com.apple.mouse.scaling" = 1.5;
      dock = {
        tilesize = 1;
        orientation = "right";
        autohide = true;
        autohide-delay = 100000000.0;
        mru-spaces = false;
        minimize-to-application = true;
        expose-group-apps = true;
      };
      WindowManager = {
        GloballyEnabled = false;
        EnableStandardClickToShowDesktop = false;
        EnableTilingByEdgeDrag = false;
        EnableTopTilingByEdgeDrag = false;
        EnableTilingOptionAccelerator = false;
        EnableTiledWindowMargins = false;
        HideDesktop = true;
        StandardHideDesktopIcons = true;
      };
      finder = {
        CreateDesktop = false;
        FXPreferredViewStyle = "Nlsv";
        ShowHardDrivesOnDesktop = false;
        ShowRemovableMediaOnDesktop = true;
      };
      screencapture = {
        location = "~/Documents/screenshots";
        target = "file";
      };
      trackpad = {
        Clicking = false;
        TrackpadThreeFingerDrag = false;
      };
      magicmouse.MouseButtonMode = "OneButton";
      CustomUserPreferences = {
        NSGlobalDomain = {
          AppleMiniaturizeOnDoubleClick = false;
          NSGlassDiffusionSetting = 0;
          UIPreferredContentSizeCategoryName = "UICTContentSizeCategoryL";
          WebAutomaticSpellingCorrectionEnabled = false;
        };
        "com.apple.dock".enterMissionControlByTopWindowDrag = false;
        "com.apple.screencapture".style = "selection";
        # This replaces macOS's whole shortcut table, so it lists every shortcut that's off on the work Mac, not only the ones that matter:
        # Spotlight (64, 65), input sources (60, 61), Mission Control and App Exposé (32, 33), Show Desktop (36) and space switching (79, 81, 118) free their keys for the window manager and Vicinae.
        "com.apple.symbolichotkeys".AppleSymbolicHotKeys = lib.genAttrs [
          "7" "8" "9" "10" "11" "12" "13" "15" "16" "17" "18" "19" "20" "21" "22" "23" "24" "25" "26"
          "32" "33" "36" "52" "57" "60" "61" "64" "65" "79" "81" "118" "159" "164" "175" "190" "222"
          "233" "235" "237" "238" "239" "240" "241" "242" "243" "244" "245" "246" "247" "248" "249"
          "250" "251" "256" "257" "258" "260"
        ] (_: { enabled = false; });
      };
    };
  };

  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      upgrade = true;
    };

    taps = [
      "penso/tap"
    ];

    brews = [
      "basis_universal"
      "herdr"
    ];

    casks = [
      "1password"
      "1password-cli"
      "claude-code@latest"
      "firefox"
      "ghostty"
      "google-chrome"
      "penso/tap/herdr-gpui"
      "karabiner-elements"
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
