let
  localLib = import ./lib.nix;
in

{ supportedSystems ? ["x86_64-linux" "x86_64-darwin"]
, scrubJobs ? true
, nixpkgsArgs ? {
    config = { allowUnfree = false; inHydra = true; };
    inherit buildNum;
  }
, buildNum ? null
}:

with (import (localLib.iohkNix.nixpkgs + "/pkgs/top-level/release-lib.nix") {
  inherit supportedSystems scrubJobs nixpkgsArgs;
  packageSet = import ./.;
});

{
  inherit (import ./. {}) tests;

  shellEnvs = {
    linux = import ./shell.nix { system = "x86_64-linux"; autoStartBackend = true; };
    darwin = import ./shell.nix { system = "x86_64-darwin"; autoStartBackend = true; };
  };
  yaml2json = let
    daedalusPkgsWithSystem = system: import ./. { inherit system; };
  in {
    x86_64-linux = (daedalusPkgsWithSystem "x86_64-linux").yaml2json;
    x86_64-darwin = (daedalusPkgsWithSystem "x86_64-darwin").yaml2json;
  };

} // mapTestOn {
  daedalus = supportedSystems;

  mainnet.appImage = [ "x86_64-linux" ];
  staging.appImage = [ "x86_64-linux" ];
  testnet.appImage = [ "x86_64-linux" ];

  mainnet.linuxInstaller = [ "x86_64-linux" ];
  staging.linuxInstaller = [ "x86_64-linux" ];
  testnet.linuxInstaller = [ "x86_64-linux" ];
}
