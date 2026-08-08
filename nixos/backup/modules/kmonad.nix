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
  environment.systemPackages = [pkgs.kmonad];

  hardware.uinput.enable = true;
  services.udev.extraRules = ''KERNEL=="uinput", OWNER="${username}", MODE="0600"'';
  users.users.${username}.extraGroups = ["input"];

  services.kmonad = {
    enable = true;
    package = pkgs.kmonad;

    keyboards."my-laptop" = {
      device = kbdDevice;
      config =
        /*
        py
        */
        ''
          ( defcfg
          input  ( device-file "${kbdDevice}" )
          output ( uinput-sink "kmonad-output" )
          fallthrough false
          )
          ;; ╭─────────────────────────────────────────────────────────╮
          ;; │ SOURCE                                                  │
          ;; ╰─────────────────────────────────────────────────────────╯
          ( defsrc

          esc   f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11    f12   ins     print    del
          grv   1    2    3    4    5    6    7    8    9    0    -      =     bspc
          tab   q    w    e    r    t    y    u    i    o    p    [      ]     \
          caps  a    s    d    f    g    h    j    k    l    ;    '      ret
          lsft  z    x    c    v    b    n    m    ,    .    /    rsft   up
          lctl  fn  lmet lalt            spc            ralt rctl left   down  rght

          )
           ;;╭───────────────────────────────────────────────────────────╮
           ;;│ ;;# Main Layer                                            │
           ;;╰───────────────────────────────────────────────────────────╯

          ( deflayer main ;; main

          tab    f1    f2   f3   f4   f5   f6   f7   f8   f9    f10   f11     f12    ins    print  XX

          grv     1     2    3    4    5    6    7    8    9     0     -       ]     caps

          bspc    p     o    u    b    z    \    '     h   d    -    /    =     \

          @esct   a     e    i    n    x      k    l    r    s     t     f      ret

          lsft    g   j     m   v     q        y   c     ,    .    w     rsft  up

          @hardl    fn    lmet @at           spc            @altn   _  left    down  rght

          )
          ;; ╭─────────────────────────────────────────────────────────╮
          ;; │ qwerty layout                                           │
          ;; ╰─────────────────────────────────────────────────────────╯
          ( deflayer qwerty

          tab   f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11    f12   _     _    _
          grv   1    2    3    4    5    6    7    8    9    0    -      =     bspc
          _   q    w    e    r    t    y    u    i    o    p    [      ]     \
          _   a    s    d    f    g    h    j    k    l    ;    '      ret
          _    z    x    c    v    b    n    m    ,    .    /    _   _
          @mainl  fn  lmet @at            spc            @altn rctl left   down  rght

          )
          ;; ╭─────────────────────────────────────────────────────────╮
          ;; │ Functions                                               │
          ;; ╰─────────────────────────────────────────────────────────╯

          ( defalias

          at (tap-hold-next 80 spc (layer-toggle arrow-key) )

          altn (tap-hold-next 80 lalt (layer-toggle number) )

          hardl (layer-switch qwerty)

          mainl (layer-switch main)

          esct (tap-hold-next 250 esc lctl)

          rsftcaps (tap-hold-next 280 caps lsft)

          )

          ;; ╭─────────────────────────────────────────────────────────╮
          ;; │ Arrow key                                               │
          ;; ╰─────────────────────────────────────────────────────────╯
          ( deflayer arrow-key

          ;;ec f1   f2   f3   f4   f5   f6    f7       f8     f9      f10    f11  f12 _ _ _

          _    _    _    _    _    _    _     _        _      _       _       _    _    _   _   _
          _    _    _    _    _    _    _     _        _      _       _       _    _    _
          _    *    $    %    &   !     \\     #        up     "      \_       ^    _    _
          _    \(    {    [   /    +     =    left     down   rght    rght     :    _
          _     \)    }    ]   @    !       |        ~        <      >       ;     _   _
          _    _    _    _              spc                           _         _    _    _   _

          )


          ;; ╭─────────────────────────────────────────────────────────╮
          ;; │ Number Layout                                           │
          ;; ╰─────────────────────────────────────────────────────────╯

          ( deflayer number

          ;;ec f1   f2   f3   f4   f5   f6    f7       f8     f9      f10       f11      f12 ins print del
          _    _           _        _     _    _    _     _        _      _       _         _        _    _   _   _

          _    _    _    _    _    _      _       _       _       _       _       _        _    _
          _    _    _    _    _    _      _       _       7       8       _       .        _    _
          _    _    _    _    lsft    _      _       1       2       3       4       5    _
          _    _    _    _    _    _      0       6       _       _    9       _    _
          _    _    _    _              spc                               _    _    _    _    _

          )
        '';
    };
  };
}
