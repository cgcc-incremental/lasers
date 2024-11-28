{ lib
, rustPlatform
}:
rustPlatform.buildRustPackage rec {
  pname = "lasers";
  version = "0.1.0";
  cargoLock.lockFile = ./Cargo.lock;
  src = lib.cleanSource ./.;
}
