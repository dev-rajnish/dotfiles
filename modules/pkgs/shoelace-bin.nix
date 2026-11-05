# =============================================================================
#  Shoelace Bin Scripts Package (modules/pkgs/shoelace-bin.nix)
#  Installs all executable helper scripts from bin/ into the Nix store
# =============================================================================
{runCommandLocal}:
runCommandLocal "shoelace-bin" {} ''
  mkdir -p $out/bin
  cp -a ${../../bin}/* $out/bin/
  chmod +x $out/bin/*
''
