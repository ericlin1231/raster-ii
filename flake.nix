{
  description = "Nix development environment of Raster II";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; };
      in {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            circt
            nextpnr
            openfpgaloader
            sbt
            trellis
            yosys
          ];
          shellHook = ''
            export CHISEL_FIRTOOL_PATH=$(nix eval nixpkgs#circt.outPath --raw)/bin
          '';
        };
      });
}
