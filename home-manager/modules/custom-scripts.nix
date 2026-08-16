# =============================================================================
#  Dynamic User Script Packager (scripts/*.sh -> home.packages)
# =============================================================================
{
  pkgs,
  lib,
  ...
}: let
  scriptsDir = ../scripts;

  # Read all files in scripts/ and filter strictly for regular *.sh files
  rawFiles = builtins.readDir scriptsDir;
  scriptFiles = lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".sh" name) rawFiles;

  # Create derivations strictly preserving the exact filename with `.sh`
  # (e.g. power-menu.sh, sleep.sh, clipboard.sh to prevent collisions with system binaries like 'sleep')
  mkScriptPkg = fileName:
    pkgs.writeShellScriptBin fileName (builtins.readFile (scriptsDir + "/${fileName}"));

  customScriptPackages = lib.mapAttrsToList (name: _: mkScriptPkg name) scriptFiles;
in {
  # ---------------------------------------------------------------------------
  # 📦 Custom User Script Packages
  # ---------------------------------------------------------------------------
  home.packages = customScriptPackages;
}
