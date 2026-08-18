use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AppearanceConfig {
    #[serde(default)]
    pub fonts: FontConfig,
    #[serde(default)]
    pub appearance: GeometryConfig,
    #[serde(default)]
    pub theme: ThemeMetaConfig,
}

impl Default for AppearanceConfig {
    fn default() -> Self {
        Self {
            fonts: FontConfig::default(),
            appearance: GeometryConfig::default(),
            theme: ThemeMetaConfig::default(),
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FontConfig {
    #[serde(default)]
    pub mono: MonoFontConfig,
    #[serde(default)]
    pub sans: NamedFontConfig,
    #[serde(default)]
    pub serif: NamedFontConfig,
    #[serde(default)]
    pub emoji: EmojiFontConfig,
    #[serde(default)]
    pub sizes: FontSizesConfig,
}

impl Default for FontConfig {
    fn default() -> Self {
        Self {
            mono: MonoFontConfig::default(),
            sans: NamedFontConfig::default(),
            serif: NamedFontConfig::default(),
            emoji: EmojiFontConfig::default(),
            sizes: FontSizesConfig::default(),
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MonoFontConfig {
    #[serde(default = "default_mono_family")]
    pub family: String,
    #[serde(default)]
    pub italic_family: String,
    #[serde(default)]
    pub features: String,
}

fn default_mono_family() -> String {
    "JetBrainsMono Nerd Font".to_string()
}

impl Default for MonoFontConfig {
    fn default() -> Self {
        Self {
            family: default_mono_family(),
            italic_family: default_mono_family(),
            features: "".to_string(),
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct NamedFontConfig {
    #[serde(default = "default_inter_family")]
    pub family: String,
    #[serde(default = "default_font_style")]
    pub style: String,
}

fn default_inter_family() -> String {
    "Inter".to_string()
}

fn default_font_style() -> String {
    "Regular".to_string()
}

impl Default for NamedFontConfig {
    fn default() -> Self {
        Self {
            family: default_inter_family(),
            style: default_font_style(),
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct EmojiFontConfig {
    #[serde(default = "default_emoji_family")]
    pub family: String,
}

fn default_emoji_family() -> String {
    "Noto Color Emoji".to_string()
}

impl Default for EmojiFontConfig {
    fn default() -> Self {
        Self {
            family: default_emoji_family(),
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FontSizesConfig {
    #[serde(default = "default_terminal_size")]
    pub terminal: f64,
    #[serde(default = "default_bar_size")]
    pub bar: f64,
    #[serde(default = "default_launcher_size")]
    pub launcher: f64,
    #[serde(default = "default_desktop_size")]
    pub desktop: f64,
    #[serde(default = "default_power_menu_size")]
    pub power_menu: f64,
    #[serde(default = "default_fastfetch_size")]
    pub fastfetch_logo: f64,
}

fn default_terminal_size() -> f64 { 16.0 }
fn default_bar_size() -> f64 { 12.0 }
fn default_launcher_size() -> f64 { 18.0 }
fn default_desktop_size() -> f64 { 12.0 }
fn default_power_menu_size() -> f64 { 14.0 }
fn default_fastfetch_size() -> f64 { 18.0 }

impl Default for FontSizesConfig {
    fn default() -> Self {
        Self {
            terminal: default_terminal_size(),
            bar: default_bar_size(),
            launcher: default_launcher_size(),
            desktop: default_desktop_size(),
            power_menu: default_power_menu_size(),
            fastfetch_logo: default_fastfetch_size(),
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GeometryConfig {
    #[serde(default = "default_border_radius")]
    pub border_radius: u32,
    #[serde(default = "default_border_width")]
    pub border_width: u32,
    #[serde(default = "default_icon_theme")]
    pub icon_theme: String,
    #[serde(default)]
    pub gaps: GapsConfig,
    #[serde(default)]
    pub opacity: OpacityConfig,
    #[serde(default)]
    pub cursor: CursorConfig,
}

fn default_border_radius() -> u32 { 0 }
fn default_border_width() -> u32 { 1 }
fn default_icon_theme() -> String { "Tela-circle-dark".to_string() }

impl Default for GeometryConfig {
    fn default() -> Self {
        Self {
            border_radius: default_border_radius(),
            border_width: default_border_width(),
            icon_theme: default_icon_theme(),
            gaps: GapsConfig::default(),
            opacity: OpacityConfig::default(),
            cursor: CursorConfig::default(),
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GapsConfig {
    #[serde(default = "default_gap_inner")]
    pub inner: u32,
    #[serde(default = "default_gap_outer")]
    pub outer: u32,
    #[serde(default = "default_gap_bar")]
    pub bar_gap: u32,
}

fn default_gap_inner() -> u32 { 6 }
fn default_gap_outer() -> u32 { 6 }
fn default_gap_bar() -> u32 { 2 }

impl Default for GapsConfig {
    fn default() -> Self {
        Self {
            inner: default_gap_inner(),
            outer: default_gap_outer(),
            bar_gap: default_gap_bar(),
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct OpacityConfig {
    #[serde(default = "default_terminal_opacity")]
    pub terminal: f64,
    #[serde(default = "default_bar_opacity")]
    pub bar: f64,
    #[serde(default = "default_overlay_opacity")]
    pub overlay: f64,
}

fn default_terminal_opacity() -> f64 { 0.95 }
fn default_bar_opacity() -> f64 { 0.90 }
fn default_overlay_opacity() -> f64 { 0.88 }

impl Default for OpacityConfig {
    fn default() -> Self {
        Self {
            terminal: default_terminal_opacity(),
            bar: default_bar_opacity(),
            overlay: default_overlay_opacity(),
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CursorConfig {
    #[serde(default = "default_cursor_name")]
    pub name: String,
    #[serde(default = "default_cursor_size")]
    pub size: u32,
}

fn default_cursor_name() -> String { "Bibata-Modern-Ice".to_string() }
fn default_cursor_size() -> u32 { 32 }

impl Default for CursorConfig {
    fn default() -> Self {
        Self {
            name: default_cursor_name(),
            size: default_cursor_size(),
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ThemeMetaConfig {
    #[serde(default = "default_active_theme")]
    pub active: String,
    #[serde(default = "default_polarity")]
    pub polarity: String,
}

fn default_active_theme() -> String { "catppuccin-mocha".to_string() }
fn default_polarity() -> String { "dark".to_string() }

impl Default for ThemeMetaConfig {
    fn default() -> Self {
        Self {
            active: default_active_theme(),
            polarity: default_polarity(),
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ThemeDefinition {
    pub name: String,
    #[serde(default)]
    pub display_name: Option<String>,
    #[serde(default = "default_polarity")]
    pub polarity: String,
    pub colors: PaletteColors,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PaletteColors {
    pub background: String,
    pub foreground: String,
    #[serde(default = "default_cursor_color")]
    pub cursor: String,
    #[serde(default = "default_accent_color")]
    pub accent: String,

    pub color0: String,
    pub color1: String,
    pub color2: String,
    pub color3: String,
    pub color4: String,
    pub color5: String,
    pub color6: String,
    pub color7: String,
    pub color8: String,
    pub color9: String,
    pub color10: String,
    pub color11: String,
    pub color12: String,
    pub color13: String,
    pub color14: String,
    pub color15: String,
}

fn default_cursor_color() -> String { "#cdd6f4".to_string() }
fn default_accent_color() -> String { "#89b4fa".to_string() }

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CurrentThemeState {
    pub name: String,
    pub display_name: String,
    pub polarity: String,
    pub updated_at: String,
}
