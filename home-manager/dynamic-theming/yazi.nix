# =============================================================================
#  Dynamic Theming: Yazi Terminal File Manager Base16 Theme & Icons
# =============================================================================
{
  pkgs,
  tokens,
}: let
  inherit (tokens) colors;

  yaziTheme = pkgs.writeText "theme.toml" ''
    # Auto-generated Base16 Yazi Theme - Do not edit manually

    # : Manager
    [mgr]
    cwd = { fg = "${colors.cyan}", italic = true }

    # Hovered
    hovered = { bg = "${colors.bgCard}", fg = "${colors.fg}" }
    preview_hovered = { bg = "${colors.bgCard}" }

    # Find
    find_keyword = { fg = "${colors.bgDark}", bg = "${colors.yellow}", bold = true }
    find_position = { fg = "${colors.orange}", bg = "${colors.bgCard}", bold = true }

    # Marker
    marker_copied = { fg = "${colors.green}", bg = "${colors.green}" }
    marker_cut = { fg = "${colors.red}", bg = "${colors.red}" }
    marker_marked = { fg = "${colors.magenta}", bg = "${colors.magenta}" }
    marker_selected = { fg = "${colors.orange}", bg = "${colors.orange}" }

    # Count
    count_copied = { fg = "${colors.bgDark}", bg = "${colors.green}" }
    count_cut = { fg = "${colors.bgDark}", bg = "${colors.red}" }
    count_selected = { fg = "${colors.bgDark}", bg = "${colors.orange}" }

    # Border
    border_symbol = "│"
    border_style = { fg = "${colors.border}" }

    # Tabs
    [tabs]
    active = { fg = "${colors.bgDark}", bg = "${colors.orange}", bold = true }
    inactive = { fg = "${colors.fgMuted}", bg = "${colors.bgCard}" }

    # : Mode
    [mode]
    normal_main = { fg = "${colors.bgDark}", bg = "${colors.orange}", bold = true }
    normal_alt = { fg = "${colors.orange}", bg = "${colors.bgCard}" }

    select_main = { fg = "${colors.bgDark}", bg = "${colors.magenta}", bold = true }
    select_alt = { fg = "${colors.magenta}", bg = "${colors.bgCard}" }

    unset_main = { fg = "${colors.bgDark}", bg = "${colors.yellow}", bold = true }
    unset_alt = { fg = "${colors.yellow}", bg = "${colors.bgCard}" }

    # : Status bar
    [status]
    overall = { fg = "${colors.fg}", bg = "${colors.bgDark}" }
    separator_open = ""
    separator_close = ""

    # Progress
    progress_label = { fg = "${colors.fg}", bold = true }
    progress_normal = { fg = "${colors.bgDark}", bg = "${colors.bgCard}" }
    progress_error = { fg = "${colors.red}", bg = "${colors.bgCard}" }

    # Permissions
    perm_type = { fg = "${colors.cyan}" }
    perm_read = { fg = "${colors.yellow}" }
    perm_write = { fg = "${colors.red}" }
    perm_exec = { fg = "${colors.green}" }
    perm_sep = { fg = "${colors.comment}" }

    # : Pick
    [pick]
    border = { fg = "${colors.borderFocus}" }
    active = { fg = "${colors.fg}", bg = "${colors.bgCard}" }
    inactive = { fg = "${colors.fgMuted}" }

    # : Input
    [input]
    border = { fg = "${colors.borderFocus}" }
    title = { fg = "${colors.orange}" }
    value = { fg = "${colors.fg}" }
    selected = { bg = "${colors.bgCard}" }

    # : Completion
    [cmp]
    border = { fg = "${colors.borderFocus}" }
    active = { fg = "${colors.fg}", bg = "${colors.bgCard}" }
    inactive = { fg = "${colors.fgMuted}" }

    icon_file = ""
    icon_folder = ""
    icon_command = ""

    # : Tasks
    [tasks]
    border = { fg = "${colors.borderFocus}" }
    title = { fg = "${colors.orange}" }
    hovered = { fg = "${colors.fg}", bg = "${colors.bgCard}" }

    # : Which
    [which]
    cols = 3
    mask = { bg = "${colors.bgDark}" }
    cand = { fg = "${colors.cyan}" }
    rest = { fg = "${colors.orange}" }
    desc = { fg = "${colors.magenta}" }
    separator = " ➜ "
    separator_style = { fg = "${colors.comment}" }

    # : Confirm
    [confirm]
    border = { fg = "${colors.borderFocus}" }
    title = { fg = "${colors.orange}" }
    content = {}
    list = {}
    btn_yes = { fg = "${colors.bgDark}", bg = "${colors.green}" }
    btn_no = { fg = "${colors.fg}", bg = "${colors.bgCard}" }
    btn_labels = ["  [Y]es  ", "  (N)o  "]

    # : Spot
    [spot]
    border = { fg = "${colors.borderFocus}" }
    title = { fg = "${colors.orange}" }

    # : Notify
    [notify]
    title_info = { fg = "${colors.cyan}" }
    title_warn = { fg = "${colors.yellow}" }
    title_error = { fg = "${colors.red}" }

    icon_error = ""
    icon_warn = ""
    icon_info = ""

    # : Help
    [help]
    on = { fg = "${colors.green}" }
    run = { fg = "${colors.magenta}" }
    desc = { fg = "${colors.cyan}" }
    hovered = { bg = "${colors.bgCard}" }
    footer = { fg = "${colors.fg}", bg = "${colors.bgDark}" }

    # : Icon Theming (Overrides Yazi default electric blue icons with Base16 palette)
    [icon]
    prepend_dirs = [
      { name = "Desktop", text = "", fg = "${colors.yellow}" },
      { name = "Documents", text = "󰈙", fg = "${colors.yellow}" },
      { name = "Downloads", text = "", fg = "${colors.yellow}" },
      { name = "Music", text = "", fg = "${colors.magenta}" },
      { name = "Pictures", text = "", fg = "${colors.yellow}" },
      { name = "Public", text = "", fg = "${colors.orange}" },
      { name = "Templates", text = "", fg = "${colors.yellow}" },
      { name = "Videos", text = "", fg = "${colors.magenta}" },
      { name = ".git", text = "", fg = "${colors.orange}" },
      { name = ".config", text = "", fg = "${colors.yellow}" },
      { name = "*", text = "", fg = "${colors.yellow}" },
    ]

    prepend_exts = [
      { name = "nix", text = "", fg = "${colors.cyan}" },
      { name = "rs", text = "", fg = "${colors.orange}" },
      { name = "py", text = "", fg = "${colors.yellow}" },
      { name = "js", text = "", fg = "${colors.yellow}" },
      { name = "ts", text = "", fg = "${colors.blue}" },
      { name = "tsx", text = "", fg = "${colors.blue}" },
      { name = "jsx", text = "", fg = "${colors.yellow}" },
      { name = "go", text = "", fg = "${colors.cyan}" },
      { name = "lua", text = "", fg = "${colors.blue}" },
      { name = "sh", text = "", fg = "${colors.green}" },
      { name = "bash", text = "", fg = "${colors.green}" },
      { name = "fish", text = "", fg = "${colors.green}" },
      { name = "toml", text = "", fg = "${colors.yellow}" },
      { name = "yaml", text = "", fg = "${colors.yellow}" },
      { name = "yml", text = "", fg = "${colors.yellow}" },
      { name = "json", text = "", fg = "${colors.yellow}" },
      { name = "kdl", text = "󰅪", fg = "${colors.yellow}" },
      { name = "md", text = "", fg = "${colors.fg}" },
      { name = "mp4", text = "", fg = "${colors.magenta}" },
      { name = "mkv", text = "", fg = "${colors.magenta}" },
      { name = "mp3", text = "", fg = "${colors.magenta}" },
      { name = "flac", text = "", fg = "${colors.magenta}" },
      { name = "png", text = "", fg = "${colors.yellow}" },
      { name = "jpg", text = "", fg = "${colors.yellow}" },
      { name = "jpeg", text = "", fg = "${colors.yellow}" },
      { name = "zip", text = "", fg = "${colors.red}" },
      { name = "tar", text = "", fg = "${colors.red}" },
      { name = "gz", text = "", fg = "${colors.red}" },
      { name = "pdf", text = "", fg = "${colors.cyan}" },
    ]

    # : Filetype & Icon Colors
    [filetype]
    rules = [
      # Directories
      { url = "*/", fg = "${colors.fg}" },

      # Executables & Scripts
      { url = "*", is = "exec", fg = "${colors.green}" },
      { url = "*.sh", fg = "${colors.green}" },
      { url = "*.bash", fg = "${colors.green}" },
      { url = "*.fish", fg = "${colors.green}" },

      # Configuration & Nix
      { url = "*.nix", fg = "${colors.cyan}" },
      { url = "*.kdl", fg = "${colors.yellow}" },
      { url = "*.toml", fg = "${colors.yellow}" },
      { url = "*.yaml", fg = "${colors.yellow}" },
      { url = "*.yml", fg = "${colors.yellow}" },
      { url = "*.json", fg = "${colors.yellow}" },
      { url = "*.ini", fg = "${colors.yellow}" },
      { url = "*.conf", fg = "${colors.yellow}" },

      # Programming Languages
      { url = "*.rs", fg = "${colors.orange}" },
      { url = "*.py", fg = "${colors.yellow}" },
      { url = "*.js", fg = "${colors.yellow}" },
      { url = "*.ts", fg = "${colors.blue}" },
      { url = "*.tsx", fg = "${colors.blue}" },
      { url = "*.jsx", fg = "${colors.yellow}" },
      { url = "*.go", fg = "${colors.cyan}" },
      { url = "*.lua", fg = "${colors.blue}" },
      { url = "*.c", fg = "${colors.blue}" },
      { url = "*.cpp", fg = "${colors.blue}" },
      { url = "*.h", fg = "${colors.blue}" },
      { url = "*.hpp", fg = "${colors.blue}" },

      # Web & Markup
      { url = "*.html", fg = "${colors.orange}" },
      { url = "*.css", fg = "${colors.blue}" },
      { url = "*.scss", fg = "${colors.magenta}" },
      { url = "*.md", fg = "${colors.fg}" },
      { url = "*.org", fg = "${colors.fg}" },

      # Media
      { mime = "image/*", fg = "${colors.yellow}" },
      { mime = "{audio,video}/*", fg = "${colors.magenta}" },

      # Archives
      { mime = "application/*zip", fg = "${colors.red}" },
      { mime = "application/x-{tar,bzip*,7z-compressed,xz,rar,gzip}", fg = "${colors.red}" },

      # Documents
      { mime = "application/{pdf,doc,rtf,vnd.*}", fg = "${colors.cyan}" },

      # Special Files
      { url = "*", is = "orphan", fg = "${colors.red}" },
      { url = "*", is = "link", fg = "${colors.cyan}" },
      { url = "Dockerfile", fg = "${colors.cyan}" },
      { url = "justfile", fg = "${colors.red}" },
      { url = "Makefile", fg = "${colors.red}" },
      { url = "flake.lock", fg = "${colors.comment}" },
    ]
  '';
in {
  inherit yaziTheme;
}
