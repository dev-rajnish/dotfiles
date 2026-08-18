//! Shared utilities for NixOS and dotfiles system management tools.
//! Built with strict error handling without `.unwrap()`.

use anyhow::{Context, Result};
use nix::unistd::User;
use std::env;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;

/// ANSI terminal color tokens for consistent CLI UI output.
pub mod colors {
    pub const HEADER: &str = "\x1b[95m";
    pub const BLUE: &str = "\x1b[94m";
    pub const CYAN: &str = "\x1b[96m";
    pub const GREEN: &str = "\x1b[92m";
    pub const YELLOW: &str = "\x1b[93m";
    pub const RED: &str = "\x1b[91m";
    pub const BOLD: &str = "\x1b[1m";
    pub const DIM: &str = "\x1b[2m";
    pub const RESET: &str = "\x1b[0m";
}

/// Locates the user's home directory.
pub fn home_dir() -> Result<PathBuf> {
    if let Ok(h) = env::var("HOME") {
        return Ok(PathBuf::from(h));
    }
    let user = User::from_uid(nix::unistd::getuid())
        .context("Failed to query current user information")?
        .context("No user entry found for current UID")?;
    Ok(user.dir)
}

/// Locates the root dotfiles repository directory containing `0-system-vars.nix`.
pub fn find_dotfiles_dir() -> Result<PathBuf> {
    if let Ok(dir_str) = env::var("DOTFILES_DIR") {
        let p = PathBuf::from(dir_str);
        if p.join("0-system-vars.nix").is_file() {
            return Ok(p);
        }
    }

    let home = home_dir()?;
    let candidates = [
        home.join("_ws/dotfiles"),
        home.join("dotfiles"),
        home.join(".dotfiles"),
    ];

    for candidate in &candidates {
        if candidate.join("0-system-vars.nix").is_file() {
            return Ok(candidate.clone());
        }
    }

    Ok(home.join("_ws/dotfiles"))
}

/// Locates the `0-system-vars.nix` file.
pub fn find_vars_file(dot_dir: &Path) -> Option<PathBuf> {
    for name in ["0-system-vars.nix", "0-system-var.nix"] {
        let p = dot_dir.join(name);
        if p.is_file() {
            return Some(p);
        }
    }
    None
}

/// Structured representation of global configuration variables in `0-system-vars.nix`.
#[derive(Debug, Clone)]
pub struct SystemVars {
    pub hostname: String,
    pub username: String,
    pub theme: String,
    pub polarity: String,
}

/// Extracts variables from `0-system-vars.nix` safely with regex.
pub fn extract_system_vars(dot_dir: &Path) -> Result<SystemVars> {
    let mut hostname = String::from("nixos");
    let mut username = env::var("USER").unwrap_or_else(|_| String::from("rsh"));
    let mut theme = String::from("catppuccin-mocha");
    let mut polarity = String::from("dark");

    if let Some(vars_file) = find_vars_file(dot_dir) {
        let content = fs::read_to_string(&vars_file)
            .with_context(|| format!("Failed to read {}", vars_file.display()))?;

        let re_host = regex::Regex::new(r#"hostname\s*=\s*"([^"]+)""#)?;
        if let Some(caps) = re_host.captures(&content) {
            if let Some(m) = caps.get(1) {
                hostname = m.as_str().to_string();
            }
        }

        let re_user = regex::Regex::new(r#"username\s*=\s*"([^"]+)""#)?;
        if let Some(caps) = re_user.captures(&content) {
            if let Some(m) = caps.get(1) {
                username = m.as_str().to_string();
            }
        }

        let re_theme = regex::Regex::new(r#"theme\s*=\s*"([^"]+)""#)?;
        if let Some(caps) = re_theme.captures(&content) {
            if let Some(m) = caps.get(1) {
                theme = m.as_str().to_string();
            }
        }

        let re_pol = regex::Regex::new(r#"polarity\s*=\s*"([^"]+)""#)?;
        if let Some(caps) = re_pol.captures(&content) {
            if let Some(m) = caps.get(1) {
                polarity = m.as_str().to_string();
            }
        }
    }

    Ok(SystemVars {
        hostname,
        username,
        theme,
        polarity,
    })
}

/// Spawns a background process detached from the current session using `nix::unistd::setsid`
/// or `std::os::unix::process::CommandExt`.
pub fn spawn_detached(program: &str, args: &[&str]) -> Result<u32> {
    use std::os::unix::process::CommandExt;
    use std::process::Stdio;

    let mut cmd = Command::new(program);
    cmd.args(args)
        .stdin(Stdio::null())
        .stdout(Stdio::null())
        .stderr(Stdio::null());

    unsafe {
        cmd.pre_exec(|| {
            // Detach child into a new session
            let _ = nix::unistd::setsid();
            Ok(())
        });
    }

    let child = cmd
        .spawn()
        .with_context(|| format!("Failed to spawn detached process '{}'", program))?;

    Ok(child.id())
}

/// Helper for logging formatted messages with immediate stdout flushing.
pub fn log_info(msg: &str) {
    use std::io::Write;
    print!("{}::{} {}\n", colors::CYAN, colors::RESET, msg);
    let _ = std::io::stdout().flush();
}

pub fn log_success(msg: &str) {
    use std::io::Write;
    print!("{}✔{} {}\n", colors::GREEN, colors::RESET, msg);
    let _ = std::io::stdout().flush();
}

pub fn log_warn(msg: &str) {
    use std::io::Write;
    eprint!("{}⚠{} {}\n", colors::YELLOW, colors::RESET, msg);
    let _ = std::io::stderr().flush();
}

pub fn log_error(msg: &str) {
    use std::io::Write;
    eprint!("{}✖ Error:{} {}\n", colors::RED, colors::RESET, msg);
    let _ = std::io::stderr().flush();
}
