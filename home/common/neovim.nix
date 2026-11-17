{ lib, dotfile, ... }:
{
  home.sessionVariables.EDITOR = lib.mkDefault "nvim";

  xdg.configFile.nvim.source = dotfile "nvim";
}
