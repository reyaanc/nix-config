{ config, dotfile, ... }:
let
  profile = "Library/Thunderbird/Profiles/5tv85n2t.default-release";
in
{
  home.file = {
    "${profile}/chrome/userChrome.css".source = dotfile "thunderbird/chrome/userChrome.css";
    "${profile}/chrome/userContent.css".source = dotfile "thunderbird/chrome/userContent.css";
    "${profile}/chrome/theme.css".text = config.theme.css;
    "${profile}/user.js".source = dotfile "thunderbird/user.js";
  };
}
