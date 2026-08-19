use anyhow::Result;
use clap::Parser;
use colored::Colorize;
use std::fs;
use std::path::{Path, PathBuf};

#[derive(Parser, Debug)]
#[command(
    name = "sl-render",
    author = "dev-rajnish <dev.rajnish@proton.me>",
    version = "0.5.0",
    about = "Template renderer for Shoelace / Dotfiles configs"
)]
struct Cli {
    /// Path to data TOML file or directory containing modular *.toml files
    #[arg(short, long)]
    data: Option<PathBuf>,

    /// Path to configuration TOML mapping templates to target destinations
    #[arg(short, long)]
    config: Option<PathBuf>,

    /// Path to templates directory containing template files
    #[arg(short, long)]
    templates: Option<PathBuf>,

    /// Preview rendered output without writing files to disk
    #[arg(long)]
    dry_run: bool,

    /// Show detailed verbose logs
    #[arg(short, long)]
    verbose: bool,
}

#[derive(Debug, Clone)]
struct RenderTask {
    app_name: String,
    template_name: String,
    destinations: Vec<String>,
}

/// Expands leading `~/` to the user's $HOME directory
fn expand_path(p: impl AsRef<Path>) -> PathBuf {
    let p = p.as_ref();
    if let Ok(stripped) = p.strip_prefix("~/") {
        if let Some(home) = dirs::home_dir() {
            return home.join(stripped);
        }
    } else if let Some(str_val) = p.to_str() {
        if str_val.starts_with('~') {
            if let Some(home) = dirs::home_dir() {
                let rest = str_val.trim_start_matches('~').trim_start_matches('/');
                return home.join(rest);
            }
        }
    }
    p.to_path_buf()
}

/// Recursively deep-merge two serde_json Values
fn merge_json_values(a: &mut serde_json::Value, b: serde_json::Value) {
    match (a, b) {
        (serde_json::Value::Object(a_map), serde_json::Value::Object(b_map)) => {
            for (k, v) in b_map {
                if let Some(existing) = a_map.get_mut(&k) {
                    merge_json_values(existing, v);
                } else {
                    a_map.insert(k, v);
                }
            }
        }
        (a_val, b_val) => *a_val = b_val,
    }
}

/// Parse a single TOML file into serde_json::Value
fn parse_toml_file(path: &Path) -> Result<serde_json::Value, String> {
    let content = fs::read_to_string(path)
        .map_err(|e| format!("Failed to read {:?}: {}", path, e))?;
    toml::from_str::<serde_json::Value>(&content)
        .map_err(|e| format!("Invalid TOML syntax in {:?}: {}", path, e))
}

/// Recursively collect all *.toml files in a directory and its subdirectories
fn collect_toml_files_recursive(dir: &Path, files: &mut Vec<PathBuf>) {
    if let Ok(read_dir) = fs::read_dir(dir) {
        for entry in read_dir.flatten() {
            let path = entry.path();
            if path.is_dir() {
                collect_toml_files_recursive(&path, files);
            } else if path.is_file() && path.extension().and_then(|s| s.to_str()) == Some("toml") {
                files.push(path);
            }
        }
    }
}

/// Load and merge data from a file or directory of modular *.toml files
fn load_merged_data(target: &Path, verbose: bool) -> Result<serde_json::Value, String> {
    let mut merged = serde_json::Value::Object(serde_json::Map::new());

    if target.is_dir() {
        let mut entries = Vec::new();
        collect_toml_files_recursive(target, &mut entries);
        entries.sort();

        if entries.is_empty() {
            return Err(format!("No .toml files found in data directory {:?}", target));
        }

        for file_path in entries {
            if verbose {
                let relative = file_path.strip_prefix(target).unwrap_or(&file_path);
                println!("  {} Loading data module: {:?}", "•".cyan(), relative.display());
            }
            let val = parse_toml_file(&file_path)?;
            merge_json_values(&mut merged, val);
        }
    } else if target.is_file() {
        if verbose {
            println!("  {} Loading data file: {:?}", "•".cyan(), target);
        }
        merged = parse_toml_file(target)?;
    } else {
        return Err(format!("Data path {:?} does not exist", target));
    }

    Ok(merged)
}

/// Extract list of destination paths from TOML value
fn extract_destinations(val: &toml::Value) -> Option<Vec<String>> {
    match val {
        toml::Value::String(s) => Some(vec![s.clone()]),
        toml::Value::Array(arr) => {
            let mut res = Vec::new();
            for item in arr {
                if let toml::Value::String(s) = item {
                    res.push(s.clone());
                }
            }
            if res.is_empty() { None } else { Some(res) }
        }
        _ => None,
    }
}

