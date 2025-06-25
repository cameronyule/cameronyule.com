{
  inputs = {
    # keep-sorted start block=yes
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # keep-sorted end
  };

  outputs = inputs @ {
    # keep-sorted start
    flake-parts,
    nixpkgs,
    self,
    treefmt-nix,
    # keep-sorted end
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      perSystem = {pkgs, ...}: let
        treefmtEval = treefmt-nix.lib.evalModule pkgs ./internal/nix/treefmt.nix;
      in {
        formatter = treefmtEval.config.build.wrapper;
        checks.formatting = treefmtEval.config.build.check self;

        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            # keep-sorted start
            hugo
            yq
            # keep-sorted end
          ];
        };
      };
    };
}
