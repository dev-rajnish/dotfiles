# =============================================================================
#  Kanata Advanced Keyboard Remapper Daemon & Service
# =============================================================================
{
  pkgs,
  username,
  keyboardPath ? null,
  ...
}: let
  byPath = "/dev/input/by-path";
  autoKeyboardPath =
    if builtins.pathExists byPath
    then let
      files = builtins.attrNames (builtins.readDir byPath);
      kbdFiles = builtins.filter (f: builtins.match ".*-event-kbd" f != null || builtins.match ".*kbd.*" f != null) files;
    in
      if kbdFiles != []
      then "${byPath}/${builtins.head kbdFiles}"
      else "/dev/input/by-path/platform-i8042-serio-0-event-kbd"
    else "/dev/input/by-path/platform-i8042-serio-0-event-kbd";

  kbdDevice =
    if keyboardPath != null && keyboardPath != ""
    then keyboardPath
    else autoKeyboardPath;
in {
  environment.systemPackages = [pkgs.kanata];

  hardware.uinput.enable = true;
  services.udev.extraRules = ''KERNEL=="uinput", OWNER="${username}", MODE="0600"'';
  users.users.${username}.extraGroups = ["input" "uinput"];

  services.kanata = {
    enable = true;
    package = pkgs.kanata;

    keyboards."my-laptop" = {
      devices = [kbdDevice];
      extraArgs = ["--nodelay"];
      extraDefCfg = ''
        process-unmapped-keys yes
        concurrent-tap-hold yes
      '';
      config = ''
        (defsrc)

        ;; ╭─────────────────────────────────────────────────────────╮
        ;; │ Aliases / Named Actions                                 │
        ;; ╰─────────────────────────────────────────────────────────╯
        (defalias
          ;; Tap: Space | Hold: Arrow/Symbol layer (0ms repress delay, 80ms timeout)
          spc-nav   (tap-hold-press 0 80 spc (layer-toggle arrow-key))

          ;; Tap: Left Alt | Hold: Number layer (0ms repress delay, 80ms timeout)
          alt-num   (tap-hold-press 0 80 lalt (layer-toggle number))

          ;; Tap: Escape | Hold: Left Control (0ms repress delay, 200ms timeout)
          esc-ctrl  (tap-hold-press 0 100 esc lctl)

          ;; Layer Switchers
          to-qwerty (layer-switch qwerty)
          to-main   (layer-switch main)
        )

        ;; ╭─────────────────────────────────────────────────────────╮
        ;; │ Main Layer (Custom Layout)                              │
        ;; ╰─────────────────────────────────────────────────────────╯
        (deflayermap (main)
          ;; Special & Control Keys
          esc   tab
          del   @to-qwerty
          caps  @esc-ctrl
          bspc  caps
          =     ]

          ;; Top Row
          tab   bspc
          q p   w o   e u   r b   t z   y \   u '   i h   o d   p -   [ /   ] =

          ;; Home Row
          s e   d i   f n   g x   h k   j l   k r   l s   ; t   ' f

          ;; Bottom Row
          z g   x j   c m   b q   n y   m c   / w

          ;; Bottom Modifiers / Thumb Keys
          lctl  lalt
          lalt  @spc-nav
          ralt  @alt-num
        )

        ;; ╭─────────────────────────────────────────────────────────╮
        ;; │ Qwerty Layer (Base Fallback)                            │
        ;; ╰─────────────────────────────────────────────────────────╯
        (deflayermap (qwerty)
          del   @to-main
          lctl  lalt
          lalt  @spc-nav
          ralt  @alt-num
        )

        ;; ╭─────────────────────────────────────────────────────────╮
        ;; │ Arrow Key & Symbols Layer (Held via @spc-nav / Space)   │
        ;; ╰─────────────────────────────────────────────────────────╯
        (deflayermap (arrow-key)
          ;; Row 1: * $ % & ? \ # up " _ ^
          q S-8   w S-4   e S-5   r S-7   t S-/   y \   u S-3   i up   o S-'   p S--   [ S-6

          ;; Row 2: ( { [ / + = left down right right :
          a S-9   s S-[   d [     f /     g S-=   h =   j left  k down l rght  ; rght  ' S-;

          ;; Row 3: ) } ] @ | ! ~ < > ;
          z S-0   x S-]   c ]     v S-2   b S-\   n S-1 m S-grv , S-,  . S-.   / ;
        )

        ;; ╭─────────────────────────────────────────────────────────╮
        ;; │ Number Layer (Held via @alt-num / Alt)                  │
        ;; ╰─────────────────────────────────────────────────────────╯
        (deflayermap (number)
          i 7   o 8   [ .
          j 1   k 2   l 3   ; 4   ' 5
          n 0   m 6   / 9
        )
      '';
    };
  };
}
