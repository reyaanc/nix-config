{ lib, ... }:
{
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = lib.mapAttrsRecursive (_: lib.mkDefault) {
      navigate = true;
      line-numbers = true;
    };
  };
}
