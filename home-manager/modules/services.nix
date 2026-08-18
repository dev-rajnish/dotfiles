# =============================================================================
#  Home Manager User Services & Daemons
# =============================================================================
{
  # ---------------------------------------------------------------------------
  # 📡 User Service Enablements
  # ---------------------------------------------------------------------------
  services = {
    # Wayle Wayland status bar daemon
    wayle.autoInstallDependencies = true;
  };

  # Suggest restarts for modified user services instead of automatically restarting
  systemd.user.startServices = "suggest";
}
