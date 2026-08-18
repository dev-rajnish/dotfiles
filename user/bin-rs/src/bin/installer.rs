//! NixOS & Dotfiles First-Time Bootstrap Installer (Rust)
//! Automates hardware detection (GPU, chassis, battery, timezone, user, hostname),
//! updates 0-system-vars.nix, stages flake files, and executes nixos-rebuild.
//! Built with strict error handling and zero unwrap.

use anyhow::{Context, Result};
use clap::Parser;
use regex::Regex;
use std::env;
use std::fs;
use std::io::{self, BufRead, Write};
use std::path::{Path, PathBuf};
use std::process::Command;
use sys_tools::{colors, find_dotfiles_dir, find_vars_file, log_error, log_info, log_success, log_warn};

#[derive(Parser, Debug)]
#[command(name = "installer", about = "NixOS & Dotfiles Bootstrap Installer (Rust)")]
struct Args {
    #[arg(long, short = 'y', alias = "non-interactive", help = "Auto-accept detected settings")]
    yes: bool,

    #[arg(long, help = "Run standalone home-manager switch after nixos-rebuild")]
    hm: bool,
}

#[derive(Debug, Clone)]
struct DetectedConfig {
    user: String,
    host: String,
    dotdir: String,
    gpu: String,
    gpu_desc: String,
    device_type: String,
    device_desc: String,
    timezone: String,
    theme: String,
    polarity: String,
}

fn detect_user() -> String {
    if let Ok(sudo_user) = env::var("SUDO_USER") {
        if sudo_user != "root" {
            return sudo_user;
        }
    }
    env::var("USER").unwrap_or_else(|_| "rsh".to_string())
}

fn detect_hostname() -> String {
    if let Ok(h) = nix::unistd::gethostname() {
        let h_str = h.to_string_lossy();
        if !h_str.is_empty() && h_str != "localhost" {
            return h_str.split('.').next().unwrap_or("nixos").to_string();
        }
    }
    if let Ok(content) = fs::read_to_string("/etc/hostname") {
        let trimmed = content.trim();
        if !trimmed.is_empty() {
            return trimmed.to_string();
        }
    }
    "nixos".to_string()
}

fn detect_dotfiles_dir(repo_root: &Path, user: &str) -> String {
    let user_home = PathBuf::from(format!("/home/{}", user));
    if let Ok(rel) = repo_root.strip_prefix(&user_home) {
        return rel.to_string_lossy().to_string();
    }
    "_ws/dotfiles".to_string()
}

fn detect_gpu() -> (String, String) {
    if let Ok(output) = Command::new("lspci").output() {
        let lines = String::from_utf8_lossy(&output.stdout);
        for line in lines.lines() {
            let l_lower = line.to_lowercase();
            if l_lower.contains("vga") || l_lower.contains("3d") || l_lower.contains("display") {
                if l_lower.contains("amd") || l_lower.contains("radeon") || l_lower.contains("ati") {
                    return ("amd".to_string(), line.trim().to_string());
                } else if l_lower.contains("intel") {
                    return ("intel".to_string(), line.trim().to_string());
                } else if l_lower.contains("nvidia") {
                    return ("nvidia".to_string(), line.trim().to_string());
                }
            }
        }
    }
    ("generic".to_string(), "Standard Display / Virtual GPU".to_string())
}

fn detect_device_type() -> (String, String) {
    if let Ok(output) = Command::new("systemd-detect-virt").output() {
        if output.status.success() {
            let virt = String::from_utf8_lossy(&output.stdout).trim().to_string();
            if !virt.is_empty() && virt != "none" {
                return ("vm".to_string(), format!("Virtual Machine ({})", virt));
            }
        }
    }

    let pwr = Path::new("/sys/class/power_supply");
    if pwr.is_dir() {
        if let Ok(entries) = fs::read_dir(pwr) {
            for e in entries.filter_map(|e| e.ok()) {
                let name = e.file_name().to_string_lossy().to_string();
                if name.starts_with("BAT") {
                    return ("laptop".to_string(), "Laptop (Battery detected)".to_string());
                }
            }
        }
    }

    if let Ok(chassis) = fs::read_to_string("/sys/class/dmi/id/chassis_type") {
        let ch_type = chassis.trim();
        let laptop_chassis = ["8", "9", "10", "11", "14", "30", "31", "32"];
        if laptop_chassis.contains(&ch_type) {
            return ("laptop".to_string(), format!("Laptop (Chassis type: {})", ch_type));
        }
    }

    ("desktop".to_string(), "Desktop PC".to_string())
}

fn detect_timezone() -> String {
    if let Ok(output) = Command::new("timedatectl").args(["show", "-p", "Timezone", "--value"]).output() {
        let tz = String::from_utf8_lossy(&output.stdout).trim().to_string();
        if !tz.is_empty() {
            return tz;
        }
    }
    if let Ok(target) = fs::read_link("/etc/localtime") {
        let target_str = target.to_string_lossy();
        if let Some(pos) = target_str.find("zoneinfo/") {
            return target_str[pos + 9..].to_string();
        }
    }
    "Asia/Kolkata".to_string()
}

