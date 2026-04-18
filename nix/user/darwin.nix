{ ... }:
let
  home = "/Users/nicolas";
in
{
  users.users.nicolas.home = home;

  home-manager.users.nicolas = {
    home.homeDirectory = home;
  };
}
