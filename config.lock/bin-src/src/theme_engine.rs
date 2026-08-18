use colored::Colorize;
use rand::seq::IndexedRandom;
use std::collections::HashMap;
use std::fs;
use std::path::Path;

use crate::models::{AppearanceConfig, CurrentThemeState, PaletteColors, ThemeDefinition};
use crate::paths::{
    find_appearance_file, find_current_theme_file, find_themes_dir, get_config_dir,
    write_to_config_and_live,
};
use crate::populator::AppearancePopulator;
use crate::process_runner::{notify, reload_desktop_apps};
use crate::themes_db::get_builtin_themes;

pub struct ThemeEngine;

impl ThemeEngine {
    pub fn load_appearance_config() -> AppearanceConfig {
        let file = find_appearance_file();
        if file.exists() {
            if let Ok(content) = fs::read_to_string(&file) {
                if let Ok(config) = toml::from_str::<AppearanceConfig>(&content) {
                    return config;
                }
            }
        }
        AppearanceConfig::default()
    }

    pub fn save_appearance_config(config: &AppearanceConfig) -> anyhow::Result<()> {
        let content = toml::to_string_pretty(config)?;
        write_to_config_and_live("0-apperance/appearance.toml", &content)?;
        Ok(())
    }

    pub fn load_all_themes() -> Vec<ThemeDefinition> {
        let mut map: HashMap<String, ThemeDefinition> = HashMap::new();

        // 1. Built-in themes
        for t in get_builtin_themes() {
            map.insert(t.name.to_lowercase(), t);
        }

        // 2. Custom TOML themes in themes directory
        let themes_dir = find_themes_dir();
        if themes_dir.exists() && themes_dir.is_dir() {
            if let Ok(entries) = fs::read_dir(&themes_dir) {
                for entry in entries.flatten() {
                    let path = entry.path();
                    if path.is_file() && path.extension().and_then(|e| e.to_str()) == Some("toml") {
                        if let Ok(content) = fs::read_to_string(&path) {
                            if let Ok(custom_theme) = toml::from_str::<ThemeDefinition>(&content) {
                                map.insert(custom_theme.name.to_lowercase(), custom_theme);
                            }
                        }
                    }
                }
            }
        }

        // 3. Wallust JSON colorschemes in ~/.config/wallust/colorschemes
        let wallust_dir = get_config_dir().join("wallust/colorschemes");
        if wallust_dir.exists() && wallust_dir.is_dir() {
            if let Ok(entries) = fs::read_dir(&wallust_dir) {
                for entry in entries.flatten() {
                    let path = entry.path();
                    if path.is_file() {
                        let ext = path.extension().and_then(|e| e.to_str());
                        if ext == Some("json") || ext == Some("jsonc") {
                            let stem = path.file_stem().and_then(|s| s.to_str()).unwrap_or("custom");
                            if stem == "stylix" {
                                continue;
                            }
                            if let Ok(theme) = Self::parse_wallust_json_file(&path, stem) {
                                map.insert(theme.name.to_lowercase(), theme);
                            }
                        }
                    }
                }
            }
        }

        let mut list: Vec<ThemeDefinition> = map.into_values().collect();
        list.sort_by(|a, b| a.name.cmp(&b.name));
        list
    }

    fn parse_wallust_json_file(path: &Path, name: &str) -> anyhow::Result<ThemeDefinition> {
        let content = fs::read_to_string(path)?;
        let val: serde_json::Value = serde_json::from_str(&content)?;

        let bg = val["special"]["background"].as_str().unwrap_or("#1e1e2e").to_string();
        let fg = val["special"]["foreground"].as_str().unwrap_or("#cdd6f4").to_string();
        let cursor = val["special"]["cursor"].as_str().unwrap_or(&fg).to_string();
        let accent = val["colors"]["color4"].as_str().unwrap_or("#89b4fa").to_string();

        let get_c = |k: &str, def: &str| -> String {
            val["colors"][k].as_str().unwrap_or(def).to_string()
        };

        let colors = PaletteColors {
            background: bg,
            foreground: fg,
            cursor,
            accent,
            color0: get_c("color0", "#1e1e2e"),
            color1: get_c("color1", "#f38ba8"),
            color2: get_c("color2", "#a6e3a1"),
            color3: get_c("color3", "#f9e2af"),
            color4: get_c("color4", "#89b4fa"),
            color5: get_c("color5", "#cba6f7"),
            color6: get_c("color6", "#94e2d5"),
            color7: get_c("color7", "#cdd6f4"),
            color8: get_c("color8", "#6c7086"),
            color9: get_c("color9", "#f38ba8"),
            color10: get_c("color10", "#a6e3a1"),
            color11: get_c("color11", "#fab387"),
            color12: get_c("color12", "#89b4fa"),
            color13: get_c("color13", "#cba6f7"),
            color14: get_c("color14", "#94e2d5"),
            color15: get_c("color15", "#b4befe"),
        };

        Ok(ThemeDefinition {
            name: name.to_string(),
            display_name: Some(name.replace('-', " ")),
            polarity: "dark".to_string(),
            colors,
        })
    }

