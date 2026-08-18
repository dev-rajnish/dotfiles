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
# 2. Dynamic PATH Construction from path.kv & Local Binaries
# -----------------------------------------------------------------------------
def get-paths-from-user-db [] {
    let home = $env.HOME
    let user = ($env.USER? | default "")
    let user_db = ($home | path join ".config/3-user-env")
    let shell_db = ($home | path join ".config/shell")

    let path_file = if ($user_db | path join "path.kv" | path exists) and ((open ($user_db | path join "path.kv") | lines | is-not-empty)) {
        $user_db | path join "path.kv"
    } else if ($shell_db | path join "path.kv" | path exists) {
        $shell_db | path join "path.kv"
    } else {
        ""
    }

    let local_bin = ($home | path join ".local/bin")
    let my_bin = ($home | path join ".config/1-bin")

    mut paths = [ $local_bin, $my_bin ]

    if ($path_file != "" and ($path_file | path exists)) {
        let lines = (open $path_file 
            | lines 
            | each { |l| $l | str trim } 
            | where { |l| ($l != "") and (not ($l | str starts-with "#")) })
        for p in $lines {
            let exp = ($p | str replace "~" $home | str replace "$USER" $user)
            if ($exp | path exists) {
                $paths = ($paths | append $exp)
            }
        }
    }
    $paths
}

# Prepend dynamic paths to PATH and ensure uniqueness
$env.PATH = ($env.PATH | split row (char esep) | prepend (get-paths-from-user-db) | uniq)

# -----------------------------------------------------------------------------
# 3. Dynamic Environment Variables from env.kv
# -----------------------------------------------------------------------------
let home = $env.HOME
let user_db = ($home | path join ".config/3-user-env")
let shell_db = ($home | path join ".config/shell")

let env_file = if ($user_db | path join "env.kv" | path exists) and ((open ($user_db | path join "env.kv") | lines | is-not-empty)) {
    $user_db | path join "env.kv"
} else if ($shell_db | path join "env.kv" | path exists) {
    $shell_db | path join "env.kv"
} else {
    ""
}

if ($env_file != "" and ($env_file | path exists)) {
    let env_entries = (open $env_file 
        | lines 
        | each { |l| $l | str trim } 
        | where { |l| ($l != "") and (not ($l | str starts-with "#")) and ($l | str contains "=") }
        | each { |l| 
            let parts = ($l | split row "=")
            let k = ($parts | get 0 | str trim)
            let v = ($parts | skip 1 | str join "=" | str trim | str trim -c '"' | str trim -c "'" | str replace "~" $home)
            { key: $k, value: $v }
        })
    for entry in $env_entries {
        load-env { $entry.key: $entry.value }
    }
} 
