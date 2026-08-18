use std::io::Write;
use std::process::{Command, Stdio};

pub fn prompt_menu(items: &[String], prompt: &str, placeholder: Option<&str>) -> anyhow::Result<Option<String>> {
    // Check if fuzzel is available in PATH and WAYLAND_DISPLAY / DISPLAY is set
    let has_wayland = std::env::var("WAYLAND_DISPLAY").is_ok() || std::env::var("DISPLAY").is_ok();

    if has_wayland {
        if let Ok(mut child) = Command::new("fuzzel")
            .arg("--dmenu")
            .arg("--prompt")
            .arg(prompt)
            .args(placeholder.map(|p| vec!["--placeholder", p]).unwrap_or_default())
            .stdin(Stdio::piped())
            .stdout(Stdio::piped())
            .stderr(Stdio::null())
            .spawn()
        {
            if let Some(mut stdin) = child.stdin.take() {
                let input_data = items.join("\n");
                let _ = stdin.write_all(input_data.as_bytes());
            }

            let output = child.wait_with_output()?;
            if output.status.success() {
                let choice = String::from_utf8_lossy(&output.stdout).trim().to_string();
                if !choice.is_empty() {
                    return Ok(Some(choice));
                }
            }
            return Ok(None);
        }
    }

    // CLI fallback
    println!("\n=== {} ===", prompt.trim());
    for (i, item) in items.iter().enumerate() {
        println!("  [{}] {}", i + 1, item);
    }
    print!("Select option (1-{}, or 'q' to quit): ", items.len());
    let _ = std::io::stdout().flush();

    let mut line = String::new();
    std::io::stdin().read_line(&mut line)?;
    let trimmed = line.trim();
    if trimmed.eq_ignore_ascii_case("q") || trimmed.is_empty() {
        return Ok(None);
    }

    if let Ok(num) = trimmed.parse::<usize>() {
        if num >= 1 && num <= items.len() {
            return Ok(Some(items[num - 1].clone()));
        }
    }

    // Fallback direct match
    for item in items {
        if item.to_lowercase().contains(&trimmed.to_lowercase()) {
            return Ok(Some(item.clone()));
        }
    }

    Ok(None)
}
