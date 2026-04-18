{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    neovim
  ];

  nix.settings.experimental-features = "nix-command flakes";

  nixpkgs.config.allowUnfree = true;

  programs.fish.enable = true;

  time.timeZone = "Europe/Berlin";
}
