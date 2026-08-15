# =============================================================================
#  Timezone & Internationalization (i18n) Configuration
# =============================================================================
{
  # System Timezone
  time.timeZone = "Asia/Kolkata";

  # ---------------------------------------------------------------------------
  # 🌐 Locale & Regional Preferences
  # ---------------------------------------------------------------------------
  # Global Language Environment Variables
  environment.variables = {
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
  };

  # Regional
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_IN";
      LC_IDENTIFICATION = "en_IN";
      LC_MEASUREMENT = "en_IN";
      LC_MONETARY = "en_IN";
      LC_NAME = "en_IN";
      LC_NUMERIC = "en_IN";
      LC_PAPER = "en_IN";
      LC_TELEPHONE = "en_IN";
      LC_TIME = "en_IN";
    };
  };
}
