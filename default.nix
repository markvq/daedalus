let
  localLib = import ./lib.nix;
in
{ system ? builtins.currentSystem
, config ? {}
, pkgs ? localLib.iohkNix.getPkgs { inherit system config; }
, version ? (builtins.fromJSON (builtins.readFile (./. + "/package.json"))).version
, buildNum ? null
, cluster ? "mainnet"
}:

let
  installPath = ".daedalus";
  src = localLib.cleanSourceTree ./.;
  cardanoSL = localLib.cardanoSL { inherit system config; };

  networks = localLib.splitString " " (builtins.replaceStrings ["\n"] [""] (builtins.readFile ./installer-clusters.cfg));
  forNetworks = localLib.genAttrs networks;

  packages = self: ({
    inherit pkgs;
    inherit (cardanoSL) daedalus-bridge;
    version = version + localLib.versionSuffix buildNum;

    # TODO, use this cross-compiled fastlist when we no longer build windows installers on windows
    fastlist = pkgs.pkgsCross.mingwW64.callPackage ./fastlist.nix {};
    # Dev tool required for the nix shell
    yaml2json = pkgs.haskell.lib.disableCabalFlag pkgs.haskellPackages.yaml "no-exe";

    tests = {
      runFlow = self.callPackage ./tests/flow.nix { inherit src; };
      runLint = self.callPackage ./tests/lint.nix { inherit src; };
      runShellcheck = self.callPackage ./tests/shellcheck.nix { inherit src; };
    };

    # Just the frontend javascript, built with npm and webpack.
    frontend = self.callPackage ./installers/yarn2nix.nix {
      inherit version buildNum;
      src = localLib.npmSourceTree ./.;
      # Backend/API is always Cardano SL at the moment
      backend = {
        api = "ada";
        version = self.daedalus-bridge.version;
      };
    };

    # Daedalus app for nix.
    daedalus = self.callPackage ./installers/daedalus.nix {
      daedalus-configs = forNetworks (network: self.${network}.daedalus-config);
    };

    # Haskell scripts to assist with generating installer files and configs
    daedalus-installer = self.callPackage ./installers {
      forceDontCheck = false;
      enableProfiling = false;
      enableSplitCheck = false;
      enableDebugging = false;
      enableBenchmarks = false;
      enablePhaseMetrics = true;
      enableHaddockHydra = false;
      fasterBuild = false;
    };
    dhall = "${self.daedalus-installer.src}/dhall";

    # Function to create an AppImage with AppImageKit runtime
    makeAppImage = self.callPackage ./installers/make-appimage.nix {};

    # Pre-built releases of electron adapted from nixpkgs
    electron4 = pkgs.callPackage ./installers/nix/electron.nix {};
    electron3 = pkgs.callPackage ./installers/nix/electron3.nix {};

  } // forNetworks (network: let
    # These are packages specialised to a network
    packages = self: super: {
      inherit network;

      # Cardano node and launcher config, generated from dhall sources.
      daedalus-config = self.callPackage ./installers/daedalus-config.nix {};

      # Daedalus app for Linux, with a desktop launcher and icon.
      daedalus-desktop = self.callPackage ./installers/desktop.nix {};
      desktopItem = self.callPackage ./installers/desktop-item.nix {};

      # Self-contained AppImages of Daedalus suitable for other distros.
      appImage' = self.callPackage ./installers/appimage.nix {
        daedalus = self.daedalus-desktop;
      };
      appImage = localLib.wrapPackage buildNum self.appImage';

      # nix-bundle based installer for linux
      linuxInstaller' = import ./installers/linux-installer.nix {
        inherit self pkgs;
      };
      linuxInstaller = localLib.wrapPackage buildNum self.linuxInstaller';
    };
  in self.overrideScope' packages));

in pkgs.lib.makeScope pkgs.newScope packages
