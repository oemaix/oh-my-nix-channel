{
  description = "Personal Nix packages as an overlay, written so they can later move into nixpkgs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      inherit (nixpkgs) lib;

      # nixpkgs unstable no longer supports x86_64-darwin.
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      forAllSystems = lib.genAttrs systems;

      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
          # Some packages in this repo (msty-studio) are unfree.
          config.allowUnfree = true;
        };

      # Only expose packages that can actually run on the given system.
      ourPackagesFor =
        system:
        let
          pkgs = pkgsFor system;
        in
        lib.filterAttrs (_: pkg: lib.meta.availableOn pkgs.stdenv.hostPlatform pkg) (
          import ./pkgs { inherit pkgs; }
        );
    in
    {
      overlays.default = import ./overlay.nix;

      # Applying this module makes every package in this repo available as pkgs.<name>.
      nixosModules.overlay = {
        nixpkgs.overlays = [ self.overlays.default ];
      };
      nixosModules.default = self.nixosModules.overlay;

      packages = forAllSystems ourPackagesFor;

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);

      # Build every package of this repo on `nix flake check`.
      checks = forAllSystems (system: self.packages.${system});

      devShells = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          default = pkgs.mkShell {
            packages = [ pkgs.nixfmt ];
          };
        }
      );
    };
}