/// Extract render task from a table entry or value
fn extract_task_from_entry(key: &str, val: &toml::Value, tasks: &mut Vec<RenderTask>) {
    match val {
        toml::Value::Table(table) => {
            let template_name = table
                .get("template")
                .and_then(|v| v.as_str())
                .unwrap_or(key)
                .to_string();

            let dests = table
                .get("dest")
                .or_else(|| table.get("destination"))
                .or_else(|| table.get("target"))
                .or_else(|| table.get("path"))
                .and_then(extract_destinations);

            if let Some(dests) = dests {
                tasks.push(RenderTask {
                    app_name: key.to_string(),
                    template_name,
                    destinations: dests,
                });
            }
        }
        other => {
            if let Some(dests) = extract_destinations(other) {
                tasks.push(RenderTask {
                    app_name: key.to_string(),
                    template_name: key.to_string(),
                    destinations: dests,
                });
            }
        }
    }
}

/// Parse configuration file supporting `[appname] template = "..." dest = "..."`
fn parse_config_file(config_path: &Path) -> Result<Vec<RenderTask>, String> {
    let content = fs::read_to_string(config_path)
        .map_err(|e| format!("Failed to read config file {:?}: {}", config_path, e))?;

    let root_val: toml::Value = toml::from_str(&content)
        .map_err(|e| format!("Invalid TOML syntax in {:?}: {}", config_path, e))?;

    let root_table = match root_val {
        toml::Value::Table(t) => t,
        _ => return Err(format!("Root of {:?} must be a TOML table", config_path)),
    };

    let mut tasks = Vec::new();

    for (key, val) in root_table {
        if key == "apps" {
            if let toml::Value::Table(apps_table) = val {
                for (app_k, app_v) in apps_table {
                    extract_task_from_entry(&app_k, &app_v, &mut tasks);
                }
            }
        } else {
            extract_task_from_entry(&key, &val, &mut tasks);
        }
    }

    Ok(tasks)
}

/// Resolve template file by trying exact name, then .mustache, then prefix matching
fn resolve_template_path(templates_dir: &Path, template_name: &str) -> Option<PathBuf> {
    // 1. Direct path (e.g., "nushell_alias.nu" or "niri_keybinds.kdl")
    let direct = templates_dir.join(template_name);
    if direct.is_file() {
        return Some(direct);
    }

    // 2. Backward compatibility with .mustache extension
    let with_mustache = templates_dir.join(format!("{}.mustache", template_name));
    if with_mustache.is_file() {
        return Some(with_mustache);
    }

    // 3. Match any file in templates_dir with stem matching template_name
    if let Ok(read_dir) = fs::read_dir(templates_dir) {
        for entry in read_dir.flatten() {
            let path = entry.path();
            if path.is_file() {
                if let Some(stem) = path.file_stem().and_then(|s| s.to_str()) {
                    if stem == template_name {
                        return Some(path);
                    }
                }
            }
        }
    }

    None
}

/// Resolve existing file or fallback to first default candidate
fn resolve_file_with_fallbacks(candidates: &[PathBuf]) -> PathBuf {
    for path in candidates {
        if path.exists() {
            return path.clone();
        }
    }
    candidates[0].clone()
}

/// Resolve existing directory or fallback to first candidate
fn resolve_dir_with_fallbacks(candidates: &[PathBuf]) -> PathBuf {
    for path in candidates {
        if path.is_dir() {
            return path.clone();
        }
    }
    candidates[0].clone()
}

