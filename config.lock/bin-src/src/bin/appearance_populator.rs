use clap::{Parser, Subcommand};
use colored::Colorize;
use dot_tools::populator::AppearancePopulator;
use dot_tools::process_runner::reload_desktop_apps;
use dot_tools::theme_engine::ThemeEngine;

#[derive(Parser)]
#[command(name = "appearance-populator")]
#[command(about = "Renders and populates XDG appearance and styling tokens from appearance.toml")]
#[command(version)]
struct Cli {
    #[command(subcommand)]
    command: Option<Commands>,

    #[arg(short, long, help = "Reload running desktop apps after populating")]
    reload: bool,

    #[arg(short, long, help = "Suppress informational messages")]
    quiet: bool,
}

#[derive(Subcommand)]
enum Commands {
    #[command(about = "Populate all appearance and theme tokens across desktop configs")]
    Populate {
        #[arg(short, long)]
        reload: bool,
    },

    #[command(about = "Get a specific appearance token value")]
    Get {
        #[arg(help = "Token key (e.g., fonts.mono.family, fonts.sizes.terminal, appearance.border_radius)")]
        key: String,
    },

    #[command(about = "Set a specific appearance token value and re-populate")]
    Set {
        #[arg(help = "Token key (e.g., appearance.border_radius, fonts.sizes.terminal)")]
        key: String,
        #[arg(help = "New token value")]
        value: String,
    },

    #[command(about = "Validate and show summary of appearance tokens")]
    Check,
}

fn main() -> anyhow::Result<()> {
    let cli = Cli::parse();

    match cli.command {
        None | Some(Commands::Populate { .. }) => {
            let config = ThemeEngine::load_appearance_config();
            let theme_name = ThemeEngine::get_current_theme_name();
            let theme = ThemeEngine::find_theme(&theme_name)
                .unwrap_or_else(|| dot_tools::themes_db::get_builtin_themes()[0].clone());

            AppearancePopulator::populate_appearance(&config)?;
            AppearancePopulator::populate_theme_tokens(&theme.colors, &config)?;

            let should_reload = cli.reload
                || match cli.command {
                    Some(Commands::Populate { reload }) => reload,
                    _ => false,
                };

            if should_reload {
                reload_desktop_apps();
            }

            if !cli.quiet {
                println!(
                    "{} Appearance & typography tokens populated successfully.",
                    "✔".green().bold()
                );
                println!(
                    "  Font: {} ({:.1}pt terminal, {:.1}pt launcher, {:.1}pt bar)",
                    config.fonts.mono.family.cyan(),
                    config.fonts.sizes.terminal,
                    config.fonts.sizes.launcher,
                    config.fonts.sizes.bar
                );
                println!(
                    "  Geometry: {}px radius, {}px border, {}px gaps",
                    config.appearance.border_radius.to_string().cyan(),
                    config.appearance.border_width.to_string().cyan(),
                    config.appearance.gaps.inner.to_string().cyan()
                );
                println!(
                    "  Theme: {} ({})",
                    theme.name.cyan(),
                    theme.polarity.cyan()
                );
            }
        }

        Some(Commands::Get { key }) => {
            let config = ThemeEngine::load_appearance_config();
            let json_val = serde_json::to_value(&config)?;
            let parts: Vec<&str> = key.split('.').collect();

            let mut curr = &json_val;
            for part in parts {
                if let Some(next) = curr.get(part) {
                    curr = next;
                } else {
                    anyhow::bail!("Token key '{}' not found in appearance config", key);
                }
            }

            if let Some(s) = curr.as_str() {
                println!("{}", s);
            } else {
                println!("{}", curr);
            }
        }

        Some(Commands::Set { key, value }) => {
            let mut config = ThemeEngine::load_appearance_config();

            let parts: Vec<&str> = key.split('.').collect();
            if parts.is_empty() {
                anyhow::bail!("Invalid token key");
            }

            // Simple common key overrides
            match key.as_str() {
                "fonts.mono.family" => config.fonts.mono.family = value.clone(),
                "fonts.sans.family" => config.fonts.sans.family = value.clone(),
                "fonts.sizes.terminal" => config.fonts.sizes.terminal = value.parse()?,
                "fonts.sizes.bar" => config.fonts.sizes.bar = value.parse()?,
                "fonts.sizes.launcher" => config.fonts.sizes.launcher = value.parse()?,
                "fonts.sizes.desktop" => config.fonts.sizes.desktop = value.parse()?,
                "fonts.sizes.power_menu" => config.fonts.sizes.power_menu = value.parse()?,
                "appearance.border_radius" => config.appearance.border_radius = value.parse()?,
                "appearance.border_width" => config.appearance.border_width = value.parse()?,
                "appearance.icon_theme" => config.appearance.icon_theme = value.clone(),
                "appearance.cursor.name" => config.appearance.cursor.name = value.clone(),
                "appearance.cursor.size" => config.appearance.cursor.size = value.parse()?,
                "appearance.gaps.inner" => config.appearance.gaps.inner = value.parse()?,
                "appearance.gaps.outer" => config.appearance.gaps.outer = value.parse()?,
                _ => {
                    anyhow::bail!("Setting custom key path '{}' not supported via CLI directly. Please edit appearance.toml", key);
                }
            }

            ThemeEngine::save_appearance_config(&config)?;

            let theme_name = ThemeEngine::get_current_theme_name();
            let theme = ThemeEngine::find_theme(&theme_name)
                .unwrap_or_else(|| dot_tools::themes_db::get_builtin_themes()[0].clone());

            AppearancePopulator::populate_appearance(&config)?;
            AppearancePopulator::populate_theme_tokens(&theme.colors, &config)?;
            reload_desktop_apps();

            println!("{} Set {} = {} and re-populated configs.", "✔".green().bold(), key.cyan(), value.bold());
        }

        Some(Commands::Check) => {
            let config = ThemeEngine::load_appearance_config();
            let theme_name = ThemeEngine::get_current_theme_name();
            let theme = ThemeEngine::find_theme(&theme_name)
                .unwrap_or_else(|| dot_tools::themes_db::get_builtin_themes()[0].clone());

            println!("\n{}", "=== 🎨 Appearance Configuration Summary ===".bold().cyan());
            println!("  Typography:");
            println!("    Mono Font:    {}", config.fonts.mono.family.bold());
            println!("    Sans Font:    {}", config.fonts.sans.family.bold());
            println!("    Serif Font:   {}", config.fonts.serif.family.bold());
            println!("    Emoji Font:   {}", config.fonts.emoji.family.bold());
            println!("  Font Sizes:");
            println!("    Terminal:     {:.1} pt", config.fonts.sizes.terminal);
            println!("    Status Bar:   {:.1} pt", config.fonts.sizes.bar);
            println!("    App Launcher: {:.1} pt", config.fonts.sizes.launcher);
            println!("    Power Menu:   {:.1} pt", config.fonts.sizes.power_menu);
            println!("  Geometry & Borders:");
            println!("    Radius:       {} px", config.appearance.border_radius);
            println!("    Border Width: {} px", config.appearance.border_width);
            println!("    Inner Gap:    {} px", config.appearance.gaps.inner);
            println!("    Outer Gap:    {} px", config.appearance.gaps.outer);
            println!("  Theme & Palette:");
            println!("    Active Theme: {} ({})", theme.name.bold(), theme.polarity);
            println!("    Cursor Theme: {} ({}px)", config.appearance.cursor.name, config.appearance.cursor.size);
            println!("    Icon Theme:   {}", config.appearance.icon_theme);
            println!();
        }
    }

    Ok(())
}
