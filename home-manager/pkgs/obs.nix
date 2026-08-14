# =============================================================================
#  OBS Studio & Wayland Screen Capture Plugins
# =============================================================================
{
  config,
  pkgs,
  ...
}: {
  # ---------------------------------------------------------------------------
  # 🎥 OBS Studio Program & Hardware Plugins
  # ---------------------------------------------------------------------------
  programs.obs-studio = {
    enable = true;

    # Optional Nvidia CUDA hardware acceleration override
    # package = (
    #   pkgs.obs-studio.override {
    #     cudaSupport = true;
    #   }
    # );

    # OBS Plugins for Wayland, PipeWire and Hardware Encoding
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs # Wayland wlroots screen capture
      obs-backgroundremoval # AI background removal
      obs-pipewire-audio-capture # Direct PipeWire application audio grabber
      obs-vaapi # AMD GPU VA-API hardware video encoder
      obs-gstreamer # GStreamer pipeline input/output
      obs-vkcapture # Direct Vulkan / OpenGL game capture
    ];
  };
}
