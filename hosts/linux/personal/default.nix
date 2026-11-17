{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../common.nix
    ../common.nix
  ];

  networking.hostName = "linux";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  users.users.reyaan = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.fish;
  };

  system.stateVersion = "26.05";
}
