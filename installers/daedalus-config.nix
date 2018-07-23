{ system, runCommand, daedalus-bridge, daedalus-installer, dhall, network }:

let
  systemOS = {
    x86_64-linux = "linux64";
    x86_64-darwin = "macos64";
  };
  os = systemOS.${system};

in runCommand "daedalus-config-${network}" {} ''
  mkdir -pv $out
  cp -v ${daedalus-bridge}/config/* $out
  cd $out
  ${daedalus-installer}/bin/generate-launcher-config --os ${os} --cluster ${network} --input-dir "${dhall}" --output-dir "."
''
