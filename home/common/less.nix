{ lib, ... }:
{
  home.sessionVariables.LESS = lib.mkDefault "-FR --mouse";
}
