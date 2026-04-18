{
  nixpkgs.hostPlatform = "x86_64-linux";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.supportedLocales = [
    "en_US.UTF-8/UTF-8"
  ];

  system.stateVersion = "25.05";
}
