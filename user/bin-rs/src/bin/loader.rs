//! Fish Shell Environment, Path & Abbreviation Loader in Rust
//! Parses ~/.config/shell/{path.kv, env.kv, alias.kv} and outputs Fish commands.
//! Validates binaries via `which` and paths via `std::path::Path`.
//! Emits dynamic Distrobox/Podman container integration functions.

use anyhow::{Context, Result};
use clap::Parser;
use serde::Serialize;
use std::collections::HashSet;
use std::fs::File;
use std::io::{BufRead, BufReader};
use std::path::{Path, PathBuf};
use std::process::Command;
use sys_tools::{colors, find_dotfiles_dir, home_dir};

const SHELL_BUILTINS: &[&str] = &[
    "exit", "cd", "clear", "set", "echo", "type", "source", "exec", "eval",
    "test", "abbr", "alias", "builtin", "command", "contains", "count",
    "history", "jobs", "read", "status", "string", "functions", "funcsave",
    "dev_env", "home-manager", "host", "distrobox_aliases", "wallpaper", "dot",
];

#[derive(Parser, Debug)]
#[command(name = "loader", about = "Fish Shell Environment & Path Loader (Rust)")]
struct Args {
    #[arg(long, short = 'c', help = "Validate KV files and display diagnostics")]
    check: bool,

    #[arg(long, short = 's', help = "Print summary statistics of loaded items")]
    stats: bool,

    #[arg(long, short = 'j', help = "Output configuration as structured JSON")]
    json: bool,
}

#[derive(Debug, Default, Serialize)]
struct ShellConfig {
    paths: Vec<String>,
    env_vars: Vec<(String, String)>,
    abbreviations: Vec<(String, String)>,
    container_functions: Vec<String>,
}

fn resolve_shell_dir() -> Result<PathBuf> {
    let home = home_dir()?;
    let candidates = [
        home.join("_ws/dotfiles/user"),
        home.join("dotfiles/user"),
        home.join(".config/shell"),
        home.join("_ws/dotfiles/config.live/shell"),
        home.join("_ws/dotfiles/config.lock/shell"),
        home.join("dotfiles/config.live/shell"),
        home.join("dotfiles/config.lock/shell"),
    ];

    for c in &candidates {
        if c.is_dir() && c.join("alias.kv").is_file() {
            return Ok(c.clone());
        }
    }
    for c in &candidates {
        if c.is_dir() {
            return Ok(c.clone());
        }
    }
    Ok(candidates[0].clone())
}

fn expand_tilde(p: &str, home: &Path) -> PathBuf {
    if let Some(stripped) = p.strip_prefix("~/") {
        home.join(stripped)
    } else if p == "~" {
        home.to_path_buf()
    } else {
        PathBuf::from(p)
    }
}

fn parse_kv(file_path: &Path) -> Result<Vec<(String, String)>> {
    if !file_path.is_file() {
        return Ok(Vec::new());
    }

    let file = File::open(file_path)
        .with_context(|| format!("Failed to open {}", file_path.display()))?;
    let reader = BufReader::new(file);
    let mut entries = Vec::new();

    for line in reader.lines() {
        let line = line?;
        let trimmed = line.trim();
        if trimmed.is_empty() || trimmed.starts_with('#') {
            continue;
        }

        if let Some((key, val)) = trimmed.split_once('=') {
            let k = key.trim().to_string();
            let mut v = val.trim().to_string();
            if (v.starts_with('"') && v.ends_with('"')) || (v.starts_with('\'') && v.ends_with('\'')) {
                v = v[1..v.len() - 1].to_string();
            }
            if !k.is_empty() && !v.is_empty() {
                entries.push((k, v));
            }
        }
    }

    Ok(entries)
}

fn parse_path_lines(file_path: &Path, home: &Path) -> Result<Vec<String>> {
    if !file_path.is_file() {
        return Ok(Vec::new());
    }

    let file = File::open(file_path)
        .with_context(|| format!("Failed to open {}", file_path.display()))?;
    let reader = BufReader::new(file);
    let mut valid_paths = Vec::new();

    for line in reader.lines() {
        let line = line?;
        let trimmed = line.trim();
        if trimmed.is_empty() || trimmed.starts_with('#') {
            continue;
        }

        let expanded = expand_tilde(trimmed, home);
        if expanded.is_dir() {
            if let Some(s) = expanded.to_str() {
                valid_paths.push(s.to_string());
            }
        }
    }

    Ok(valid_paths)
}

