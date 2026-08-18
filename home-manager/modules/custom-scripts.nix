# =============================================================================
#  Dynamic User Binary Packager (user/bin-rs/target/release -> home.packages)
# =============================================================================
{
  pkgs,
  lib,
  ...
}: let
  userBinRs = ../../user/bin-rs/target/release;

  # Helper to package a directory of compiled release binaries
  packageDir = dir:
    if builtins.pathExists dir
    then let
      raw = builtins.readDir dir;
      files =
        lib.filterAttrs (
          name: type:
            type
            == "regular"
            && !(lib.hasPrefix "." name)
            && !(lib.hasSuffix ".d" name)
            && !(lib.hasSuffix ".rlib" name)
            && !(lib.hasSuffix ".lock" name)
        )
        raw;
    in
      lib.mapAttrsToList (
        name: _:
          pkgs.runCommand name {} ''
            mkdir -p $out/bin
            cp "${dir}/${name}" $out/bin/${name}
            chmod +x $out/bin/${name}
          ''
      )
      files
    else [];

  customPackages = packageDir userBinRs;
in {
  # ---------------------------------------------------------------------------
  # 📦 Custom User Packages
  # ---------------------------------------------------------------------------
  home.packages = customPackages;
}
