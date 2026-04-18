{
  self,
  pkgs,
  ...
}:
{
  users.users.nicolas.packages = with pkgs; [
    mpv
  ];

  system.configurationRevision = self.rev or self.dirtyRev or null;
  system.stateVersion = 6;
  system.primaryUser = "nicolas";

  nixpkgs.hostPlatform = "aarch64-darwin";

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
}
