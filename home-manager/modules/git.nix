{
  ghUsername,
  ghEmail,
  ...
}: {
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = ghUsername;
        email = ghEmail;
      };
      credential = {
        helper = "store";
      };
    };
  };
}
