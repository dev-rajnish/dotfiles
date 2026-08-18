//! Wallpaper & Base16 Desktop Theme Manager in Rust
//! Manages wallpaper persistence, Swaybg background daemon, Base16 theme discovery
//! from the Nix store, interactive Fuzzel menus, and Home Manager profile activation.
//! Built with strict error handling and zero unwrap.

use anyhow::{Context, Result};
use clap::Parser;
use rand::seq::SliceRandom;
use regex::Regex;
use std::fs;
use std::io::{self, IsTerminal, Write};
use std::path::{Path, PathBuf};
use std::process::{Command, Stdio};
use sys_tools::{colors, extract_system_vars, find_dotfiles_dir, find_vars_file, home_dir, log_error, log_info, log_success, log_warn, spawn_detached};
use walkdir::WalkDir;

#[derive(Parser, Debug)]
#[command(name = "wallpaper", about = "Wallpaper & Base16 Theme Manager (Rust)")]
struct Args {
    #[arg(help = "Image path (e.g. from Waypaper post-command)")]
    image: Option<String>,

    #[arg(long, short = 'r', help = "Restore saved session wallpaper")]
    restore: bool,

    #[arg(long, short = 'g', help = "Launch Waypaper GUI in detached background mode")]
    gui: bool,

    #[arg(long, short = 'f', help = "Launch Waypaper GUI attached to terminal in foreground")]
    foreground: bool,

    #[arg(long, value_name = "PATH", help = "Waypaper post-command handler")]
    post: Option<String>,

    #[arg(long, short = 's', value_name = "PATH", help = "Set wallpaper image directly")]
    set: Option<String>,

    #[arg(long, short = 'R', alias = "rnd", help = "Apply random wallpaper from folder")]
    random: bool,

    #[arg(long, short = 'c', help = "Show current wallpaper path only")]
    current: bool,

    #[arg(long, help = "Show detailed wallpaper & theme dashboard")]
    status: bool,

    #[arg(long, short = 'l', help = "List all available wallpapers in gallery")]
    list: bool,

    #[arg(long, short = 't', help = "Pick and apply Base16 colorscheme directly")]
    theme: bool,
}

fn cache_dir() -> Result<PathBuf> {
    if let Ok(c) = std::env::var("XDG_CACHE_HOME") {
        Ok(PathBuf::from(c))
    } else {
        Ok(home_dir()?.join(".cache"))
    }
}

fn config_dir() -> Result<PathBuf> {
    if let Ok(c) = std::env::var("XDG_CONFIG_HOME") {
        Ok(PathBuf::from(c))
    } else {
        Ok(home_dir()?.join(".config"))
    }
}

fn state_file() -> Result<PathBuf> {
    Ok(cache_dir()?.join("wallpaper.path"))
}

fn link_file() -> Result<PathBuf> {
    Ok(cache_dir()?.join("current_wallpaper"))
}

fn default_fallback() -> Result<PathBuf> {
    Ok(config_dir()?.join("niri/niri.d/wallpaper.png"))
}

fn resolve_image_path(raw: &str) -> Option<PathBuf> {
    if raw.trim().is_empty() {
        return None;
    }
    let home = home_dir().ok()?;
    let path = if let Some(stripped) = raw.strip_prefix("~/") {
        home.join(stripped)
    } else {
        PathBuf::from(raw)
    };

    if path.is_file() {
        path.canonicalize().ok()
    } else {
        None
    }
}

fn get_wallpaper_dir() -> Result<PathBuf> {
    let home = home_dir()?;
    let candidates = [
        home.join("_ws/walls"),
        home.join("ws/walls"),
        home.join("Pictures/Wallpapers"),
        home.join("Pictures"),
    ];

    for c in &candidates {
        if c.is_dir() {
            return Ok(c.clone());
        }
    }
    Ok(candidates[0].clone())
}

fn get_all_wallpapers(folder: &Path) -> Vec<PathBuf> {
    let mut images = Vec::new();
    let valid_exts = ["png", "jpg", "jpeg", "webp", "PNG", "JPG", "JPEG", "WEBP"];

    for entry in WalkDir::new(folder).follow_links(true).into_iter().filter_map(|e| e.ok()) {
        if entry.file_type().is_file() {
            if let Some(ext) = entry.path().extension().and_then(|s| s.to_str()) {
                if valid_exts.contains(&ext) {
                    images.push(entry.path().to_path_buf());
                }
            }
        }
    }
    images.sort();
    images
}

