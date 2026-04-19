{ pkgs, ... }:
{
  users.users.nicolas = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    shell = pkgs.fish;
    initialPassword = "password123";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJe9xDIDvesRTCJL/KY85cyCDcJYsPeUq1mOG4k82Jat nicolas"
    ];
  };

  home-manager.users.nicolas = {
    home.homeDirectory = "/home/nicolas";
  };
}
