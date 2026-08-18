//! Unified NixOS & Home Manager Dotfiles CLI Assistant ('dot') in Rust
//! Provides subcommands for system switches, updates, formatting, garbage collection,
//! and comprehensive health diagnostics. Built with strict error handling and zero unwrap.

use anyhow::{Context, Result};
use clap::{Parser, Subcommand};
use std::path::Path;
use std::process::Command;
use sys_tools::{colors, extract_system_vars, find_dotfiles_dir, log_error, log_info, log_success, log_warn};

#[derive(Parser, Debug)]
#[command(name = "dot", about = "Unified NixOS & Home Manager CLI Assistant (Rust)")]
struct Cli {
    #[command(subcommand)]
    command: Option<Commands>,
}

#[derive(Subcommand, Debug)]
enum Commands {
    #[command(about = "Rebuild and switch NixOS configuration")]
    Switch,

    #[command(about = "Alias for switch")]
    Nixos,

    #[command(about = "Rebuild and switch Home Manager configuration")]
    Hm,

    #[command(about = "Alias for hm")]
    Home,

    #[command(about = "Rebuild both NixOS and Home Manager")]
    Sync,

    #[command(about = "Test NixOS configuration without updating bootloader")]
    Test,

    #[command(about = "Build NixOS configuration and update bootloader")]
    Boot,

    #[command(about = "Format Nix and dotfiles using nix fmt")]
    Fmt,

    #[command(about = "Run nix flake check")]
    Check,

    #[command(about = "Update Antigravity CLI and Flake inputs")]
    Update {
        #[arg(help = "Specific input to update (e.g. nixpkgs)")]
        input: Option<String>,
    },

    #[command(about = "Clean old Nix generations and optimize store")]
    Gc {
        #[arg(long, default_value = "7d", help = "Delete generations older than")]
        days: String,
    },

    #[command(about = "Run comprehensive health diagnostics")]
    Doctor,
}

fn run_stream(cmd: &mut Command) -> Result<i32> {
    let status = cmd.status().context("Failed to execute command")?;
    Ok(status.code().unwrap_or(1))
}

fn cmd_switch(dot_dir: &Path, host: &str) -> Result<i32> {
    log_info(&format!("Rebuilding NixOS system for host '{host}'..."));
    let mut cmd = Command::new("sudo");
    cmd.args(["nixos-rebuild", "switch", "--flake", &format!("{}#{}", dot_dir.display(), host)]);
    run_stream(&mut cmd)
}

fn cmd_hm(dot_dir: &Path, user: &str) -> Result<i32> {
    log_info(&format!("Switching Home Manager profile for user '{user}'..."));
    if which::which("home-manager").is_ok() {
        let mut cmd = Command::new("home-manager");
        cmd.args(["switch", "--flake", &format!("{}#{}", dot_dir.display(), user)]);
        run_stream(&mut cmd)
    } else {
        let mut cmd = Command::new("nix");
        cmd.args(["run", &format!("{}#homeConfigurations.{}.activationPackage", dot_dir.display(), user)]);
        run_stream(&mut cmd)
    }
}

