{
  username,
  pkgs,
  ...
}: {
  users.users.${username} = {
    isNormalUser = true;

    shell = pkgs.fish;
    ignoreShellProgramCheck = true;

    #passwd
    #initialPassword = "rr";

    description = "${username}";

    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "render"
      "input"
      "podman"
      "seat"
    ];
  };
}
