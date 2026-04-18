{ pkgs, ... }:
{
  users.users.nicolas.packages = with pkgs; [
    neovim
    fish
    eza
    bat
    tree
    ripgrep
    jujutsu
    git
    uv
    gnupg
    wget
    aria2
    pv
    jq
    fzf
    btop
    claude-code
    direnv
    nix-direnv
    nixd
    nixfmt
    ocamlPackages.janeStreet.patdiff
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "backup";
  home-manager.users.nicolas =
    { config, ... }:
    let
      mkOutOfStoreSymlink = config.lib.file.mkOutOfStoreSymlink;
      dotfiles = config.home.homeDirectory + "/dots";
    in
    {
      home.stateVersion = "25.05";

      xdg.configFile = {
        "ghostty".source = mkOutOfStoreSymlink "${dotfiles}/dots/ghostty";
        "fish".source = mkOutOfStoreSymlink "${dotfiles}/fish";
        "nvim".source = mkOutOfStoreSymlink "${dotfiles}/nvim";
        "jj".source = mkOutOfStoreSymlink "${dotfiles}/jj";
        "direnv".source = mkOutOfStoreSymlink "${dotfiles}/direnv";
      };

      home.file.".gitconfig".source = mkOutOfStoreSymlink "${dotfiles}/.gitconfig";
    };
}
