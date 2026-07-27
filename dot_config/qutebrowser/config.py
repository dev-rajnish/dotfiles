# =============================================================================
#  Qutebrowser Configuration (Python)
# =============================================================================

# 1. Autoconfig Loading (False ensures config.py overrides autoconfig.yml)
config.load_autoconfig(False)

# 2. Theme Integration
config.source('theme.py')

# 3. Fonts & Typography
c.fonts.default_size = "14pt"
c.fonts.default_family = ["JetBrains Mono", "DejaVu Sans Mono", "monospace"]

c.fonts.web.size.default = 18
c.fonts.web.size.default_fixed = 15
c.fonts.web.size.minimum = 13

# 4. Global Dark Mode Preferences
c.colors.webpage.preferred_color_scheme = "dark"
c.colors.webpage.darkmode.enabled = False

# 5. Domain-Specific Dark Mode Overrides
# Disable darkmode forcing for WhatsApp Web to preserve native web layout
config.set('colors.webpage.darkmode.enabled', False, 'https://web.whatsapp.com/*')
config.set('colors.webpage.darkmode.enabled', False, 'https://*.whatsapp.com/*')

# 6. Adblocking & Content Filtering
c.content.blocking.method = "both"

# 7. Tab Bar & Window Interface
c.tabs.position = "top"
c.tabs.show = "always"

# 8. Navigation & Session Preferences
c.confirm_quit = ["downloads"]
c.auto_save.session = True
