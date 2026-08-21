{ config,  lib, env, ...}:
let
  cfg = config.mySystem.hm.git;
in {
  options.mySystem.hm.git = {
    enable = lib.mkEnableOption "git config";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${env.username} = { config, ... }: (
    {
  # ---------------------------------------------------------------------------
  # 🐙 Git Configuration & Global Settings
  # ---------------------------------------------------------------------------
  programs.git = {
    enable = true;
    settings = {
      # User identity (Imported from env/system.toml)
      user = {
        name = env.ghUsername;
        email = env.ghEmail;
      };

      # Credential helper to cache logins
      credential = {
        helper = "store";
      };

      # Disable GUI askpass prompts in terminal
      core = {
        askPass = "";
      };
    };
  };
}
  );
  };
}