fn collect_detection(repo_root: &Path) -> Result<DetectedConfig> {
    let user = detect_user();
    let host = detect_hostname();
    let dotdir = detect_dotfiles_dir(repo_root, &user);
    let (gpu, gpu_desc) = detect_gpu();
    let (device_type, device_desc) = detect_device_type();
    let timezone = detect_timezone();

    let mut theme = "catppuccin-mocha".to_string();
    let mut polarity = "dark".to_string();

    if let Some(vars_file) = find_vars_file(repo_root) {
        if let Ok(content) = fs::read_to_string(&vars_file) {
            let re_t = Regex::new(r#"theme\s*=\s*"([^"]+)""#)?;
            if let Some(caps) = re_t.captures(&content) {
                if let Some(m) = caps.get(1) {
                    theme = m.as_str().to_string();
                }
            }
            let re_p = Regex::new(r#"polarity\s*=\s*"([^"]+)""#)?;
            if let Some(caps) = re_p.captures(&content) {
                if let Some(m) = caps.get(1) {
                    polarity = m.as_str().to_string();
                }
            }
        }
    }

    Ok(DetectedConfig {
        user,
        host,
        dotdir,
        gpu,
        gpu_desc,
        device_type,
        device_desc,
        timezone,
        theme,
        polarity,
    })
}

fn update_vars_file(vars_file: &Path, cfg: &DetectedConfig) -> Result<()> {
    let content = fs::read_to_string(vars_file)?;
    let replacements = [
        (r#"(?m)(^\s*username\s*=\s*")[^"]*(";)"#, &cfg.user),
        (r#"(?m)(^\s*hostname\s*=\s*")[^"]*(";)"#, &cfg.host),
        (r#"(?m)(^\s*dotfilesDir\s*=\s*")[^"]*(";)"#, &cfg.dotdir),
        (r#"(?m)(^\s*gpuDriver\s*=\s*")[^"]*(";)"#, &cfg.gpu),
        (r#"(?m)(^\s*deviceType\s*=\s*")[^"]*(";)"#, &cfg.device_type),
        (r#"(?m)(^\s*timeZone\s*=\s*")[^"]*(";)"#, &cfg.timezone),
        (r#"(?m)(^\s*theme\s*=\s*")[^"]*(";)"#, &cfg.theme),
    ];

    let mut updated = content;
    for (pat, val) in &replacements {
        let re = Regex::new(pat)?;
        updated = re.replace(&updated, format!("${{1}}{}${{2}}", val)).to_string();
    }

    fs::write(vars_file, updated)?;
    log_success("0-system-vars.nix successfully updated.");
    Ok(())
}

fn sync_hardware_config(repo_root: &Path) -> Result<()> {
    let target = repo_root.join("nixos/hardware-configuration.nix");
    let source = Path::new("/etc/nixos/hardware-configuration.nix");

    log_info("Checking hardware configuration...");
    if !source.is_file() {
        log_info("/etc/nixos/hardware-configuration.nix not found, generating with nixos-generate-config...");
        let output = Command::new("nixos-generate-config")
            .arg("--show-hardware-config")
            .output()
            .context("Failed to run nixos-generate-config")?;
        fs::write(&target, &output.stdout)?;
    } else {
        match fs::read(source) {
            Ok(bytes) => fs::write(&target, bytes)?,
            Err(_) => {
                let _ = Command::new("sh")
                    .arg("-c")
                    .arg(format!("sudo cat '{}' > '{}'", source.display(), target.display()))
                    .status();
            }
        }
    }
    log_success(&format!("Hardware configuration synchronized to {}", target.display()));
    Ok(())
}

fn run_editor_review(vars_file: &Path) -> Result<()> {
    let mut editor = env::var("EDITOR").or_else(|_| env::var("VISUAL")).unwrap_or_default();
    if editor.is_empty() {
        for candidate in ["nvim", "nano", "vim", "vi"] {
            if which::which(candidate).is_ok() {
                editor = candidate.to_string();
                break;
            }
        }
    }
    if editor.is_empty() {
        return Ok(());
    }

    println!("\n{}:: Ready to review 0-system-vars.nix before starting installation...{}", colors::CYAN, colors::RESET);
    print!("Press [Enter] to open with '{}' (or type editor name): ", editor);
    let _ = io::stdout().flush();
    let mut input = String::new();
    if io::stdin().read_line(&mut input).is_ok() {
        let chosen = input.trim();
        if !chosen.is_empty() && which::which(chosen).is_ok() {
            editor = chosen.to_string();
        }
    }

    log_info(&format!("Opening 0-system-vars.nix with '{}'...", editor));
    let _ = Command::new(&editor).arg(vars_file).status();
    Ok(())
}

fn main() -> Result<()> {
    let args = Args::parse();
    let repo_root = find_dotfiles_dir()?;
    let vars_file = repo_root.join("0-system-vars.nix");

    println!("{}============================================================================={}", colors::HEADER, colors::RESET);
    println!("{}   ❄️  NixOS & Home Manager Bootstrap Installer (Rust){}", colors::BOLD, colors::RESET);
    println!("{}============================================================================={}", colors::HEADER, colors::RESET);

    let mut cfg = collect_detection(&repo_root)?;

    println!("\n{}🔍 Auto-Detected System Configuration:{}", colors::CYAN, colors::RESET);
    println!("-----------------------------------------------------------------------------");
    println!("  [1] Username:       {}{}{}", colors::GREEN, cfg.user, colors::RESET);
    println!("  [2] Hostname:       {}{}{}", colors::GREEN, cfg.host, colors::RESET);
    println!("  [3] Dotfiles Path:  {}{}{} (relative to $HOME)", colors::GREEN, cfg.dotdir, colors::RESET);
    println!("  [4] GPU Driver:     {}{}{} ({})", colors::GREEN, cfg.gpu, colors::RESET, cfg.gpu_desc);
    println!("  [5] Device Type:    {}{}{} ({})", colors::GREEN, cfg.device_type, colors::RESET, cfg.device_desc);
    println!("  [6] Timezone:       {}{}{}", colors::GREEN, cfg.timezone, colors::RESET);
    println!("  [7] Base16 Theme:   {}{}{} ({})", colors::GREEN, cfg.theme, colors::RESET, cfg.polarity);
    println!("-----------------------------------------------------------------------------");

    if !args.yes {
        print!("\nApply these settings and proceed with installation? [Y/n/c(ustom)]: ");
        let _ = io::stdout().flush();
        let mut choice = String::new();
        if io::stdin().read_line(&mut choice).is_ok() {
            let c_clean = choice.trim().to_lowercase();
            if c_clean == "n" || c_clean == "no" {
                log_warn("Installation aborted by user.");
                return Ok(());
            } else if c_clean == "c" || c_clean == "custom" {
                let stdin = io::stdin();
                println!("\n:: Enter custom settings (Press Enter to keep detected default):");
                print!("  Username [{}]: ", cfg.user);
                let _ = io::stdout().flush();
                let mut u = String::new();
                stdin.lock().read_line(&mut u)?;
                if !u.trim().is_empty() { cfg.user = u.trim().to_string(); }

                print!("  Hostname [{}]: ", cfg.host);
                let _ = io::stdout().flush();
                let mut h = String::new();
                stdin.lock().read_line(&mut h)?;
                if !h.trim().is_empty() { cfg.host = h.trim().to_string(); }

                print!("  Dotfiles Subdirectory [{}]: ", cfg.dotdir);
                let _ = io::stdout().flush();
                let mut d = String::new();
                stdin.lock().read_line(&mut d)?;
                if !d.trim().is_empty() { cfg.dotdir = d.trim().to_string(); }

                print!("  GPU Driver (amd/intel/nvidia/generic) [{}]: ", cfg.gpu);
                let _ = io::stdout().flush();
                let mut g = String::new();
                stdin.lock().read_line(&mut g)?;
                if !g.trim().is_empty() { cfg.gpu = g.trim().to_string(); }
            }
        }
    }

    update_vars_file(&vars_file, &cfg)?;
    sync_hardware_config(&repo_root)?;

    if !args.yes {
        run_editor_review(&vars_file)?;
    }

    log_info("Staging repository files for Nix flake evaluation...");
    let _ = Command::new("git").args(["-C", &repo_root.to_string_lossy(), "add", "-A"]).status();

    log_info(&format!("Rebuilding and switching NixOS system for host '{}'...", cfg.host));
    let status = Command::new("sudo")
        .args(["nixos-rebuild", "switch", "--flake", &format!("{}#{}", repo_root.display(), cfg.host)])
        .status()?;

    if !status.success() {
        log_error("NixOS rebuild failed.");
        std::process::exit(status.code().unwrap_or(1));
    }

    if args.hm {
        log_info("Running Home Manager switch...");
        let _ = Command::new("home-manager")
            .args(["switch", "--flake", &format!("{}#{}", repo_root.display(), cfg.user)])
            .status();
    }

    println!("\n{}============================================================================={}", colors::HEADER, colors::RESET);
    println!("{}   ✨ Installation and System Switch Complete!{}", colors::BOLD, colors::RESET);
    println!("{}============================================================================={}", colors::HEADER, colors::RESET);
    println!("  • User Profile: {}{}{}", colors::CYAN, cfg.user, colors::RESET);
    println!("  • Host Profile: {}{}{}", colors::CYAN, cfg.host, colors::RESET);
    println!("  • Theme:        {}{}{}", colors::CYAN, cfg.theme, colors::RESET);
    println!("\n  💡 Routine Daily Commands:");
    println!("     {}dot switch{}   # Rebuild NixOS system", colors::YELLOW, colors::RESET);
    println!("     {}dot hm{}       # Switch user Home Manager environment", colors::YELLOW, colors::RESET);
    println!("     {}dot fmt{}      # Format dotfiles with treefmt", colors::YELLOW, colors::RESET);
    println!("{}============================================================================={}", colors::HEADER, colors::RESET);

    Ok(())
}
