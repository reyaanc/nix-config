{ lib, ... }:
{
  home.activation.folders = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p "$HOME/Personal" "$HOME/Worktrees"
  '';
}
