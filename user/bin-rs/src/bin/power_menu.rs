//! Power & Session Menu for Wayland Compositors (Rust)
//! Handles lock, logout, sleep, reboot, and poweroff actions.
//! Built with strict error handling and zero unwrap.

use anyhow::{Context, Result};
use clap::Parser;
use std::io::{self, IsTerminal, Write};
use std::process::{Command, Stdio};
use sys_tools::{colors, home_dir, log_error, log_info, log_success, log_warn};

const ACTIONS: &[(&str, &str)] = &[
    ("󰌾  Lock", "lock"),
    ("󰍃  Logout", "logout"),
    ("󰤄  Sleep", "sleep"),
    ("󰜉  Reboot", "reboot"),
    ("󰐥  Shutdown", "shutdown"),
];

#[derive(Parser, Debug)]
#[command(name = "power-menu", about = "Wayland Power & Session Management Menu (Rust)")]
struct Args {
    #[arg(long, help = "Directly execute a session action without menu")]
    action: Option<String>,

    #[arg(long, help = "Print selected action without executing")]
    dry_run: bool,

    #[arg(long, help = "List all available session actions")]
    list: bool,
}

fn action_lock() -> Result<()> {
    log_info("Locking session (swaylock)...");
    if which::which("swaylock").is_ok() {
        let _ = Command::new("swaylock").arg("-f").status();
    } else if which::which("loginctl").is_ok() {
        let _ = Command::new("loginctl").arg("lock-session").status();
    } else {
        log_warn("Neither swaylock nor loginctl found.");
    }
    Ok(())
}

fn action_logout() -> Result<()> {
    log_info("Terminating Wayland compositor session...");
    if which::which("labwc").is_ok() && Command::new("labwc").arg("--exit").status().is_ok() {
        return Ok(());
    }
    if which::which("niri").is_ok()
        && Command::new("niri")
            .args(["msg", "action", "quit", "--skip-confirmation"])
            .status()
            .is_ok()
    {
        return Ok(());
    }
    let _ = Command::new("sh")
        .arg("-c")
        .arg("pkill labwc || pkill niri || loginctl terminate-session self")
        .status();
    Ok(())
}

fn action_sleep() -> Result<()> {
    log_info("Putting system to sleep (suspend)...");
    let home = home_dir()?;
    let script_candidates = [
        home.join("_ws/dotfiles/user/bin-sh/sleep.sh"),
        home.join("dotfiles/user/bin-sh/sleep.sh"),
        home.join("_ws/dotfiles/home-manager/scripts/sleep.sh"),
        home.join("dotfiles/home-manager/scripts/sleep.sh"),
    ];

    for s in &script_candidates {
        if s.is_file() {
            let _ = Command::new(s).status();
            return Ok(());
        }
    }

    if which::which("pamixer").is_ok() {
        let _ = Command::new("pamixer").arg("--mute").status();
    }
    let _ = Command::new("systemctl").arg("suspend").status();
    Ok(())
}

fn action_reboot() -> Result<()> {
    log_warn("Rebooting system (systemctl reboot)...");
    let _ = Command::new("systemctl").arg("reboot").status();
    Ok(())
}

fn action_shutdown() -> Result<()> {
    log_error("Shutting down system (systemctl poweroff)...");
    let _ = Command::new("systemctl").arg("poweroff").status();
    Ok(())
}

fn dispatch_action(action_name: &str, dry_run: bool) -> Result<()> {
    if dry_run {
        log_success(&format!("Dry-run: Action '{}' would be executed.", action_name));
        return Ok(());
    }

    match action_name {
        "lock" => action_lock()?,
        "logout" => action_logout()?,
        "sleep" => action_sleep()?,
        "reboot" => action_reboot()?,
        "shutdown" => action_shutdown()?,
        other => log_warn(&format!("Unknown action: {}", other)),
    }
    Ok(())
}

fn show_fuzzel_menu() -> Result<Option<String>> {
    if which::which("fuzzel").is_err() {
        if io::stdin().is_terminal() {
            println!("\n{}Power & Session Menu (Rust):{}", colors::HEADER, colors::RESET);
            for (idx, (label, name)) in ACTIONS.iter().enumerate() {
                println!("  [{}] {} ({})", idx + 1, label, name);
            }
            print!("Enter choice [1-5]: ");
            let _ = io::stdout().flush();
            let mut input = String::new();
            if io::stdin().read_line(&mut input).is_ok() {
                if let Ok(num) = input.trim().parse::<usize>() {
                    if num >= 1 && num <= ACTIONS.len() {
                        return Ok(Some(ACTIONS[num - 1].1.to_string()));
                    }
                }
            }
        }
        return Ok(None);
    }

    let menu_input = ACTIONS
        .iter()
        .map(|(label, _)| *label)
        .collect::<Vec<&str>>()
        .join("\n")
        + "\n";

    let mut child = Command::new("fuzzel")
        .args([
            "--dmenu",
            "--prompt", "Power: ",
            "--placeholder", "Select session action...",
            "--lines", &ACTIONS.len().to_string(),
            "--width", "18",
            "--horizontal-pad", "20",
            "--vertical-pad", "15",
        ])
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::null())
        .spawn()
        .context("Failed to spawn Fuzzel")?;

    if let Some(mut stdin) = child.stdin.take() {
        stdin.write_all(menu_input.as_bytes())?;
    }

    let output = child.wait_with_output()?;
    let selected_label = String::from_utf8_lossy(&output.stdout).trim().to_string();

    for (label, name) in ACTIONS {
        if *label == selected_label {
            return Ok(Some(name.to_string()));
        }
    }

    Ok(None)
}

fn main() -> Result<()> {
    let args = Args::parse();

    if args.list {
        println!("{}Available Session Actions (Rust):{}", colors::HEADER, colors::RESET);
        for (label, action_name) in ACTIONS {
            println!("  • {}{:<10}{} ({})", colors::CYAN, action_name, colors::RESET, label);
        }
        return Ok(());
    }

    let target_action = if let Some(ref act) = args.action {
        Some(act.clone())
    } else {
        show_fuzzel_menu()?
    };

    if let Some(action_name) = target_action {
        dispatch_action(&action_name, args.dry_run)?;
    }

    Ok(())
}
