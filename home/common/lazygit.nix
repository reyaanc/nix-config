{ config, lib, ... }:
let
  c = config.theme.colors;
in
{
  programs.lazygit = {
    enable = true;
    settings = lib.mapAttrsRecursive (_: lib.mkDefault) {
      os.editPreset = "nvim-remote";
      gui.theme = {
        activeBorderColor = [ "#${c.orange}" "bold" ];
        inactiveBorderColor = [ "#${c.border}" ];
        searchingActiveBorderColor = [ "#${c.orange}" "bold" ];
        optionsTextColor = [ "#${c.blue}" ];
        selectedLineBgColor = [ "#${c.bgHighlight}" ];
        cherryPickedCommitFgColor = [ "#${c.blue}" ];
        cherryPickedCommitBgColor = [ "#${c.violet}" ];
        markedBaseCommitFgColor = [ "#${c.blue}" ];
        markedBaseCommitBgColor = [ "#${c.yellow}" ];
        unstagedChangesColor = [ "#${c.red}" ];
        defaultFgColor = [ "#${c.fg}" ];
      };
    };
  };
}
