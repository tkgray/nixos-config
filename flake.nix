{
  description = "NixOS configuration for seagull";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
  };

  outputs = { self, nixpkgs, nixpkgs-stable }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      pkgs-stable = nixpkgs-stable.legacyPackages.${system};
    in
    {
      # NixOS configuration
      nixosConfigurations.seagull = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./configuration-local.nix
        ];
      };

      # Overlays for stable package access
      overlays.default = _final: _prev: {
        stable = pkgs-stable;
      };

      # Development shell with maintenance tools
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          nixfmt
          nixpkgs-fmt
          deadnix
          statix
          nil
        ];
        shellHook = ''
          echo "NixOS development environment loaded"
          echo "Available commands: nixfmt, nixpkgs-fmt, deadnix, statix, nil"
        '';
      };

      # Quality checks
      checks.${system} = {
        formatting = pkgs.runCommand "check-formatting" { } ''
          ${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt --check ${self}/flake.nix
          touch $out
        '';

        deadnix = pkgs.runCommand "check-deadnix" { } ''
          ${pkgs.deadnix}/bin/deadnix --fail ${self}/flake.nix
          touch $out
        '';

        statix = pkgs.runCommand "check-statix" { } ''
          ${pkgs.statix}/bin/statix check ${self}/flake.nix
          touch $out
        '';
      };

      # Formatter for nix fmt
      formatter.${system} = pkgs.nixpkgs-fmt;

    };
}
