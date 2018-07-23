{ stdenv, libXScrnSaver, makeWrapper, fetchurl, unzip, atomEnv, libuuid, at-spi2-atk }@args:
(import ./electron.nix args).overrideAttrs (old: rec {
  name = "electron-${version}";
  version = "3.0.14";
  src = {
    x86_64-linux = fetchurl {
      url = "https://github.com/electron/electron/releases/download/v${version}/electron-v${version}-linux-x64.zip";
      sha256 = "0wha13dbb8553h9c7kvpnrjj5c6wizr441s81ynmkfbfybg697p7";
    };
  }.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
})