    pub fn get_current_theme_name() -> String {
        let cur_file = find_current_theme_file();
        if cur_file.exists() {
            if let Ok(content) = fs::read_to_string(&cur_file) {
                if let Ok(state) = serde_json::from_str::<CurrentThemeState>(&content) {
                    if !state.name.is_empty() {
                        return state.name;
                    }
                }
            }
        }

        let config = Self::load_appearance_config();
        config.theme.active
    }

    pub fn find_theme(query: &str) -> Option<ThemeDefinition> {
        let query_clean = query.trim().to_lowercase().replace(' ', "-");
        let all = Self::load_all_themes();

        // 1. Exact match on name
        for t in &all {
            if t.name.to_lowercase() == query_clean {
                return Some(t.clone());
            }
        }

        // 2. Exact match on display_name
        for t in &all {
            if let Some(disp) = &t.display_name {
                if disp.to_lowercase() == query.trim().to_lowercase() {
                    return Some(t.clone());
                }
            }
        }

        // 3. Substring match
        for t in &all {
            if t.name.to_lowercase().contains(&query_clean) {
                return Some(t.clone());
            }
            if let Some(disp) = &t.display_name {
                if disp.to_lowercase().contains(&query.trim().to_lowercase()) {
                    return Some(t.clone());
                }
            }
        }

        None
    }

    pub fn apply_theme(name_or_query: &str, reload: bool) -> anyhow::Result<ThemeDefinition> {
        let theme = Self::find_theme(name_or_query)
            .ok_or_else(|| anyhow::anyhow!("Theme '{}' not found. Run 'theme-switcher --list' to see available themes.", name_or_query))?;

        let mut appearance = Self::load_appearance_config();
        appearance.theme.active = theme.name.clone();
        appearance.theme.polarity = theme.polarity.clone();

        // 1. Save updated appearance configuration
        Self::save_appearance_config(&appearance)?;

        // 2. Save current theme state JSON
        let state = CurrentThemeState {
            name: theme.name.clone(),
            display_name: theme.display_name.clone().unwrap_or_else(|| theme.name.clone()),
            polarity: theme.polarity.clone(),
            updated_at: chrono_like_timestamp(),
        };
        let state_str = serde_json::to_string_pretty(&state)?;
        write_to_config_and_live("0-apperance/current_theme.json", &state_str)?;

        // 3. Render appearance and theme tokens across kitty, fuzzel, colors, wlogout, wayle, labwc, niri, swaylock
        AppearancePopulator::populate_appearance(&appearance)?;
        AppearancePopulator::populate_theme_tokens(&theme.colors, &appearance)?;

        // 4. If Wallust is present, execute wallust cs
        let stylix_json = get_config_dir().join("wallust/colorschemes/stylix.jsonc");
        if stylix_json.exists() {
            let _ = std::process::Command::new("wallust")
                .arg("cs")
                .arg(&stylix_json)
                .output();
        }

        // 5. Reload apps and send notification
        if reload {
            reload_desktop_apps();
            let disp = theme.display_name.as_deref().unwrap_or(&theme.name);
            notify(
                "🎨 Theme Switcher",
                &format!("Applied theme: {} ({})", disp, theme.polarity),
                Some("preferences-desktop-theme"),
            );
        }

        Ok(theme)
    }

