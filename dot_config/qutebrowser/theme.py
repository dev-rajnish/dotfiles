# =============================================================================
#  Tokyo Night Dark Theme for Qutebrowser
#  Base16 Theme Adaptation
# =============================================================================

# Palette Definition (Tokyo Night Dark)
base00 = "#1a1b26"  # Background
base01 = "#16161e"  # Darker Background
base02 = "#2f3549"  # Selection / Highlight
base03 = "#444b6a"  # Comments / Muted
base04 = "#787c99"  # Dark Foreground
base05 = "#a9b1d6"  # Main Foreground
base06 = "#cbccd1"  # Light Foreground
base07 = "#d5d6db"  # Bright Foreground
base08 = "#c0caf5"  # Soft Blue
base09 = "#a9b1d6"  # Soft Cyan
base0A = "#0db9d7"  # Cyan / Teal
base0B = "#9ece6a"  # Green
base0C = "#b4f9f8"  # Light Cyan
base0D = "#2ac3de"  # Blue / Accent
base0E = "#bb9af7"  # Purple / Magenta
base0F = "#f7768e"  # Red / Warning

# -----------------------------------------------------------------------------
# 1. Completion Widget
# -----------------------------------------------------------------------------
c.colors.completion.fg = base05
c.colors.completion.odd.bg = base01
c.colors.completion.even.bg = base00
c.colors.completion.category.fg = base0A
c.colors.completion.category.bg = base00
c.colors.completion.category.border.top = base00
c.colors.completion.category.border.bottom = base00
c.colors.completion.item.selected.fg = base05
c.colors.completion.item.selected.bg = base02
c.colors.completion.item.selected.border.top = base02
c.colors.completion.item.selected.border.bottom = base02
c.colors.completion.item.selected.match.fg = base0B
c.colors.completion.match.fg = base0B
c.colors.completion.scrollbar.fg = base05
c.colors.completion.scrollbar.bg = base00

# -----------------------------------------------------------------------------
# 2. Context Menu
# -----------------------------------------------------------------------------
c.colors.contextmenu.disabled.bg = base01
c.colors.contextmenu.disabled.fg = base04
c.colors.contextmenu.menu.bg = base00
c.colors.contextmenu.menu.fg = base05
c.colors.contextmenu.selected.bg = base02
c.colors.contextmenu.selected.fg = base05

# -----------------------------------------------------------------------------
# 3. Downloads Bar
# -----------------------------------------------------------------------------
c.colors.downloads.bar.bg = base00
c.colors.downloads.start.fg = base00
c.colors.downloads.start.bg = base0D
c.colors.downloads.stop.fg = base00
c.colors.downloads.stop.bg = base0C
c.colors.downloads.error.fg = base08

# -----------------------------------------------------------------------------
# 4. Hints & Keyhints
# -----------------------------------------------------------------------------
c.colors.hints.fg = base00
c.colors.hints.bg = base0A
c.colors.hints.match.fg = base05

c.colors.keyhint.fg = base05
c.colors.keyhint.suffix.fg = base05
c.colors.keyhint.bg = base00

# -----------------------------------------------------------------------------
# 5. Messages & Alerts
# -----------------------------------------------------------------------------
c.colors.messages.error.fg = base00
c.colors.messages.error.bg = base08
c.colors.messages.error.border = base08

c.colors.messages.warning.fg = base00
c.colors.messages.warning.bg = base0E
c.colors.messages.warning.border = base0E

c.colors.messages.info.fg = base05
c.colors.messages.info.bg = base00
c.colors.messages.info.border = base00

# -----------------------------------------------------------------------------
# 6. Prompts
# -----------------------------------------------------------------------------
c.colors.prompts.fg = base05
c.colors.prompts.border = base00
c.colors.prompts.bg = base00
c.colors.prompts.selected.bg = base02
c.colors.prompts.selected.fg = base05

# -----------------------------------------------------------------------------
# 7. Status Bar
# -----------------------------------------------------------------------------
c.colors.statusbar.normal.fg = base0B
c.colors.statusbar.normal.bg = base00
c.colors.statusbar.insert.fg = base00
c.colors.statusbar.insert.bg = base0D
c.colors.statusbar.passthrough.fg = base00
c.colors.statusbar.passthrough.bg = base0C
c.colors.statusbar.private.fg = base00
c.colors.statusbar.private.bg = base01
c.colors.statusbar.command.fg = base05
c.colors.statusbar.command.bg = base00
c.colors.statusbar.command.private.fg = base05
c.colors.statusbar.command.private.bg = base00
c.colors.statusbar.caret.fg = base00
c.colors.statusbar.caret.bg = base0E
c.colors.statusbar.caret.selection.fg = base00
c.colors.statusbar.caret.selection.bg = base0D
c.colors.statusbar.progress.bg = base0D
c.colors.statusbar.url.fg = base05
c.colors.statusbar.url.error.fg = base08
c.colors.statusbar.url.hover.fg = base05
c.colors.statusbar.url.success.http.fg = base0C
c.colors.statusbar.url.success.https.fg = base0B
c.colors.statusbar.url.warn.fg = base0E

# -----------------------------------------------------------------------------
# 8. Tab Bar
# -----------------------------------------------------------------------------
c.colors.tabs.bar.bg = base00
c.colors.tabs.indicator.start = base0D
c.colors.tabs.indicator.stop = base0C
c.colors.tabs.indicator.error = base08
c.colors.tabs.odd.fg = base05
c.colors.tabs.odd.bg = base01
c.colors.tabs.even.fg = base05
c.colors.tabs.even.bg = base00
c.colors.tabs.pinned.even.bg = base0C
c.colors.tabs.pinned.even.fg = base07
c.colors.tabs.pinned.odd.bg = base0B
c.colors.tabs.pinned.odd.fg = base07
c.colors.tabs.pinned.selected.even.bg = base02
c.colors.tabs.pinned.selected.even.fg = base05
c.colors.tabs.pinned.selected.odd.bg = base02
c.colors.tabs.pinned.selected.odd.fg = base05
c.colors.tabs.selected.odd.fg = base05
c.colors.tabs.selected.odd.bg = base02
c.colors.tabs.selected.even.fg = base05
c.colors.tabs.selected.even.bg = base02

# -----------------------------------------------------------------------------
# 9. Webpage Default Background
# -----------------------------------------------------------------------------
c.colors.webpage.bg = base00
