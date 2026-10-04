{
  nixpkgs,
  system,
}: let
  pkgs = nixpkgs.legacyPackages.${system};
  mkRustPackage = name: path:
    pkgs.rustPlatform.buildRustPackage {
      pname = name;
      version = "0.1.0";
      src = ../../scripts/misc/${path};

      cargoLock = {
        lockFile = ../../scripts/misc/${path}/Cargo.lock;
      };
    };
in {
  ai_agent = mkRustPackage "ai_agent" "ai_agent";
  anki_tools = mkRustPackage "anki_tools" "anki_tools";
  clipboard_ssh = mkRustPackage "clipboard_ssh" "clipboard_ssh";
  keepass_reader = mkRustPackage "keepass-reader" "keepass-reader";
  provision_choose_config = mkRustPackage "provision_choose_config" "provision_choose_config";
}
