# =============================================================================
#  Nushell Environment Configuration (env.nu)
#  Runs before config.nu on every Nushell startup.
# =============================================================================

# -----------------------------------------------------------------------------
# 1. Base Environment Variables
# -----------------------------------------------------------------------------
$env.STARSHIP_SHELL = "nu"

# Ensure standard XDG directories exist
$env.XDG_CONFIG_HOME = ($env.HOME | path join ".config")
$env.XDG_DATA_HOME = ($env.HOME | path join ".local/share")
$env.XDG_CACHE_HOME = ($env.HOME | path join ".cache")
$env.XDG_STATE_HOME = ($env.HOME | path join ".local/state")

# -----------------------------------------------------------------------------
# 2. Dynamic PATH Construction from user/path.kv
# -----------------------------------------------------------------------------
def get-dotfiles-paths [] {
    let home = $env.HOME
    let path_file = ($home | path join "_ws/dotfiles/user/path.kv")
    let repo_rust_bin = ($home | path join "_ws/dotfiles/user/bin-rs/target/release")
    let local_bin = ($home | path join ".local/bin")

    mut paths = [ $local_bin, $repo_rust_bin ]

    if ($path_file | path exists) {
        let lines = (open $path_file 
            | lines 
            | each { |l| $l | str trim } 
            | where { |l| ($l != "") and (not ($l | str starts-with "#")) })
        for p in $lines {
            let exp = ($p | str replace "~" $home)
            if ($exp | path exists) {
                $paths = ($paths | append $exp)
            }
        }
    }
    $paths
}

# Prepend dynamic paths to PATH and ensure uniqueness
$env.PATH = ($env.PATH | split row (char esep) | prepend (get-dotfiles-paths) | uniq)

# -----------------------------------------------------------------------------
# 3. Dynamic Environment Variables from user/env.kv
# -----------------------------------------------------------------------------
let env_file = ($env.HOME | path join "_ws/dotfiles/user/env.kv")
if ($env_file | path exists) {
    let env_entries = (open $env_file 
        | lines 
        | each { |l| $l | str trim } 
        | where { |l| ($l != "") and (not ($l | str starts-with "#")) and ($l | str contains "=") }
        | each { |l| 
            let parts = ($l | split row "=")
            let k = ($parts | get 0 | str trim)
            let v = ($parts | skip 1 | str join "=" | str trim | str trim -c '"' | str trim -c "'" | str replace "~" $env.HOME)
            { key: $k, value: $v }
        })
    for entry in $env_entries {
        load-env { $entry.key: $entry.value }
    }
}
