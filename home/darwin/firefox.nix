{ dotfile, ... }:
let
  profile = "Library/Application Support/Firefox/Profiles/h4ytd0bs.default-release";
in
{
  home.file = {
    "${profile}/chrome".source = dotfile "firefox/chrome";
    "${profile}/user.js".source = dotfile "firefox/user.js";
  };
}