fn get_base16_themes() -> Vec<String> {
    let mut themes = Vec::new();
    let store_paths = [
        "/nix/store",
        "/run/current-system/sw/share/themes",
    ];

    for base in &store_paths {
        if let Ok(entries) = fs::read_dir(base) {
            for entry in entries.filter_map(|e| e.ok()) {
                let name = entry.file_name().to_string_lossy().to_string();
                if name.contains("base16") {
                    let share_themes = entry.path().join("share/themes");
                    if share_themes.is_dir() {
                        if let Ok(theme_files) = fs::read_dir(&share_themes) {
                            for tf in theme_files.filter_map(|e| e.ok()) {
                                if let Some(ext) = tf.path().extension() {
                                    if ext == "yaml" {
                                        if let Some(stem) = tf.path().file_stem().and_then(|s| s.to_str()) {
                                            themes.push(stem.to_string());
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    themes.sort();
    themes.dedup();
    themes
}

fn select_colorscheme_fuzzel() -> Result<Option<String>> {
    let themes = get_base16_themes();
    if themes.is_empty() {
        log_warn("No Base16 themes found in Nix store.");
        return Ok(None);
    }

    let menu_text = themes.join("\n") + "\n";
    let mut child = Command::new("fuzzel")
        .args([
            "--dmenu",
            "--prompt", "Colorscheme: ",
            "--placeholder", "Select Base16 colorscheme (Esc to cancel)...",
            "--lines", "15",
            "--width", "30",
            "--horizontal-pad", "20",
            "--vertical-pad", "15",
        ])
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::null())
        .spawn()
        .context("Failed to spawn Fuzzel")?;

    if let Some(mut stdin) = child.stdin.take() {
        stdin.write_all(menu_text.as_bytes())?;
    }

    let output = child.wait_with_output()?;
    let selected = String::from_utf8_lossy(&output.stdout).trim().to_string();
    if selected.is_empty() {
        Ok(None)
    } else {
        Ok(Some(selected))
    }
}

fn apply_colorscheme(scheme_name: &str) -> Result<bool> {
    let dot_dir = find_dotfiles_dir()?;
    let vars_file = find_vars_file(&dot_dir)
        .context("0-system-vars.nix not found in dotfiles directory")?;

    log_info(&format!("Updating theme to '{}' in {}...", scheme_name, vars_file.file_name().unwrap_or_default().to_string_lossy()));
    let content = fs::read_to_string(&vars_file)?;

    let re_theme = Regex::new(r#"(?m)(^\s*theme\s*=\s*")[^"]*(";)"#)?;
    let re_colorscheme = Regex::new(r#"(?m)(^\s*colorscheme\s*=\s*")[^"]*(";)"#)?;

    let updated = if re_theme.is_match(&content) {
        re_theme.replace(&content, format!("${{1}}{}${{2}}", scheme_name)).to_string()
    } else if re_colorscheme.is_match(&content) {
        re_colorscheme.replace(&content, format!("${{1}}{}${{2}}", scheme_name)).to_string()
    } else {
        log_warn("Could not locate theme field in 0-system-vars.nix");
        return Ok(false);
    };

    fs::write(&vars_file, updated)?;

    let _ = Command::new("notify-send")
        .args([
            "-a", "Colorscheme",
            "-h", "string:x-canonical-private-synchronous:colorscheme-change",
            "Applying Colorscheme",
            &format!("Theme: {}", scheme_name),
        ])
        .status();

    log_info(&format!("Building and activating Home Manager profile ({scheme_name})..."));
    let status = Command::new("nix")
        .args(["run", ".#homeConfigurations.rsh.activationPackage"])
        .current_dir(&dot_dir)
        .status()?;

    if status.success() {
        let _ = Command::new("notify-send")
            .args([
                "-a", "Colorscheme",
                "-h", "string:x-canonical-private-synchronous:colorscheme-change",
                "Colorscheme Applied",
                &format!("Successfully updated to {}", scheme_name),
            ])
            .status();
        log_success(&format!("Colorscheme applied successfully: {}", scheme_name));
        Ok(true)
    } else {
        log_warn(&format!("Activation finished with exit code: {:?}", status.code()));
        Ok(false)
    }
}

fn apply_and_persist(img_path: &Path) -> Result<()> {
    let cache = cache_dir()?;
    fs::create_dir_all(&cache)?;

    let state = state_file()?;
    fs::write(&state, format!("{}\n", img_path.display()))?;

    let link = link_file()?;
    let _ = fs::remove_file(&link);
    #[cfg(unix)]
    std::os::unix::fs::symlink(img_path, &link)?;

    // Niri sync
    let niri_d = config_dir()?.join("niri/niri.d");
    if niri_d.is_dir() {
        let target = niri_d.join("wallpaper.png");
        let _ = fs::remove_file(&target);
        if fs::hard_link(img_path, &target).is_err() {
            let _ = fs::copy(img_path, &target);
        }
    }

    let file_name = img_path.file_name().unwrap_or_default().to_string_lossy();
    let _ = Command::new("notify-send")
        .args([
            "-a", "Wallpaper",
            "-i", &img_path.to_string_lossy(),
            "-h", "string:x-canonical-private-synchronous:wallpaper-change",
            "Wallpaper Updated",
            &file_name,
        ])
        .status();

    log_success(&format!("Wallpaper persisted: {}", img_path.display()));
    Ok(())
}

fn start_swaybg(img_path: &Path) -> Result<()> {
    log_info(&format!("Spawning swaybg daemon with {}...", img_path.file_name().unwrap_or_default().to_string_lossy()));
    let _ = Command::new("pkill").args(["-x", "swaybg"]).status();
    spawn_detached("swaybg", &["-i", &img_path.to_string_lossy(), "-m", "fill"])?;
    Ok(())
}

fn restore_session(silent: bool) -> Result<()> {
    let state = state_file()?;
    let mut target = None;

    if state.is_file() {
        if let Ok(saved) = fs::read_to_string(&state) {
            target = resolve_image_path(saved.trim());
        }
    }

    if target.is_none() {
        let fallback = default_fallback()?;
        if fallback.is_file() {
            target = Some(fallback);
        }
    }

    if target.is_none() {
        let wall_dir = get_wallpaper_dir()?;
        let all_walls = get_all_wallpapers(&wall_dir);
        if let Some(first) = all_walls.first() {
            target = Some(first.clone());
        }
    }

    if let Some(img) = target {
        start_swaybg(&img)?;
        apply_and_persist(&img)?;
        if !silent {
            log_success(&format!("Wallpaper session restored: {}", img.display()));
        }
    } else if !silent {
        log_warn("No wallpaper found to restore.");
    }

    Ok(())
}

fn get_current_wallpaper() -> Option<PathBuf> {
    if let Ok(state) = state_file() {
        if let Ok(saved) = fs::read_to_string(state) {
            if let Some(p) = resolve_image_path(saved.trim()) {
                return Some(p);
            }
        }
    }
    if let Ok(link) = link_file() {
        if link.exists() {
            if let Ok(target) = link.canonicalize() {
                return Some(target);
            }
        }
    }
    None
}

fn print_status() -> Result<()> {
    let cur_wall = get_current_wallpaper();
    let wall_str = cur_wall.as_ref().map(|p| p.to_string_lossy().to_string()).unwrap_or_else(|| "None set".to_string());
    let dot_dir = find_dotfiles_dir()?;
    let vars = extract_system_vars(&dot_dir)?;
    let wall_dir = get_wallpaper_dir()?;
    let wall_count = get_all_wallpapers(&wall_dir).len();
    let theme_count = get_base16_themes().len();

    println!("\n{}============================================================================={}", colors::HEADER, colors::RESET);
    println!("{}   🎨 Wallpaper & Base16 Desktop Theme Manager (Rust){}", colors::BOLD, colors::RESET);
    println!("{}============================================================================={}", colors::HEADER, colors::RESET);
    println!("  • {}Active Wallpaper:{}    {}{}{}", colors::BOLD, colors::RESET, colors::CYAN, wall_str, colors::RESET);
    println!("  • {}Active Base16 Theme:{} {}{}{}", colors::BOLD, colors::RESET, colors::GREEN, vars.theme, colors::RESET);
    println!("  • {}Wallpaper Gallery:{}   {}{}{} ({} images)", colors::BOLD, colors::RESET, colors::YELLOW, wall_dir.display(), colors::RESET, wall_count);
    println!("  • {}Base16 Schemes:{}      {}{} themes available in Nix store{}", colors::BOLD, colors::RESET, colors::YELLOW, theme_count, colors::RESET);
    println!("{}============================================================================={}", colors::HEADER, colors::RESET);
    Ok(())
}

fn list_wallpapers() -> Result<()> {
    let wall_dir = get_wallpaper_dir()?;
    let images = get_all_wallpapers(&wall_dir);
    let cur_wall = get_current_wallpaper();

    println!("\n{}🖼️ Wallpapers in {} ({} found):{}", colors::CYAN, wall_dir.display(), images.len(), colors::RESET);
    println!("-----------------------------------------------------------------------------");
    for (idx, img) in images.iter().enumerate() {
        let is_cur = cur_wall.as_ref() == Some(img);
        let active_tag = if is_cur { " ★ (Active)" } else { "" };
        let color = if is_cur { colors::GREEN } else { colors::RESET };
        println!("  [{:2}] {}{}{}{}", idx + 1, color, img.file_name().unwrap_or_default().to_string_lossy(), active_tag, colors::RESET);
    }
    println!("-----------------------------------------------------------------------------");
    Ok(())
}

fn apply_random() -> Result<()> {
    let wall_dir = get_wallpaper_dir()?;
    let images = get_all_wallpapers(&wall_dir);
    if let Some(chosen) = images.choose(&mut rand::thread_rng()) {
        log_info(&format!("Selected random wallpaper: {}", chosen.file_name().unwrap_or_default().to_string_lossy()));
        start_swaybg(chosen)?;
        apply_and_persist(chosen)?;
    } else {
        log_error(&format!("No image files found in {}", wall_dir.display()));
    }
    Ok(())
}

fn launch_gui(foreground: bool) -> Result<()> {
    if which::which("waypaper").is_err() {
        log_error("'waypaper' binary not found in PATH.");
        return Ok(());
    }

    if foreground {
        log_info("Launching Waypaper GUI in foreground mode...");
        let _ = Command::new("waypaper").status();
    } else {
        let pid = spawn_detached("waypaper", &[])?;
        log_success(&format!("Waypaper GUI launched in background (PID: {})", pid));
    }
    Ok(())
}

fn run_interactive_dashboard() -> Result<()> {
    print_status()?;

    println!("\n:: Select an Action:");
    println!("  [{0}1{1}] 🎲 Set Random Wallpaper", colors::CYAN, colors::RESET);
    println!("  [{0}2{1}] 🎨 Change Base16 Colorscheme (Fuzzel)", colors::CYAN, colors::RESET);
    println!("  [{0}3{1}] 🖼️  Launch Waypaper GUI", colors::CYAN, colors::RESET);
    println!("  [{0}4{1}] 📜 List All Wallpapers", colors::CYAN, colors::RESET);
    println!("  [{0}5{1}] 🔄 Restore Session Wallpaper", colors::CYAN, colors::RESET);
    println!("  [{0}q{1}] 🚪 Exit\n", colors::CYAN, colors::RESET);

    print!("Enter choice [1-5 / q]: ");
    let _ = io::stdout().flush();

    let mut input = String::new();
    if io::stdin().read_line(&mut input).is_ok() {
        match input.trim().to_lowercase().as_str() {
            "1" | "r" | "rnd" | "random" => apply_random()?,
            "2" | "t" | "theme" => {
                if let Some(scheme) = select_colorscheme_fuzzel()? {
                    apply_colorscheme(&scheme)?;
                }
            }
            "3" | "g" | "gui" => launch_gui(false)?,
            "4" | "l" | "list" => list_wallpapers()?,
            "5" | "restore" => restore_session(false)?,
            "q" | "exit" | "quit" => {}
            _ => log_warn("Invalid choice."),
        }
    }
    Ok(())
}

fn main() -> Result<()> {
    let args = Args::parse();

    if args.gui {
        return launch_gui(args.foreground);
    }

    if args.current {
        if let Some(cur) = get_current_wallpaper() {
            println!("{}", cur.display());
        }
        return Ok(());
    }

    if args.status {
        return print_status();
    }

    if args.list {
        return list_wallpapers();
    }

    if args.theme {
        if let Some(scheme) = select_colorscheme_fuzzel()? {
            apply_colorscheme(&scheme)?;
        }
        return Ok(());
    }

    if args.random {
        return apply_random();
    }

    if let Some(ref set_path) = args.set {
        if let Some(img) = resolve_image_path(set_path) {
            start_swaybg(&img)?;
            apply_and_persist(&img)?;
        } else {
            log_error(&format!("Wallpaper image not found: {}", set_path));
        }
        return Ok(());
    }

    if let Some(ref post_path) = args.post {
        if let Some(img) = resolve_image_path(post_path) {
            start_swaybg(&img)?;
            apply_and_persist(&img)?;
        }
        return Ok(());
    }

    if let Some(ref img_path) = args.image {
        if let Some(img) = resolve_image_path(img_path) {
            start_swaybg(&img)?;
            apply_and_persist(&img)?;
        }
        return Ok(());
    }

    if args.restore {
        return restore_session(true);
    }

    // Default action in terminal
    if io::stdout().is_terminal() {
        run_interactive_dashboard()?;
    } else {
        restore_session(true)?;
    }

    Ok(())
}
