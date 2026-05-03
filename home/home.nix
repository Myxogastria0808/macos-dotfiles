{
  inputs,
  system,
  username,
  ...
}:

{
  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";
    stateVersion = "25.11"; # Please read the comment before changing.
  };
  home.packages = [
    # nixvim
    inputs.nixvim-config.packages.${system}.default
  ];
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}

