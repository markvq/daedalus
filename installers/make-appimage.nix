{ lib, stdenv, runCommand, fetchurl, squashfsTools }:

let
  AppImageKit = {
    AppRun = fetchurl {
      url = "https://github.com/AppImage/AppImageKit/releases/download/11/AppRun-x86_64";
      sha256 = "0ci315x1njw6hldi9b8i8bv5q6pvhyfhs9ahb280bq93pdb4zx78";
    };
    runtime = fetchurl {
      url = "https://github.com/AppImage/AppImageKit/releases/download/11/runtime-x86_64";
      sha256 = "1n4bgvx6zs8lzdl517qdch1grnwl4xzyn0a5qwfknbhz53vz0bni";
    };
  };

in

  { name
  , buildCommand
  , ...
  } @ attrs:

  let
    unpacked = stdenv.mkDerivation ({
      name = "${name}.AppDir";
      buildCommand = ''
        ${buildCommand}
        mkdir -p $out
        cp ${AppImageKit.AppRun} $out/AppRun
        chmod +x $out/AppRun
        chmod -R +w $out
      '';
    } // removeAttrs attrs ["name" "buildCommand"]);

    appImage = stdenv.mkDerivation ({
      name = "${name}.AppImage";
      passthru = { inherit unpacked; } // attrs.passthru or {};
      buildCommand = ''
        ${squashfsTools}/bin/mksquashfs ${unpacked} ${name}.squashfs -root-owned -noappend
        cat ${AppImageKit.runtime} >> $out
        cat ${name}.squashfs >> $out
        chmod a+x $out
      '';
    } // removeAttrs attrs ["name" "passthru" "buildCommand"]);

  in
    appImage
