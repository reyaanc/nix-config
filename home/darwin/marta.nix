{ config, lib, ... }:
let
  dir = "Library/Application Support/org.yanex.marta";
in
{
  options.marta.favorites = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
    default = { };
  };

  config = {
    marta.favorites = {
      Personal = "~/Personal";
      Worktrees = "~/Worktrees";
    };

    home = {
      file."${dir}/conf.marco".text = ''
        environment {
            terminal "Ghostty"
            textEditor "Zed"
        }
      '';

      file."${dir}/favorites.marco".text = ''
        Home "~"
        Downloads "''${user.downloads}"
        Desktop "''${user.desktop}"
        Applications "''${all.applications}"

        Separator1 null

      '' + lib.concatStrings (lib.mapAttrsToList (name: path: "${name} \"${path}\"\n") config.marta.favorites);
    };

    targets.darwin.defaults.NSGlobalDomain.NSFileViewer = "org.yanex.marta";
  };
}