fn is_command_installed(cmd_str: &str, builtins: &HashSet<&str>) -> bool {
    let parts: Vec<&str> = cmd_str.split_whitespace().collect();
    if parts.is_empty() {
        return false;
    }
    let binary = parts[0];

    if builtins.contains(binary) {
        return true;
    }

    which::which(binary).is_ok()
}

fn validate_alias(val: &str, home: &Path, builtins: &HashSet<&str>) -> bool {
    let mut val_clean = val.trim();
    if (val_clean.starts_with('"') && val_clean.ends_with('"')) || (val_clean.starts_with('\'') && val_clean.ends_with('\'')) {
        val_clean = &val_clean[1..val_clean.len() - 1];
    }

    // Case 1: cd command
    if let Some(rest) = val_clean.strip_prefix("cd ") {
        let mut target = rest.trim();
        if (target.starts_with('"') && target.ends_with('"')) || (target.starts_with('\'') && target.ends_with('\'')) {
            target = &target[1..target.len() - 1];
        }
        let exp = expand_tilde(target, home);
        return exp.is_dir();
    }

    // Case 2: File or folder exists
    let exp_val = expand_tilde(val_clean, home);
    if exp_val.exists() {
        return true;
    }

    // Case 3: Executable command validation
    is_command_installed(val_clean, builtins)
}

fn detect_distrobox_functions(builtins: &HashSet<&str>) -> Vec<String> {
    let mut out = Vec::new();
    let in_container = Path::new("/run/.containerenv").exists() || Path::new("/.dockerenv").exists();

    if in_container {
        out.push(
            "function host --description \"Execute command on the host system\"\n\
             \x20   if type -q distrobox-host-exec\n\
             \x20       distrobox-host-exec $argv\n\
             \x20   else\n\
             \x20       $argv\n\
             \x20   end\n\
             end".to_string()
        );
    } else if which::which("podman").is_ok() && which::which("distrobox").is_ok() {
        if let Ok(output) = Command::new("podman")
            .args(["ps", "-a", "--format", "{{.Names}}"])
            .output()
        {
            if let Ok(names_str) = String::from_utf8(output.stdout) {
                for box_name in names_str.lines() {
                    let b = box_name.trim();
                    if !b.is_empty() && which::which(b).is_err() && !builtins.contains(b) {
                        let fn_def = format!(
                            "function {} --description \"Enter distrobox container: {}\"\n\
                             \x20   if test (count $argv) -gt 0\n\
                             \x20       distrobox enter {} -- $argv\n\
                             \x20   else\n\
                             \x20       distrobox enter {}\n\
                             \x20   end\n\
                             end",
                            b, b, b, b
                        );
                        out.push(fn_def);
                    }
                }
            }
        }
    }

    out
}

