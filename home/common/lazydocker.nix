{ config, lib, ... }:
let
  c = config.theme.colors;
in
{
  programs.lazydocker = {
    enable = true;
    settings = lib.mapAttrsRecursive (_: lib.mkDefault) {
      gui.theme = {
        activeBorderColor = [ "#${c.orange}" "bold" ];
        inactiveBorderColor = [ "#${c.border}" ];
        selectedLineBgColor = [ "#${c.bgHighlight}" ];
        optionsTextColor = [ "#${c.blue}" ];
      };
    };
  };
}
