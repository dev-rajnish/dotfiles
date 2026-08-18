# =============================================================================
#  Timezone & Internationalization (i18n) Configuration
# =============================================================================
{env, ...}: {
  # System Timezone
  time.timeZone = env.timeZone;

  # ---------------------------------------------------------------------------
  # 🌐 Locale & Regional Preferences
  # ---------------------------------------------------------------------------
  # Global Language Environment Variables
  environment.variables = {
    LANG = env.defaultLocale;
    LC_ALL = env.defaultLocale;
  };

  # Regional
  i18n = {
    defaultLocale = env.defaultLocale;
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
