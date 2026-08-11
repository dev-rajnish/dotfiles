{
  username,
  pkgs,
  ...
}: {
  users.users.${username} = {
    isNormalUser = true;

    shell = pkgs.fish;
    ignoreShellProgramCheck = true;

    description = username;

    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "render"
      "input"
      "podman"
      "seat"
      "adbusers"
      "kvm"
      "libvirtd"
      "audio"
    ];
  };
}
