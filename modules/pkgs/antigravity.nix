# =============================================================================
#  Antigravity CLI Package (pkgs/antigravity.nix)
#  Custom derivation wrapping the upstream standalone Linux binary
# =============================================================================
{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}: let
  version = "1.1.13";
  url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.13-6057583128215552/linux-x64/cli_linux_x64.tar.gz";
  hash = "sha512-icaIG2wZmcuCNucYHCGSro83KwQTOWwPe8/4PSesnAzBICeVzA1insHsv0k30cKUz09eT5+OBbHpcuJxmDE0Qg==";
in
  stdenv.mkDerivation {
    pname = "antigravity-cli";
    inherit version;

    src = fetchurl {
      inherit url hash;
    };

    sourceRoot = ".";

    nativeBuildInputs = [
      autoPatchelfHook
    ];

    buildInputs = [
      stdenv.cc.cc.lib
    ];

    installPhase = ''
      runHook preInstall
      install -m755 -D antigravity $out/bin/agy
      runHook postInstall
    '';

    meta = with lib; {
      description = "Antigravity CLI (agy) - Agentic AI Coding Assistant";
      homepage = "https://antigravity.google";
      mainProgram = "agy";
      platforms = platforms.linux;
    };
  }
