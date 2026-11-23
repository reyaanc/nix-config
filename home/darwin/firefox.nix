{ lib, dotfile, ... }:
{
  # The profile folder's name is random per machine, so it's read from installs.ini at switch time; before Firefox's first launch there's no profile to link into.
  home.activation.firefoxProfile = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    app="$HOME/Library/Application Support/Firefox"
    profile=$(sed -n 's/^Default=//p' "$app/installs.ini" 2>/dev/null | head -n 1)
    if [ -n "$profile" ]; then
      run ln -sfn ${dotfile "firefox/chrome"} "$app/$profile/chrome"
      run ln -sfn ${dotfile "firefox/user.js"} "$app/$profile/user.js"
    fi
  '';
}
