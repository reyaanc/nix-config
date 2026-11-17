{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    work.url = "path:/Users/reyaan/Personal/nix-work";
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, nix-darwin, home-manager, spicetify-nix, ... }:
  let
    home = [
      ./home/common
      spicetify-nix.homeManagerModules.default
    ];
  in
  {
    darwinConfigurations.MacBook-Pro = nix-darwin.lib.darwinSystem {
      specialArgs = { inherit inputs; };
      modules = [
        ./hosts/darwin/work
        home-manager.darwinModules.home-manager
        { home-manager.users.reyaan.imports = home ++ [ ./home/darwin ]; }
      ];
    };

    nixosConfigurations.linux = nixpkgs.lib.nixosSystem {
      modules = [
        ./hosts/linux/personal
        home-manager.nixosModules.home-manager
        { home-manager.users.reyaan.imports = home ++ [ ./home/linux ]; }
      ];
    };
  };
}
