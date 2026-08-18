use clap::{Parser, Subcommand};
use colored::Colorize;
use dot_tools::fuzzel::prompt_menu;
use dot_tools::theme_engine::ThemeEngine;

#[derive(Parser)]
#[command(name = "theme-switcher")]
#[command(about = "Modern, blazing-fast theme switcher with Fuzzel Wayland menu and Wallust integration")]
#[command(version)]
struct Cli {
    #[command(subcommand)]
    command: Option<Commands>,

    #[arg(short = 's', long = "set", help = "Theme name or alias to apply")]
    set: Option<String>,

    #[arg(short = 'l', long = "list", help = "List all available themes")]
    list: bool,

    #[arg(short = 'c', long = "current", help = "Show currently active theme")]
    current: bool,

    #[arg(short = 'm', long = "menu", help = "Open interactive Fuzzel graphical picker")]
    menu: bool,

    #[arg(short = 'r', long = "random", help = "Pick and apply a random theme")]
    random: bool,

    #[arg(short = 't', long = "toggle", help = "Toggle dark/light polarity of current theme")]
    toggle: bool,

    #[arg(short = 'p', long = "preview", help = "Preview a theme's color palette")]
    preview: Option<String>,

    #[arg(long = "no-reload", help = "Do not reload desktop compositors/bars")]
    no_reload: bool,
}

#[derive(Subcommand)]
enum Commands {
    #[command(about = "Set and apply a theme by name")]
    Set {
        #[arg(help = "Name of the theme")]
        name: String,
        #[arg(long = "no-reload")]
        no_reload: bool,
    },

    #[command(about = "List all available themes")]
    List,

    #[command(about = "Show current active theme")]
    Current,

    #[command(about = "Open interactive Fuzzel launcher menu")]
    Menu,

    #[command(about = "Apply a random theme")]
    Random,

    #[command(about = "Toggle polarity (dark <-> light)")]
    Toggle,

    #[command(about = "Preview palette for a theme in terminal")]
    Preview {
        #[arg(help = "Name of the theme to preview")]
        name: String,
    },
}

fn main() -> anyhow::Result<()> {
    let cli = Cli::parse();
    let reload = !cli.no_reload;

    if let Some(theme_to_set) = cli.set {
        let applied = ThemeEngine::apply_theme(&theme_to_set, reload)?;
        println!(
            "{} Switched theme to {} ({})",
            "✔".green().bold(),
            applied.name.cyan().bold(),
            applied.polarity
        );
        return Ok(());
    }

    if cli.list {
        return list_themes();
    }

    if cli.current {
        return show_current_theme();
    }

    if cli.random {
        let applied = ThemeEngine::apply_random_theme()?;
        println!(
            "{} Randomly selected theme: {} ({})",
            "🎲".bold(),
            applied.name.cyan().bold(),
            applied.polarity
        );
        return Ok(());
    }

    if cli.toggle {
        let applied = ThemeEngine::toggle_polarity()?;
        println!(
            "{} Toggled polarity: {} ({})",
            "🌓".bold(),
            applied.name.cyan().bold(),
            applied.polarity
        );
        return Ok(());
    }

    if let Some(target) = cli.preview {
        if let Some(theme) = ThemeEngine::find_theme(&target) {
            ThemeEngine::print_theme_preview(&theme);
        } else {
            anyhow::bail!("Theme '{}' not found", target);
        }
        return Ok(());
    }

    match cli.command {
        Some(Commands::Set { name, no_reload }) => {
            let applied = ThemeEngine::apply_theme(&name, !no_reload)?;
            println!(
                "{} Switched theme to {} ({})",
                "✔".green().bold(),
                applied.name.cyan().bold(),
                applied.polarity
            );
        }

        Some(Commands::List) => {
            list_themes()?;
        }

        Some(Commands::Current) => {
            show_current_theme()?;
        }

        Some(Commands::Menu) => {
            run_interactive_menu(reload)?;
        }

        Some(Commands::Random) => {
            let applied = ThemeEngine::apply_random_theme()?;
            println!(
                "{} Randomly selected theme: {} ({})",
                "🎲".bold(),
                applied.name.cyan().bold(),
                applied.polarity
            );
        }

        Some(Commands::Toggle) => {
            let applied = ThemeEngine::toggle_polarity()?;
            println!(
                "{} Toggled polarity: {} ({})",
                "🌓".bold(),
                applied.name.cyan().bold(),
                applied.polarity
            );
        }

        Some(Commands::Preview { name }) => {
            if let Some(theme) = ThemeEngine::find_theme(&name) {
                ThemeEngine::print_theme_preview(&theme);
            } else {
                anyhow::bail!("Theme '{}' not found", name);
            }
        }

        None => {
            // Default action: Interactive menu
            run_interactive_menu(reload)?;
        }
    }

    Ok(())
}

