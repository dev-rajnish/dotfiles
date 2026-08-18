//! Antigravity CLI Release Checker & Nix Package Auto-Updater (Rust)
//! Fetches release manifest, converts SHA-512 to SRI format, and updates package Nix file.
//! Built with strict error handling and zero unwrap.

use anyhow::{Context, Result};
use clap::Parser;
use regex::Regex;
use serde::Deserialize;
use std::fs;
use std::process::Command;
use sys_tools::{colors, find_dotfiles_dir, log_error, log_info, log_success, log_warn};

const MANIFEST_URL: &str =
    "https://antigravity-cli-auto-updater-974169037036.us-central1.run.app/manifests/linux_amd64.json";

#[derive(Parser, Debug)]
#[command(name = "update-agy", about = "Antigravity CLI Auto-Updater (Rust)")]
struct Args {
    #[arg(long, help = "Only check for updates without modifying files")]
    check_only: bool,

    #[arg(long, help = "Print what would change without modifying files")]
    dry_run: bool,
}

#[derive(Deserialize, Debug)]
struct Manifest {
    version: Option<String>,
    url: Option<String>,
    sha512: Option<String>,
}

fn convert_hash_to_sri(sha512_hex: &str) -> Result<String> {
    let output = Command::new("nix")
        .args(["hash", "convert", "--hash-algo", "sha512", "--to", "sri", sha512_hex])
        .output()
        .context("Failed to run 'nix hash convert'")?;

    if !output.status.success() {
        let err = String::from_utf8_lossy(&output.stderr);
        anyhow::bail!("Nix hash convert failed: {}", err);
    }

    Ok(String::from_utf8_lossy(&output.stdout).trim().to_string())
}

fn fetch_manifest() -> Result<Option<Manifest>> {
    match ureq::get(MANIFEST_URL)
        .set("User-Agent", "Antigravity-Updater/Rust")
        .timeout(std::time::Duration::from_secs(10))
        .call()
    {
        Ok(response) => {
            let manifest: Manifest = serde_json::from_reader(response.into_reader())
                .context("Failed to parse release manifest JSON")?;
            Ok(Some(manifest))
        }
        Err(e) => {
            log_warn(&format!("Could not reach release server ({}). Skipping update check.", e));
            Ok(None)
        }
    }
}

fn main() -> Result<()> {
    let args = Args::parse();
    let dot_dir = find_dotfiles_dir()?;
    let agy_nix = dot_dir.join("home-manager/pkgs/antigravity-cli.nix");

    if !agy_nix.is_file() {
        log_error(&format!("Package file not found at {}", agy_nix.display()));
        return Ok(());
    }

    log_info("Checking for Antigravity CLI updates (Rust)...");
    let manifest_opt = fetch_manifest()?;
    let manifest = match manifest_opt {
        Some(m) => m,
        None => return Ok(()),
    };

    let (new_ver, new_url, new_sha512) = match (&manifest.version, &manifest.url, &manifest.sha512) {
        (Some(v), Some(u), Some(s)) => (v, u, s),
        _ => {
            log_warn("Incomplete manifest received from server.");
            return Ok(());
        }
    };

    let content = fs::read_to_string(&agy_nix)
        .with_context(|| format!("Failed to read {}", agy_nix.display()))?;

    let re_ver = Regex::new(r#"version\s*=\s*"([^"]+)""#)?;
    let cur_ver = re_ver
        .captures(&content)
        .and_then(|c| c.get(1))
        .map(|m| m.as_str())
        .unwrap_or("unknown");

    println!("  Current version: {}{}{}", colors::CYAN, cur_ver, colors::RESET);
    println!("  Latest version:  {}{}{}", colors::GREEN, new_ver, colors::RESET);

    if cur_ver == new_ver {
        log_success(&format!("Antigravity CLI is up to date (v{})", cur_ver));
        return Ok(());
    }

    let new_sri = convert_hash_to_sri(new_sha512)?;
    log_info(&format!("New version available: v{} -> v{}", cur_ver, new_ver));
    println!("   SRI Hash: {}", new_sri);

    if args.check_only {
        return Ok(());
    }

    if args.dry_run {
        log_warn("Dry-run mode enabled; skipping file modification.");
        return Ok(());
    }

    let re_ver_replace = Regex::new(r#"version\s*=\s*"[^"]+""#)?;
    let re_url_replace = Regex::new(r#"url\s*=\s*"[^"]+""#)?;
    let re_hash_replace = Regex::new(r#"hash\s*=\s*"[^"]+""#)?;

    let mut updated = re_ver_replace.replace(&content, format!("version = \"{}\"", new_ver)).to_string();
    updated = re_url_replace.replace(&updated, format!("url = \"{}\"", new_url)).to_string();
    updated = re_hash_replace.replace(&updated, format!("hash = \"{}\"", new_sri)).to_string();

    fs::write(&agy_nix, updated)?;
    log_success(&format!("Successfully updated {} to v{}", agy_nix.display(), new_ver));

    Ok(())
}