fn main() -> Result<()> {
    let cli = Cli::parse();

    // 1. Resolve Data Path (Supports directory ~/.config/shoelace/data/ or data.toml)
    let data_target = match cli.data {
        Some(p) => expand_path(p),
        None => {
            let dir_candidates = [
                expand_path("~/.config/shoelace/data"),
                expand_path("~/.config/sl/data"),
                expand_path("~/.config/dot/data"),
            ];
            let mut resolved = None;
            for dir in &dir_candidates {
                if dir.is_dir() {
                    resolved = Some(dir.clone());
                    break;
                }
            }

            resolved.unwrap_or_else(|| {
                resolve_file_with_fallbacks(&[
                    expand_path("~/.config/shoelace/data.toml"),
                    expand_path("~/.config/sl/data.toml"),
                    expand_path("~/.config/dot/data.toml"),
                    expand_path("~/.config/env/data.toml"),
                ])
            })
        }
    };

    // 2. Resolve Config Path
    let config_path = match cli.config {
        Some(p) => expand_path(p),
        None => resolve_file_with_fallbacks(&[
            expand_path("~/.config/shoelace/shoelace.toml"),
            expand_path("~/.config/shoelace/dot.toml"),
            expand_path("~/.config/sl/sl.toml"),
            expand_path("~/.config/dot/dot.toml"),
            expand_path("~/.config/shoelace/apps.toml"),
        ]),
    };

    // 3. Resolve Templates Directory
    let templates_dir = match cli.templates {
        Some(p) => expand_path(p),
        None => resolve_dir_with_fallbacks(&[
            expand_path("~/.config/shoelace/templates"),
            expand_path("~/.config/sl/templates"),
            expand_path("~/.config/dot/templates"),
        ]),
    };

    if cli.verbose {
        println!("{}", "─── Shoelace Template Renderer ───".bold().cyan());
        println!("📂 Data Source:     {:?}", data_target);
        println!("⚙️  Config File:     {:?}", config_path);
        println!("📁 Templates Dir:   {:?}", templates_dir);
        println!("──────────────────────────────────");
    }

    // 4. Load & Recursively Merge Data
    let data_val = match load_merged_data(&data_target, cli.verbose) {
        Ok(v) => v,
        Err(e) => {
            eprintln!("{} {}", "❌".red(), e);
            return Ok(());
        }
    };

    // 5. Read and Parse Config File (Tasks)
    let render_tasks = match parse_config_file(&config_path) {
        Ok(tasks) => tasks,
        Err(e) => {
            eprintln!("{} {}", "❌".red(), e);
            return Ok(());
        }
    };

    if render_tasks.is_empty() {
        println!(
            "{} No application template mappings found in {:?}",
            "ℹ".yellow(),
            config_path
        );
        return Ok(());
    }

    // 6. Process Each App Template Mapping
    let mut rendered_count = 0;
    let mut error_count = 0;

    for task in &render_tasks {
        let tmpl_path = match resolve_template_path(&templates_dir, &task.template_name) {
            Some(p) => p,
            None => {
                eprintln!(
                    "{} Missing template file for '{}' in {:?} (Skipping [{}])",
                    "⚠".yellow(),
                    task.template_name,
                    templates_dir,
                    task.app_name
                );
                error_count += 1;
                continue;
            }
        };

        let tmpl_display_name = tmpl_path
            .file_name()
            .and_then(|s| s.to_str())
            .unwrap_or(&task.template_name);

        // Read template
        let tmpl_content = match fs::read_to_string(&tmpl_path) {
            Ok(content) => content,
            Err(e) => {
                eprintln!(
                    "{} Error reading {:?}: {} (Skipping [{}])",
                    "⚠".yellow(),
                    tmpl_path,
                    e,
                    task.app_name
                );
                error_count += 1;
                continue;
            }
        };

        // Compile template
        let template = match mustache::compile_str(&tmpl_content) {
            Ok(t) => t,
            Err(e) => {
                eprintln!(
                    "{} Compile error in {:?}: {} (Skipping [{}])",
                    "⚠".yellow(),
                    tmpl_path,
                    e,
                    task.app_name
                );
                error_count += 1;
                continue;
            }
        };

        // Render variables
        let rendered = match template.render_to_string(&data_val) {
            Ok(r) => r,
            Err(e) => {
                eprintln!(
                    "{} Render error for {:?}: {} (Skipping [{}])",
                    "⚠".yellow(),
                    tmpl_path,
                    e,
                    task.app_name
                );
                error_count += 1;
                continue;
            }
        };

        for target_str in &task.destinations {
            let target_path = expand_path(target_str);

            if cli.dry_run {
                println!(
                    "{} [DRY-RUN] [{}] {} -> {:?}",
                    "🔍".cyan(),
                    task.app_name.bold(),
                    tmpl_display_name,
                    target_path
                );
                if cli.verbose {
                    println!("---\n{}\n---", rendered);
                }
                rendered_count += 1;
                continue;
            }

            // Create target directory if it doesn't exist
            if let Some(parent) = target_path.parent() {
                if !parent.exists() {
                    if let Err(e) = fs::create_dir_all(parent) {
                        eprintln!(
                            "{} Failed to create dir {:?}: {} (Skipping)",
                            "⚠".yellow(),
                            parent,
                            e
                        );
                        error_count += 1;
                        continue;
                    }
                }
            }

            // Write output
            if let Err(e) = fs::write(&target_path, &rendered) {
                eprintln!(
                    "{} Failed to write {:?}: {} (Skipping)",
                    "⚠".yellow(),
                    target_path,
                    e
                );
                error_count += 1;
                continue;
            }

            println!(
                "{} [{}] Rendered: {} -> {:?}",
                "✓".green(),
                task.app_name.bold(),
                tmpl_display_name,
                target_path
            );
            rendered_count += 1;
        }
    }

    if cli.verbose || error_count > 0 {
        println!(
            "\n{} Completed: {} rendered, {} skipped/failed",
            "✨".bold(),
            rendered_count.to_string().green(),
            error_count.to_string().red()
        );
    }

    Ok(())
}
