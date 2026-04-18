# mac:   sudo darwin-rebuild switch --flake .#macbook
# linux: sudo nixos-rebuild switch --flake .#germany01

{
  description = "System configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
    }:
    {
      darwinConfigurations."macbook" = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit self; };
        modules = [
          home-manager.darwinModules.home-manager
          ./nix/machines/shared.nix
          ./nix/user/shared.nix
          ./nix/user/darwin.nix
          ./nix/machines/macbook.nix
        ];
      };

      nixosConfigurations."germany01" = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit self; };
        modules = [
          home-manager.nixosModules.home-manager
          ./nix/machines/shared.nix
          ./nix/user/shared.nix
          ./nix/user/linux.nix
          ./nix/machines/germany01.nix
        ];
      };

      # modules for an infra repo to import
      nixosModules.default = {
        imports = [
          ./nix/user/shared.nix
          ./nix/user/linux.nix
        ];
      };
      darwinModules.default = {
        imports = [
          ./nix/user/shared.nix
          ./nix/user/darwin.nix
        ];
      };
    };
}