fn cmd_doctor(dot_dir: &Path, host: &str, user: &str) -> Result<i32> {
    let vars = extract_system_vars(dot_dir)?;

    println!("\n{}============================================================================={}", colors::HEADER, colors::RESET);
    println!("{}   🩺 Dotfiles & System Health Diagnostics (Rust){}", colors::BOLD, colors::RESET);
    println!("{}============================================================================={}", colors::HEADER, colors::RESET);
    println!("  • Dotfiles Root:  {}{}{}", colors::CYAN, dot_dir.display(), colors::RESET);
    println!("  • Host Profile:   {}{}{}", colors::GREEN, host, colors::RESET);
    println!("  • User Profile:   {}{}{}", colors::GREEN, user, colors::RESET);
    println!("  • Active Theme:   {}{}{}", colors::YELLOW, vars.theme, colors::RESET);

    // 1. Disk usage via nix crate (statvfs)
    if let Ok(stat) = nix::sys::statvfs::statvfs(dot_dir) {
        let total_bytes = (stat.blocks() as u64) * (stat.fragment_size() as u64);
        let free_bytes = (stat.blocks_available() as u64) * (stat.fragment_size() as u64);
        let total_gb = (total_bytes as f64) / (1024.0 * 1024.0 * 1024.0);
        let free_gb = (free_bytes as f64) / (1024.0 * 1024.0 * 1024.0);
        println!("  • Root Disk:      {}{:.1} GB free{} of {:.1} GB", colors::GREEN, free_gb, colors::RESET, total_gb);
    }

    // 2. Git Status
    println!("\n{}📦 Git Repository Status:{}", colors::BOLD, colors::RESET);
    if let Ok(output) = Command::new("git").args(["-C", &dot_dir.to_string_lossy(), "status", "-s"]).output() {
        let out_str = String::from_utf8_lossy(&output.stdout);
        let lines: Vec<&str> = out_str.lines().filter(|l| !l.trim().is_empty()).collect();
        if lines.is_empty() {
            log_success("Working tree is clean.");
        } else {
            log_warn(&format!("{} uncommitted file(s):", lines.len()));
            for l in lines.iter().take(5) {
                println!("    {}", l);
            }
            if lines.len() > 5 {
                println!("    ... and {} more", lines.len() - 5);
            }
        }
    }

    // 3. Systemd Services
    println!("\n{}⚙️ Systemd Service Status:{}", colors::BOLD, colors::RESET);
    let sys_failed = Command::new("systemctl").args(["--failed", "--quiet"]).status();
    let usr_failed = Command::new("systemctl").args(["--user", "--failed", "--quiet"]).status();

    let sys_ok = sys_failed.map(|s| s.success()).unwrap_or(false);
    let usr_ok = usr_failed.map(|s| s.success()).unwrap_or(false);

    if sys_ok && usr_ok {
        log_success("No failed system or user systemd units.");
    } else {
        if !sys_ok {
            log_error("Systemd system units have failed states.");
        }
        if !usr_ok {
            log_error("Systemd user units have failed states.");
        }
    }

    // 4. Generations
    println!("\n{}❄️ Generations Status:{}", colors::BOLD, colors::RESET);
    let sys_prof = Path::new("/nix/var/nix/profiles/system");
    if sys_prof.exists() {
        if let Ok(output) = Command::new("nix-env").args(["-p", "/nix/var/nix/profiles/system", "--list-generations"]).output() {
            let out_str = String::from_utf8_lossy(&output.stdout);
            let lines: Vec<&str> = out_str.lines().filter(|l| !l.trim().is_empty()).collect();
            if !lines.is_empty() {
                println!("  NixOS System Generations: {}{}{}", colors::CYAN, lines.len(), colors::RESET);
                for l in lines.iter().rev().take(2).rev() {
                    println!("    {}", l);
                }
            }
        }
    }

    if which::which("home-manager").is_ok() {
        if let Ok(output) = Command::new("home-manager").arg("generations").output() {
            let out_str = String::from_utf8_lossy(&output.stdout);
            let lines: Vec<&str> = out_str.lines().filter(|l| !l.trim().is_empty()).collect();
            if !lines.is_empty() {
                println!("  Home Manager Generations: {}{}{}", colors::CYAN, lines.len(), colors::RESET);
            }
        }
    }

    println!("{}============================================================================={}", colors::HEADER, colors::RESET);
    Ok(0)
}

fn main() -> Result<()> {
    let cli = Cli::parse();
    let dot_dir = find_dotfiles_dir()?;
    let vars = extract_system_vars(&dot_dir)?;

    let cmd = match cli.command {
        Some(c) => c,
        None => {
            let _ = Command::new("dot").arg("--help").status();
            return Ok(());
        }
    };

    let code = match cmd {
        Commands::Switch | Commands::Nixos => cmd_switch(&dot_dir, &vars.hostname)?,
        Commands::Hm | Commands::Home => cmd_hm(&dot_dir, &vars.username)?,
        Commands::Sync => {
            let rc = cmd_switch(&dot_dir, &vars.hostname)?;
            if rc == 0 {
                cmd_hm(&dot_dir, &vars.username)?
            } else {
                rc
            }
        }
        Commands::Test => {
            log_info(&format!("Testing NixOS configuration for host '{}'...", vars.hostname));
            let mut c = Command::new("sudo");
            c.args(["nixos-rebuild", "test", "--flake", &format!("{}#{}", dot_dir.display(), vars.hostname)]);
            run_stream(&mut c)?
        }
        Commands::Boot => {
            log_info(&format!("Building NixOS boot entry for host '{}'...", vars.hostname));
            let mut c = Command::new("sudo");
            c.args(["nixos-rebuild", "boot", "--flake", &format!("{}#{}", dot_dir.display(), vars.hostname)]);
            run_stream(&mut c)?
        }
        Commands::Fmt => {
            log_info("Formatting dotfiles tree...");
            let mut c = Command::new("nix");
            c.arg("fmt").current_dir(&dot_dir);
            run_stream(&mut c)?
        }
        Commands::Check => {
            log_info("Running nix flake check...");
            let mut c = Command::new("nix");
            c.args(["flake", "check"]).current_dir(&dot_dir);
            run_stream(&mut c)?
        }
        Commands::Update { input } => {
            // Update AGY
            let _ = Command::new("update-agy").status();
            log_info("Updating Flake inputs...");
            let mut c = Command::new("nix");
            if let Some(inp) = input {
                c.args(["flake", "update", &inp]);
            } else {
                c.args(["flake", "update"]);
            }
            c.current_dir(&dot_dir);
            run_stream(&mut c)?
        }
        Commands::Gc { days } => {
            log_info(&format!("Collecting user & system garbage older than {}...", days));
            let _ = Command::new("nix-collect-garbage").args(["--delete-older-than", &days]).status();
            let _ = Command::new("sudo").args(["nix-collect-garbage", "--delete-older-than", &days]).status();
            log_info("Optimizing Nix store...");
            let _ = Command::new("nix").args(["store", "optimise"]).status();
            let _ = Command::new("sudo").args(["nix", "store", "optimise"]).status();
            0
        }
        Commands::Doctor => cmd_doctor(&dot_dir, &vars.hostname, &vars.username)?,
    };

    if code != 0 {
        std::process::exit(code);
    }

    Ok(())
}
