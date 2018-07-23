{ runCommand, daedalus, desktopItem, network }:

let
  localLib = import ../lib.nix;
  icon = (import ./icons/icons.nix).${network};
  iconName = localLib.daedalusProgName network;
in
  daedalus.overrideAttrs (oldAttrs: {
    passthru = { inherit network; };
    buildCommand = ''
      ${oldAttrs.buildCommand}
      mkdir -p $out/share/icons/hicolor/{64x64,1024x1024}/apps
      ln -s ${desktopItem}/share/applications $out/share
      ln -s ${icon.small} $out/share/icons/hicolor/64x64/apps/${iconName}.png
      ln -s ${icon.large} $out/share/icons/hicolor/1024x1024/apps/${iconName}.png
    '';
  })