fn collect_shell_config() -> Result<ShellConfig> {
    let home = home_dir()?;
    let shell_dir = resolve_shell_dir()?;
    let mut cfg = ShellConfig::default();

    let builtins: HashSet<&str> = SHELL_BUILTINS.iter().copied().collect();

    // 1. Paths from path.kv
    let path_file = shell_dir.join("path.kv");
    let valid_paths = parse_path_lines(&path_file, &home)?;
    cfg.paths.extend(valid_paths);

    // Dynamic dotfiles script paths
    let script_candidates = [
        home.join("_ws/dotfiles/user/bin-sh"),
        home.join("dotfiles/user/bin-sh"),
        home.join("_ws/dotfiles/user/bin-rs/target/release"),
        home.join("dotfiles/user/bin-rs/target/release"),
        home.join("_ws/dotfiles/home-manager/scripts"),
        home.join("dotfiles/home-manager/scripts"),
        home.join("_ws/dotfiles/scripts"),
        home.join("dotfiles/scripts"),
        home.join(".dotfiles/scripts"),
    ];

    for s_dir in &script_candidates {
        if s_dir.is_dir() {
            if let Some(s) = s_dir.to_str() {
                cfg.paths.push(s.to_string());
            }
        }
    }

    // 2. Environment variables from env.kv
    let env_file = shell_dir.join("env.kv");
    for (k, v) in parse_kv(&env_file)? {
        let val_expanded = if v.starts_with('~') {
            expand_tilde(&v, &home).to_string_lossy().to_string()
        } else {
            v
        };
        cfg.env_vars.push((k, val_expanded));
    }

    // 3. Aliases from alias.kv
    let alias_file = shell_dir.join("alias.kv");
    for (k, v) in parse_kv(&alias_file)? {
        if validate_alias(&v, &home, &builtins) {
            cfg.abbreviations.push((k, v));
        }
    }

    // Dynamic dotfiles abbreviations
    if let Ok(dot_dir) = find_dotfiles_dir() {
        if dot_dir.is_dir() {
            let d_str = dot_dir.to_string_lossy();
            cfg.abbreviations.push((".d".to_string(), format!("cd {}/", d_str)));
            cfg.abbreviations.push((".c".to_string(), format!("cd {}/config.live/", d_str)));
            cfg.abbreviations.push((".h".to_string(), format!("cd {}/home-manager/", d_str)));
        }
    }

    // Dynamic wallpaper abbreviation
    let wall_candidates = [
        home.join("_ws/walls"),
        home.join("ws/walls"),
        home.join("Pictures/Wallpapers"),
    ];
    for w in &wall_candidates {
        if w.is_dir() {
            cfg.abbreviations.push((".w".to_string(), format!("cd {}/", w.display())));
            break;
        }
    }

    // 4. Distrobox functions
    cfg.container_functions = detect_distrobox_functions(&builtins);

    Ok(cfg)
}

fn generate_fish_code(cfg: &ShellConfig) -> String {
    let mut out = Vec::new();

    for p in &cfg.paths {
        out.push(format!("fish_add_path -g -p \"{}\"", p));
    }

    for (k, v) in &cfg.env_vars {
        out.push(format!("set -gx {} \"{}\"", k, v));
    }

    for (k, v) in &cfg.abbreviations {
        out.push(format!("abbr -a {} -- \"{}\"", k, v));
    }

    for fn_code in &cfg.container_functions {
        out.push(fn_code.clone());
    }

    out.join("\n")
}

fn main() -> Result<()> {
    let args = Args::parse();
    let cfg = collect_shell_config()?;

    if args.json {
        let json_str = serde_json::to_string_pretty(&cfg)?;
        println!("{}", json_str);
        return Ok(());
    }

    if args.stats {
        println!("{}🐚 Shell Configuration Summary (Rust):{}", colors::BOLD, colors::RESET);
        println!("  • Paths Added:        {}", cfg.paths.len());
        println!("  • Environment Vars:   {}", cfg.env_vars.len());
        println!("  • Abbreviations:      {}", cfg.abbreviations.len());
        println!("  • Container Handlers: {}", cfg.container_functions.len());
        return Ok(());
    }

    if args.check {
        let shell_dir = resolve_shell_dir()?;
        println!("{}🔍 Testing Shell Configuration Loader (Rust):{}", colors::CYAN, colors::RESET);
        println!("  Config Directory: {}", shell_dir.display());
        println!("  Found {} valid path entries:", cfg.paths.len());
        for p in &cfg.paths {
            println!("    {} [OK] {}", colors::GREEN, p);
        }
        println!("  Found {} environment variables:", cfg.env_vars.len());
        for (k, v) in &cfg.env_vars {
            println!("    {} [ENV] {} = {}{}", colors::CYAN, k, v, colors::RESET);
        }
        println!("  Found {} validated abbreviations:", cfg.abbreviations.len());
        for (k, v) in &cfg.abbreviations {
            println!("    {} [ABBR] {} -> {}{}", colors::YELLOW, k, v, colors::RESET);
        }
        return Ok(());
    }

    // Default output for Fish shell source evaluation
    println!("{}", generate_fish_code(&cfg));
    Ok(())
}
