{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url      = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url  = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
        name = "pmw";
      in
      {
        defaultPackage = pkgs.stdenv.mkDerivation {
          inherit name;
          src = self;
          buildInputs = [
            pkgs.rust-bin.stable.latest.default
          ];
          buildPhase = ''
            cargo build --release
          '';
          installPhase = ''
            mkdir -p $out/bin
            cp ./target/release/kodo $out/bin
          '';
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.rust-analyzer
            pkgs.rust-bin.stable.latest.default
          ];

          shellHook = ''
            PS1="\n\[\033[01;32m\]${name}-nix >\[\033[00m\] "
          '';
        };
      }
    );
}
