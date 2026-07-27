{pkgs, ...}: {
  # User-space Command Line Interface (CLI) & Terminal User Interface (TUI) Tools
  home.packages = with pkgs; [
    # Modern Unix Alternatives & Command Line Utilities
    bat # Modern replacement for 'cat' with syntax highlighting & git integration
    choose # Human-friendly alternative to 'cut' and 'awk'
    duf # Disk usage and free space statistics viewer
    dust # Intuitive tree-based alternative to 'du'
    entr # Run arbitrary commands when files change
    eza # Modern, feature-rich replacement for 'ls'
    fd # Fast, user-friendly alternative to 'find'
    ncdu # Terminal disk usage analyzer with ncurses interface
    ripgrep # Ultra-fast line-oriented search tool (replacement for 'grep')
    sd # Intuitive find & replace alternative to 'sed'
    yazi # Blazing fast terminal file manager written in Rust
    zoxide # Smarter 'cd' command that learns your habits

    # Git & Structural Diff Tools
    delta # Syntax-highlighting pager for git diffs
    difftastic # Structural diff tool that compares code syntax trees

    # System & Resource Monitors (User Space)
    btop-rocm # Resource monitor with AMD GPU / ROCm monitoring support
    ftop # File progress & transfer monitor
    htop # Interactive process viewer
    nerdfetch # Minimalist system info fetcher script
    ttop # Top-like system performance monitor

    # Terminal Multiplexer, Shell Enhancements & Productivity
    fossil # Simple, high-reliability distributed SCM system
    glow # Command-line markdown renderer
    httpie # User-friendly HTTP client / cURL alternative
    starship # Minimal, blazing-fast, and customizable shell prompt
    stow # Symlink farm manager for dotfiles
    tldr # Community-driven, simplified man pages
    zellij # Terminal workspace manager and multiplexer

    # Terminal Aesthetics & Fun / Toys
    cbonsai # Terminal bonsai tree generator
    cmatrix # Matrix digital rain terminal screen saver
    fortune # Displays random quotes and sayings
    lolcat # Rainbow colorizer for command-line output
    pipes # Animated terminal pipes screen saver
    toilet # ASCII art banner generator
  ];
}
