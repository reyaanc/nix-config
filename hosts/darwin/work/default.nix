{ inputs, ... }:
{
  imports = [
    ../../common.nix
    ../common.nix
    inputs.work.darwinModules.default
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  system.primaryUser = "reyaan";
  users.users.reyaan.home = "/Users/reyaan";

  home-manager.users.reyaan.imports = [ inputs.work.homeModules.default ];

  system.stateVersion = 6;
}
