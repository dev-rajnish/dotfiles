use std::process::Command;

pub fn execute_cmd(cmd: &str) -> anyhow::Result<String> {
    let output = Command::new("sh")
        .arg("-c")
        .arg(cmd)
        .output()?;

    let stdout = String::from_utf8_lossy(&output.stdout).to_string();
    if !output.status.success() {
        let stderr = String::from_utf8_lossy(&output.stderr).to_string();
        anyhow::bail!("Command '{}' failed with status {}: {}", cmd, output.status, stderr);
    }
    Ok(stdout)
}

pub fn run_detached(cmd: &str) {
    let _ = Command::new("sh")
        .arg("-c")
        .arg(cmd)
        .spawn();
}

pub fn notify(title: &str, message: &str, icon: Option<&str>) {
    let mut cmd = Command::new("notify-send");
    cmd.arg(title).arg(message);
    if let Some(i) = icon {
        cmd.arg("-i").arg(i);
    }
    let _ = cmd.spawn();
}

pub fn reload_desktop_apps() {
    // Kitty reload: SIGUSR1 reloads kitty.conf & colors.conf
    let _ = Command::new("pkill")
        .args(["-SIGUSR1", "kitty"])
        .spawn();

    // Labwc reconfigure
    let _ = Command::new("labwc")
        .arg("--reconfigure")
        .spawn();

    // Wayle bar reload
    let _ = Command::new("sh")
        .arg("-c")
        .arg("wayle panel restart 2>/dev/null || wayle shell 2>/dev/null || true")
        .spawn();
}
