{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget

      nixpkgs.config.allowUnfree = true;

      environment.systemPackages =
        [
          pkgs.vim
          pkgs.ghostty-bin
          pkgs.git
          pkgs.rustup
        ];

      homebrew = {
        enable = true;
        casks = [
          "steam"
          "obs"
        ];

        onActivation = {
          cleanup = "zap";
          autoUpdate = true;
          upgrade = true;         
        };        
      };

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Program settings
      programs = {
        man.enable = true;
        # Look into configuring vim here
        
      };
      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      # Setting me to the primary user      
      system.primaryUser = "hunter";
      
      # Setting Mac sleep requirements 
      power.sleep = {
        display = 2;
        computer = 5;
      };      

      # Setting Mac defaults
      system.defaults = {
        dock = {
          autohide = true;
          tilesize = 64;
          magnification = true;
          largesize = 96;
          persistent-apps = [
            "/System/Volumes/Preboot/Cryptexes/App/System/Applications/Safari.app/"
            "/System/Applications/Mail.app"
            "${pkgs.ghostty-bin}/Applications/ghostty.app"
          ];
        };
        
        controlcenter = {
          BatteryShowPercentage = true;
        };

        finder = {
          _FXEnableColumnAutoSizing = true;
          _FXShowPosixPathInTitle = true;
          _FXSortFoldersFirst = true;
          AppleShowAllExtensions = true;
          FXPreferredViewStyle = "clmv";
          FXRemoveOldTrashItems = true;
          NewWindowTarget = "Home";
          QuitMenuItem = true;
          ShowPathbar = true;
        };
        
       loginwindow = {
        GuestEnabled = false;
       };

       NSGlobalDomain = {
        "com.apple.swipescrolldirection" = false;
        AppleInterfaceStyle = "Dark";
        NSDocumentSaveNewDocumentsToCloud = false;
       };

       trackpad = {
        TrackpadMomentumScroll = false;
        TrackpadPinch = true;
       };
      };
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#Hunters-MacBook-Pro
    darwinConfigurations."Hunters-MacBook-Pro" = nix-darwin.lib.darwinSystem {
      modules = [ 
        configuration
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            user = "hunter";
          };
        }
      ];
    };

  };
}
