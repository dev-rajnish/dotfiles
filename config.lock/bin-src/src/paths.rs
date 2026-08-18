use std::path::{Path, PathBuf};

pub fn get_config_dir() -> PathBuf {
    if let Ok(xdg) = std::env::var("XDG_CONFIG_HOME") {
        if !xdg.trim().is_empty() {
            return PathBuf::from(xdg);
        }
    }
    dirs::config_dir().unwrap_or_else(|| {
        let home = dirs::home_dir().unwrap_or_else(|| PathBuf::from("/home/rsh"));
        home.join(".config")
    })
}

pub fn get_home_dir() -> PathBuf {
    dirs::home_dir().unwrap_or_else(|| PathBuf::from("/home/rsh"))
}

pub fn get_dotfiles_dir() -> PathBuf {
    let home = get_home_dir();
    home.join("dot")
}

pub fn get_dotfiles_live_dir() -> PathBuf {
    let home = get_home_dir();
    home.join("dot/config.live")
}

pub fn find_env_dir() -> PathBuf {
    let candidates = vec![
        get_config_dir().join("env"),
        get_dotfiles_dir().join("env"),
        PathBuf::from("./env"),
    ];

    for path in candidates {
        if path.exists() && path.is_dir() {
            return path;
        }
    }

    get_config_dir().join("env")
}

pub fn find_appearance_file() -> PathBuf {
    let candidates = vec![
        get_config_dir().join("env/appearance.toml"),
        get_dotfiles_dir().join("env/appearance.toml"),
        PathBuf::from("./env/appearance.toml"),
        get_config_dir().join("appearance/appearance.toml"),
        get_dotfiles_live_dir().join("appearance/appearance.toml"),
        PathBuf::from("./config.live/appearance/appearance.toml"),
    ];

    for path in candidates {
        if path.exists() {
            return path;
        }
    }

    // Default target
    get_config_dir().join("env/appearance.toml")
}

pub fn find_theme_file() -> PathBuf {
    let candidates = vec![
        get_config_dir().join("env/theme.toml"),
        get_dotfiles_dir().join("env/theme.toml"),
        PathBuf::from("./env/theme.toml"),
    ];

    for path in candidates {
        if path.exists() {
            return path;
        }
    }

    get_config_dir().join("env/theme.toml")
}

pub fn find_themes_dir() -> PathBuf {
    let candidates = vec![
        get_config_dir().join("appearance/themes"),
        get_dotfiles_live_dir().join("appearance/themes"),
        PathBuf::from("./config.live/appearance/themes"),
        PathBuf::from("./appearance/themes"),
    ];

    for path in candidates {
        if path.exists() && path.is_dir() {
            return path;
        }
    }

    get_config_dir().join("appearance/themes")
}

pub fn find_current_theme_file() -> PathBuf {
    let candidates = vec![
        get_config_dir().join("appearance/current_theme.json"),
        get_dotfiles_live_dir().join("appearance/current_theme.json"),
        PathBuf::from("./config.live/appearance/current_theme.json"),
        PathBuf::from("./appearance/current_theme.json"),
    ];

    for path in candidates {
        if path.exists() {
            return path;
        }
    }

    get_config_dir().join("appearance/current_theme.json")
}

pub fn write_file_safe(path: &Path, content: &str) -> anyhow::Result<()> {
    if let Some(parent) = path.parent() {
        std::fs::create_dir_all(parent)?;
    }
    std::fs::write(path, content)?;
    Ok(())
}

/// Dual-write to both ~/.config and ~/dot/config.live if dotfiles exists
pub fn write_to_config_and_live(rel_subpath: &str, content: &str) -> anyhow::Result<()> {
    let target_config = get_config_dir().join(rel_subpath);
    write_file_safe(&target_config, content)?;

    let live_target = get_dotfiles_live_dir().join(rel_subpath);
    if live_target != target_config && get_dotfiles_live_dir().exists() {
        let _ = write_file_safe(&live_target, content);
    }

    Ok(())
}
