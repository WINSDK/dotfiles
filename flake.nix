# mac build: sudo darwin-rebuild switch --flake .#macbook
# Folder must be placed in $HOME/Repos/dotfiles.

{
  description = "Nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    configuration = { pkgs, config, ... }:
    let
      home = config.system.primaryUserHome;
    in {
      environment.systemPackages = with pkgs;
        [ neovim
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
          postgresql
          clang-tools
          clang
          cmake
          ocaml
          opam
          dune_3
          rustup
          ocamlPackages.janeStreet.patdiff
        ];

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;
      system.primaryUser = "nicolas";

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      # Enable non-free packages to be installed.
      nixpkgs.config.allowUnfree = true;

      # Use fish shell.
      programs.fish.enable = true;

      # Symlink dotfile configs
      system.activationScripts.postActivation.text = let
        dotfiles = "${home}/Repos/dotfiles";
      in ''
        sudo -u nicolas ln -sfn ${dotfiles}/fish    ${home}/.config/fish
        sudo -u nicolas ln -sfn ${dotfiles}/nvim    ${home}/.config/nvim
        sudo -u nicolas ln -sfn ${dotfiles}/ghostty ${home}/.config/ghostty
        sudo -u nicolas ln -sfn ${dotfiles}/jj      ${home}/.config/jj
        sudo -u nicolas ln -sfn ${dotfiles}/.gitconfig ${home}/.gitconfig
      '';

      system.defaults = {
        NSGlobalDomain = {
          AppleInterfaceStyle = "Dark";
          NSAutomaticCapitalizationEnabled = false;
          NSAutomaticDashSubstitutionEnabled = false;
          NSAutomaticInlinePredictionEnabled = false;
          NSAutomaticPeriodSubstitutionEnabled = false;
          NSAutomaticQuoteSubstitutionEnabled = false;
          NSAutomaticSpellingCorrectionEnabled = false;
        };

        dock = {
          autohide = true;
          tilesize = 56;
          launchanim = true;
          show-recents = false;
          show-process-indicators = true;
          mineffect = "genie";
        };

        finder = {
          ShowPathbar = true;
          FXPreferredViewStyle = "Nlsv";
        };

        WindowManager = {
          GloballyEnabled = false;
          EnableStandardClickToShowDesktop = false;
          EnableTiledWindowMargins = false;
          HideDesktop = true;
          StandardHideWidgets = true;
        };

        universalaccess = {
          reduceMotion = true;
          reduceTransparency = true;
        };

        CustomSystemPreferences = {
          NSGlobalDomain = {
            AppleAccentColor = 6;
            AppleHighlightColor = "1.000000 0.749020 0.823529 Pink";
          };
          "com.apple.Accessibility" = {
            EnhancedBackgroundContrastEnabled = 1;
          };
        };
      };
    };
  in
  {
    darwinConfigurations."macbook" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
    };
  };
}