    pub fn toggle_polarity() -> anyhow::Result<ThemeDefinition> {
        let current_name = Self::get_current_theme_name();
        let cur_theme = Self::find_theme(&current_name).unwrap_or_else(|| get_builtin_themes()[0].clone());

        let target_name = match cur_theme.name.as_str() {
            "catppuccin-mocha" | "catppuccin-macchiato" | "catppuccin-frappe" => "catppuccin-latte",
            "catppuccin-latte" => "catppuccin-mocha",
            "tokyo-night" | "tokyo-night-storm" | "tokyo-night-moon" => "tokyo-night-day",
            "tokyo-night-day" => "tokyo-night",
            "gruvbox-dark" => "gruvbox-light",
            "gruvbox-light" => "gruvbox-dark",
            "rose-pine" | "rose-pine-moon" => "rose-pine-dawn",
            "rose-pine-dawn" => "rose-pine",
            "everforest-dark" => "everforest-light",
            "everforest-light" => "everforest-dark",
            "solarized-dark" => "solarized-light",
            "solarized-light" => "solarized-dark",
            "ayu-dark" | "ayu-mirage" => "ayu-dark",
            _ => {
                if cur_theme.polarity == "dark" {
                    "catppuccin-latte"
                } else {
                    "catppuccin-mocha"
                }
            }
        };

        Self::apply_theme(target_name, true)
    }

    pub fn apply_random_theme() -> anyhow::Result<ThemeDefinition> {
        let cur_name = Self::get_current_theme_name();
        let all = Self::load_all_themes();
        let pool: Vec<&ThemeDefinition> = all.iter().filter(|t| t.name != cur_name).collect();

        let mut rng = rand::rng();
        if let Some(chosen) = pool.choose(&mut rng) {
            Self::apply_theme(&chosen.name, true)
        } else {
            Self::apply_theme(&all[0].name, true)
        }
    }

    pub fn print_theme_preview(theme: &ThemeDefinition) {
        let disp = theme.display_name.as_deref().unwrap_or(&theme.name);
        println!("\n{}", format!("━━━ {} ({}) ━━━", disp, theme.polarity).bold().cyan());
        println!("  Background: {}  Foreground: {}  Accent: {}",
            theme.colors.background.bold(),
            theme.colors.foreground.bold(),
            theme.colors.accent.bold()
        );

        let colors = [
            ("00", &theme.colors.color0),
            ("01", &theme.colors.color1),
            ("02", &theme.colors.color2),
            ("03", &theme.colors.color3),
            ("04", &theme.colors.color4),
            ("05", &theme.colors.color5),
            ("06", &theme.colors.color6),
            ("07", &theme.colors.color7),
            ("08", &theme.colors.color8),
            ("09", &theme.colors.color9),
            ("10", &theme.colors.color10),
            ("11", &theme.colors.color11),
            ("12", &theme.colors.color12),
            ("13", &theme.colors.color13),
            ("14", &theme.colors.color14),
            ("15", &theme.colors.color15),
        ];

        print!("  ");
        for (idx, hex) in &colors[0..8] {
            if let Some((r, g, b)) = hex_to_rgb(hex) {
                print!("\x1b[48;2;{};{};{}m  \x1b[0m ", r, g, b);
            } else {
                print!("{} ", idx);
            }
        }
        println!();

        print!("  ");
        for (idx, hex) in &colors[8..16] {
            if let Some((r, g, b)) = hex_to_rgb(hex) {
                print!("\x1b[48;2;{};{};{}m  \x1b[0m ", r, g, b);
            } else {
                print!("{} ", idx);
            }
        }
        println!("\n");
    }
}

fn hex_to_rgb(hex: &str) -> Option<(u8, u8, u8)> {
    let clean = hex.trim_start_matches('#');
    if clean.len() >= 6 {
        let r = u8::from_str_radix(&clean[0..2], 16).ok()?;
        let g = u8::from_str_radix(&clean[2..4], 16).ok()?;
        let b = u8::from_str_radix(&clean[4..6], 16).ok()?;
        return Some((r, g, b));
    }
    None
}

fn chrono_like_timestamp() -> String {
    use std::time::SystemTime;
    let now = SystemTime::now();
    let dur = now.duration_since(SystemTime::UNIX_EPOCH).unwrap_or_default();
    format!("{}_unix", dur.as_secs())
}
