{ self, inputs, lib, ... }: {
  imports = [
    inputs.devshell.flakeModule
  ];

  config.perSystem =
    { config
    , pkgs
    , ...
    }: {
      #imports = [
      #  inputs.git-hooks.flakeModule
      #];

      config.devshells.default = {
        imports = [
          "${inputs.devshell}/extra/language/c.nix"
          # "${inputs.devshell}/extra/language/rust.nix"
        ];

        commands = with pkgs; [
          # { package = rust-toolchain; category = "rust"; }
        ];

        language.c = {
          libraries = lib.optional pkgs.stdenv.isDarwin pkgs.libiconv;
        };

        env = [
	  { name = "LD_LIBRARY_PATH"; value = "$LD_LIBRARY_PATH:${ with pkgs; lib.makeLibraryPath [
            wayland
            libxkbcommon
            fontconfig
          ] }"; }
	];

	#shellHook = ''
	#  ${config.pre-commit.installationScript}
	#'';
      };

      #config.pre-commit.settings = {
      #  settings.rust.cargoManifestPath = "${self}/crate2nix/Cargo.toml";
      #  hooks = {
      #    # rust
      #    rustfmt.enable = true;
      #    clippy.enable = true;
      #    # nix
      #    nixpkgs-fmt.enable = true;
      #    # shell
      #    shellcheck.enable = true;
      #  };
      #};
    };
}
