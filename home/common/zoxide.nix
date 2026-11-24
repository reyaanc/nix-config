{ config, lib, ... }:
let
  home = config.home.homeDirectory;
  zoxide = lib.getExe config.programs.zoxide.package;
in
{
  options.zoxide.directories = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
  };

  config = {
    programs.zoxide = {
      enable = true;
      options = [ "--cmd" "cd" ];
    };

    zoxide.directories = [
      "${home}/Personal"
      "${home}/Personal/nix-config"
      "${home}/Worktrees"
    ];

    home.activation.zoxideDirectories = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      known=$(${zoxide} query --list 2>/dev/null || true)
      for dir in ${lib.escapeShellArgs config.zoxide.directories}; do
        if [ -d "$dir" ] && ! grep -qxF "$dir" <<< "$known"; then
          run ${zoxide} add "$dir"
        fi
      done
    '';
  };
}
