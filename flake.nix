{
  description = "Rust-Nix";

  inputs = {
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    crate2nix = {
      url = "github:nix-community/crate2nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
	flake-parts.follows = "flake-parts";
	devshell.follows = "devshell";
	pre-commit-hooks.follows = "git-hooks";
      };
    };
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };
    # Development
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-trusted-public-keys = "eigenvalue.cachix.org-1:ykerQDDa55PGxU25CETy9wF6uVDpadGGXYrFNJA3TUs=";
    extra-substituters = "https://eigenvalue.cachix.org";
    allow-import-from-derivation = true;
  };

  outputs =
    inputs @ { self
    , nixpkgs
    , flake-parts
    , rust-overlay
    , crate2nix
    , ...
    }: flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      imports = [
        ./nix/rust-overlay/flake-module.nix
        ./nix/devshell/flake-module.nix
      ];

      perSystem = { system, pkgs, lib, inputs', ... }:
        let
          # If you dislike IFD, you can also generate it with `crate2nix generate` 
          # on each dependency change and import it here with `import ./Cargo.nix`.
          cargoNix = inputs.crate2nix.tools.${system}.appliedCargoNix {
            name = "rustnix";
            src = ./.;
          };
        in
        rec {
          checks = {
            default = cargoNix.rootCrate.build.override {
              runTests = true;
            };
          };

          packages = {
            default = cargoNix.rootCrate.build.overrideAttrs (self: super: {
	      
	    });

            inherit (pkgs) rust-toolchain;

            rust-toolchain-versions = pkgs.writeScriptBin "rust-toolchain-versions" ''
              ${pkgs.rust-toolchain}/bin/cargo --version
              ${pkgs.rust-toolchain}/bin/rustc --version
            '';
          };
        };
    };
}
