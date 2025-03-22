{
  description = "Nix development environment of Raster II";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            (python3.withPackages (pk: with pk; [
                meson
                sphinx
                sphinxcontrib-wavedrom
            ]))
            libevent
            cjson
            circt
            fujprog
            nextpnr
            sbt
            scalafmt
            rustfmt
            sdl3
            trellis
            svd2rust
            verilator
            yosys
          ];
          shellHook = ''
            export CHISEL_FIRTOOL_PATH=${pkgs.circt.outPath}/bin
          '';
        };
      }
    );
}
