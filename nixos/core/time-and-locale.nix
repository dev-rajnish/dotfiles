# =============================================================================
#  Timezone & Internationalization (i18n) Configuration
# =============================================================================
{
  timeZone,
  defaultLocale,
  ...
}: {
  # System Timezone
  time.timeZone = timeZone;

  # ---------------------------------------------------------------------------
  # 🌐 Locale & Regional Preferences
  # ---------------------------------------------------------------------------
  # Global Language Environment Variables
  environment.variables = {
    LANG = defaultLocale;
    LC_ALL = defaultLocale;
  };

  # Regional
  i18n = {
    defaultLocale = defaultLocale;
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
