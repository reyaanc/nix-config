{
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "reyaan" ];
    max-jobs = "auto";
  };

  nixpkgs.config.allowUnfree = true;

  programs.fish.enable = true;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };
}
