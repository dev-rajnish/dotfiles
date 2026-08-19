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

  # ---------------------------------------------------------------------------
  # 🔄 Shoelace Auto-Render Systemd Service & Path Watcher
  # ---------------------------------------------------------------------------
  systemd.user = {
    # 1. Oneshot Service: Executes sl-render
    services.sl-render = {
      Unit = {
        Description = "Shoelace Template Renderer Service";
        Documentation = ["https://github.com/dev-rajnish/shoelace"];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "%h/.local/bin/sl-render";
      };
    };

    # 2. Path Watcher: Monitors ~/shoelace/config.live/shoelace for changes
    paths.sl-render = {
      Unit = {
        Description = "Watch Shoelace data, templates, and config for modifications";
      };
      Path = {
        PathModified = [
          "%h/shoelace/config.live/shoelace/data"
          "%h/shoelace/config.live/shoelace/data/shell"
          "%h/shoelace/config.live/shoelace/templates"
          "%h/shoelace/config.live/shoelace/shoelace.toml"
        ];
        PathChanged = [
          "%h/shoelace/config.live/shoelace/data"
          "%h/shoelace/config.live/shoelace/data/shell"
          "%h/shoelace/config.live/shoelace/templates"
          "%h/shoelace/config.live/shoelace/shoelace.toml"
        ];
        Unit = "sl-render.service";
      };
      Install = {
        WantedBy = ["default.target"];
      };
    };

    # Suggest restarts for modified user services instead of automatically restarting
    startServices = "suggest";
  };
}