fn list_themes() -> anyhow::Result<()> {
    let themes = ThemeEngine::load_all_themes();
    let cur_name = ThemeEngine::get_current_theme_name();

    println!("\n{}", "=== 🎨 Available Desktop Themes ===".bold().cyan());
    for t in themes {
        let is_current = t.name == cur_name;
        let prefix = if is_current { "●".green().bold() } else { "○".normal() };
        let disp = t.display_name.as_deref().unwrap_or(&t.name);
        let tag = if t.polarity == "dark" { "[dark]".dimmed() } else { "[light]".yellow() };

        if is_current {
            println!("  {} {} {} {}", prefix, t.name.green().bold(), format!("({})", disp).dimmed(), tag);
        } else {
            println!("  {} {} {} {}", prefix, t.name.bold(), format!("({})", disp).dimmed(), tag);
        }
    }
    println!("\nTotal: {} themes available\n", ThemeEngine::load_all_themes().len());
    Ok(())
}

fn show_current_theme() -> anyhow::Result<()> {
    let cur_name = ThemeEngine::get_current_theme_name();
    if let Some(theme) = ThemeEngine::find_theme(&cur_name) {
        ThemeEngine::print_theme_preview(&theme);
    } else {
        println!("Current theme: {}", cur_name);
    }
    Ok(())
}

fn run_interactive_menu(reload: bool) -> anyhow::Result<()> {
    let themes = ThemeEngine::load_all_themes();
    let cur_name = ThemeEngine::get_current_theme_name();

    let mut menu_items = Vec::new();
    let mut theme_lookup = Vec::new();

    // Add Toggle & Random at the top
    menu_items.push("🌓  Toggle Dark / Light Polarity".to_string());
    theme_lookup.push("__TOGGLE__".to_string());

    menu_items.push("🎲  Random Theme".to_string());
    theme_lookup.push("__RANDOM__".to_string());

    for t in &themes {
        let is_current = t.name == cur_name;
        let marker = if is_current { "● " } else { "  " };
        let icon = if t.polarity == "dark" { "🌙" } else { "☀️" };
        let disp = t.display_name.as_deref().unwrap_or(&t.name);

        let label = format!("{}{} {} ({})", marker, icon, disp, t.name);
        menu_items.push(label);
        theme_lookup.push(t.name.clone());
    }

    if let Some(choice) = prompt_menu(&menu_items, "🎨 Theme: ", Some("Search desktop theme..."))? {
        let index = menu_items.iter().position(|item| item == &choice);
        if let Some(idx) = index {
            let action = &theme_lookup[idx];
            if action == "__TOGGLE__" {
                let applied = ThemeEngine::toggle_polarity()?;
                println!("{} Switched to {}", "✔".green(), applied.name);
            } else if action == "__RANDOM__" {
                let applied = ThemeEngine::apply_random_theme()?;
                println!("{} Switched to {}", "✔".green(), applied.name);
            } else {
                let applied = ThemeEngine::apply_theme(action, reload)?;
                println!("{} Switched to {}", "✔".green(), applied.name);
            }
        }
    }

    Ok(())
}
