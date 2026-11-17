{ lib, ... }:
{
  programs.git = {
    enable = true;

    settings = lib.mapAttrsRecursive (_: lib.mkDefault) {
      user = {
        name = "reyaanc";
        email = "59304120+reyaanc@users.noreply.github.com";
      };
      push.autoSetupRemote = true;
      pull.rebase = true;
      rebase = {
        autoSquash = true;
        autoStash = true;
        updateRefs = true;
      };
      rerere.enabled = true;
      merge.conflictStyle = "zdiff3";
      diff = {
        algorithm = "histogram";
        colorMoved = "default";
      };
      branch.sort = "-committerdate";
      fetch.prune = true;
      commit.verbose = true;
    };

    ignores = [
      ".DS_Store"
      "**/.claude/settings.local.json"
      "**/.claude/.cc-writes/"
    ];
  };
}
