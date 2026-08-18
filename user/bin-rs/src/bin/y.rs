//! Yazi CWD Wrapper in Rust ('y')
//! Launches Yazi with a temporary --cwd-file, captures directory changes,
//! and outputs the destination or spawns a shell in the target directory.
//! Built with strict error handling, RAII cleanup, and zero unwrap.

use anyhow::{Context, Result};
use std::env;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::{Command, Stdio};

/// RAII Guard that automatically cleans up the temporary file on exit.
struct TempFileGuard {
    path: PathBuf,
}

impl TempFileGuard {
    fn new(prefix: &str) -> Result<Self> {
        let pid = nix::unistd::getpid();
        let timestamp = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .map(|d| d.as_nanos())
            .unwrap_or(0);
        let path = env::temp_dir().join(format!("{}-{}-{}.tmp", prefix, pid, timestamp));
        Ok(Self { path })
    }

    fn path(&self) -> &Path {
        &self.path
    }
}

impl Drop for TempFileGuard {
    fn drop(&mut self) {
        if self.path.exists() {
            let _ = fs::remove_file(&self.path);
        }
    }
}

/// Runs Yazi with forwarded CLI arguments, capturing any directory change.
fn run_yazi(args: &[String]) -> Result<Option<PathBuf>> {
    let tmp = TempFileGuard::new("yazi-cwd")?;
    let cwd_flag = format!("--cwd-file={}", tmp.path().display());

    let status = Command::new("yazi")
        .args(args)
        .arg(&cwd_flag)
        .stdin(Stdio::inherit())
        .stdout(Stdio::inherit())
        .stderr(Stdio::inherit())
        .status()
        .context("Failed to execute 'yazi'. Ensure yazi is installed.")?;

    if !status.success() {
        return Ok(None);
    }

    if tmp.path().is_file() {
        let content = fs::read_to_string(tmp.path())
            .with_context(|| format!("Failed to read {}", tmp.path().display()))?;
        let target = content.trim();

        if !target.is_empty() {
            let target_path = PathBuf::from(target);
            if let Ok(current_dir) = env::current_dir() {
                if target_path != current_dir && target_path.is_dir() {
                    return Ok(Some(target_path));
                }
            } else if target_path.is_dir() {
                return Ok(Some(target_path));
            }
        }
    }

    Ok(None)
}

fn main() -> Result<()> {
    // Collect forwarded arguments excluding program name
    let args: Vec<String> = env::args().skip(1).collect();

    // Check if called in shell command emission mode (e.g. `y --print-cd`)
    let print_mode = args.iter().any(|a| a == "--print-cd");
    let forwarded_args: Vec<String> = args.into_iter().filter(|a| a != "--print-cd").collect();

    if let Some(target_dir) = run_yazi(&forwarded_args)? {
        if print_mode {
            // Emits Fish / Bash `cd` command to stdout for eval/source
            println!("cd -- \"{}\"", target_dir.display());
        } else {
            // Print target directory path to stdout (for `cd (y $argv)`)
            println!("{}", target_dir.display());
        }
    }

    Ok(())
}
