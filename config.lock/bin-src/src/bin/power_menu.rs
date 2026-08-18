use clap::{Parser, Subcommand};
use colored::Colorize;
use dot_tools::fuzzel::prompt_menu;
use dot_tools::process_runner::{execute_cmd, run_detached};

#[derive(Parser)]
#[command(name = "power-menu")]
#[command(about = "Wayland power management and session controller with Fuzzel & Wlogout support")]
#[command(version)]
struct Cli {
    #[command(subcommand)]
    command: Option<Commands>,

    #[arg(short = 'w', long = "wlogout", help = "Launch wlogout dialog instead of Fuzzel")]
    wlogout: bool,

    #[arg(short = 'c', long = "confirm", help = "Prompt for confirmation before destructive actions")]
    confirm: bool,
}

#[derive(Subcommand)]
enum Commands {
    #[command(about = "Lock current screen")]
    Lock,
    #[command(about = "Log out from desktop session")]
    Logout,
    #[command(about = "Suspend system to RAM")]
    Suspend,
    #[command(about = "Hibernate system to disk")]
    Hibernate,
    #[command(about = "Reboot system")]
    Reboot,
    #[command(about = "Power off / Shutdown system")]
    Shutdown,
    #[command(about = "Reboot into UEFI/BIOS firmware setup")]
    Uefi,
    #[command(about = "Launch power menu selection")]
    Menu,
}

fn main() -> anyhow::Result<()> {
    let cli = Cli::parse();

    if cli.wlogout {
        run_detached("wlogout || pkill wlogout");
        return Ok(());
    }

    match cli.command {
        Some(Commands::Lock) => action_lock()?,
        Some(Commands::Logout) => action_logout(cli.confirm)?,
        Some(Commands::Suspend) => action_suspend()?,
        Some(Commands::Hibernate) => action_hibernate(cli.confirm)?,
        Some(Commands::Reboot) => action_reboot(cli.confirm)?,
        Some(Commands::Shutdown) => action_shutdown(cli.confirm)?,
        Some(Commands::Uefi) => action_uefi(cli.confirm)?,
        Some(Commands::Menu) | None => run_fuzzel_power_menu(cli.confirm)?,
    }

    Ok(())
}

fn action_lock() -> anyhow::Result<()> {
    println!("{} Locking session...", "🔒".bold());
    let _ = execute_cmd("swaylock -f || hyprlock || loginctl lock-session");
    Ok(())
}

fn action_logout(confirm: bool) -> anyhow::Result<()> {
    if confirm && !confirm_prompt("logout of session")? {
        return Ok(());
    }
    println!("{} Logging out...", "󰍃".bold());
    let _ = execute_cmd("labwc --exit || niri msg action quit || hyprctl dispatch exit || swaymsg exit || loginctl terminate-user $USER");
    Ok(())
}

fn action_suspend() -> anyhow::Result<()> {
    println!("{} Suspending system...", "󰤄".bold());
    let _ = execute_cmd("systemctl suspend");
    Ok(())
}

fn action_hibernate(confirm: bool) -> anyhow::Result<()> {
    if confirm && !confirm_prompt("hibernate system")? {
        return Ok(());
    }
    println!("{} Hibernating system...", "󰒲".bold());
    let _ = execute_cmd("systemctl hibernate");
    Ok(())
}

fn action_reboot(confirm: bool) -> anyhow::Result<()> {
    if confirm && !confirm_prompt("reboot system")? {
        return Ok(());
    }
    println!("{} Rebooting system...", "󰑐".bold());
    let _ = execute_cmd("systemctl reboot");
    Ok(())
}

fn action_shutdown(confirm: bool) -> anyhow::Result<()> {
    if confirm && !confirm_prompt("power off system")? {
        return Ok(());
    }
    println!("{} Powering off system...", "󰐥".bold());
    let _ = execute_cmd("systemctl poweroff");
    Ok(())
}

fn action_uefi(confirm: bool) -> anyhow::Result<()> {
    if confirm && !confirm_prompt("reboot into UEFI setup")? {
        return Ok(());
    }
    println!("{} Rebooting to UEFI firmware setup...", "󰌢".bold());
    let _ = execute_cmd("systemctl reboot --firmware-setup");
    Ok(())
}

fn confirm_prompt(action: &str) -> anyhow::Result<bool> {
    let items = vec![
        format!("✔  Yes, {}", action),
        "✖  No, Cancel".to_string(),
    ];
    let prompt = format!("Confirm {}: ", action);
    if let Some(choice) = prompt_menu(&items, &prompt, None)? {
        return Ok(choice.starts_with('✔'));
    }
    Ok(false)
}

fn run_fuzzel_power_menu(confirm: bool) -> anyhow::Result<()> {
    let items = vec![
        "  Lock".to_string(),
        "󰍃  Logout".to_string(),
        "󰤄  Suspend".to_string(),
        "󰒲  Hibernate".to_string(),
        "󰑐  Reboot".to_string(),
        "󰐥  Shutdown".to_string(),
        "󰌢  Firmware Setup (UEFI)".to_string(),
        "  Cancel".to_string(),
    ];

    if let Some(choice) = prompt_menu(&items, "⏻  Power: ", Some("Select power action..."))? {
        if choice.contains("Lock") {
            action_lock()?;
        } else if choice.contains("Logout") {
            action_logout(confirm)?;
        } else if choice.contains("Suspend") {
            action_suspend()?;
        } else if choice.contains("Hibernate") {
            action_hibernate(confirm)?;
        } else if choice.contains("Reboot") {
            action_reboot(confirm)?;
        } else if choice.contains("Shutdown") {
            action_shutdown(confirm)?;
        } else if choice.contains("Firmware") {
            action_uefi(confirm)?;
        }
    }

    Ok(())
}
