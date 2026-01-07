{
  description = "Magos NixOS Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      username = "johan";
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in {
    devShells.x86_64-linux.k2a = pkgs.mkShell {
      buildInputs = [
        pkgs.php82
        pkgs.php82Packages.composer
        pkgs.wp-cli
        pkgs.nodejs_20
      ];
    };

    nixosConfigurations.magos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs username; };
      modules = [
        ./nixos/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${username} = import ./nixos/home.nix;
        }
      ];
    };
  };
}
