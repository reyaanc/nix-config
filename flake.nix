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
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, spicetify-nix, ... }:
  let
    home = [
      ./home/common
      spicetify-nix.homeManagerModules.default
    ];
  in
  {
    darwinModules.default = {
      imports = [
        ./hosts/common.nix
        ./hosts/darwin/common.nix
        home-manager.darwinModules.home-manager
      ];
      home-manager.users.reyaan.imports = home ++ [ ./home/darwin ];
    };

    darwinConfigurations.personal = nix-darwin.lib.darwinSystem {
      modules = [
        self.darwinModules.default
        ./hosts/darwin/personal
        { home-manager.users.reyaan.rebuild.host = "personal"; }
      ];
    };

    nixosConfigurations.linux = nixpkgs.lib.nixosSystem {
      modules = [
        ./hosts/linux/personal
        home-manager.nixosModules.home-manager
        {
          home-manager.users.reyaan = {
            imports = home ++ [ ./home/linux ];
            rebuild.host = "linux";
          };
        }
      ];
    };
  };
}
