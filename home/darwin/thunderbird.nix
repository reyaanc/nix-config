{ config, lib, pkgs, dotfile, ... }:
let
  theme = pkgs.writeText "theme.css" config.theme.css;
in
{
  # The profile folder's name is random per machine, so it's read from installs.ini at switch time; before Thunderbird's first launch there's no profile to link into.
  home.activation.thunderbirdProfile = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    app="$HOME/Library/Thunderbird"
    profile=$(sed -n 's/^Default=//p' "$app/installs.ini" 2>/dev/null | head -n 1)
    if [ -n "$profile" ]; then
      run mkdir -p "$app/$profile/chrome"
      run ln -sfn ${dotfile "thunderbird/user.js"} "$app/$profile/user.js"
      run ln -sfn ${dotfile "thunderbird/chrome/userChrome.css"} "$app/$profile/chrome/userChrome.css"
      run ln -sfn ${dotfile "thunderbird/chrome/userContent.css"} "$app/$profile/chrome/userContent.css"
      run ln -sfn ${theme} "$app/$profile/chrome/theme.css"
    fi
  '';
}
