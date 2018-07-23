{ stdenv, runCommand, writeText, writeScriptBin, fetchurl, fetchFromGitHub, electron3,
coreutils, utillinux, procps, network,
frontend, daedalus-bridge, daedalus-installer, daedalus-config,
sandboxed ? false
}:

let
  # closure size TODO list
  # electron depends on cups, which depends on avahi
  daedalus-frontend = writeScriptBin "daedalus-frontend" ''
    #!${stdenv.shell}

    test -z "$XDG_DATA_HOME" && { XDG_DATA_HOME="''${HOME}/.local/share"; }
    export DAEDALUS_DIR="''${XDG_DATA_HOME}/Daedalus"

    cd "''${DAEDALUS_DIR}/${network}/"

    exec ${electron3}/bin/electron ${frontend'}/share/daedalus "$@"
  '';
  frontend' = runCommand "daedalus-frontend-${network}" {} ''
    cp --no-preserve=mode -R ${frontend} $out
    cp ${newPackagePath} $out/share/daedalus/package.json
  '';
  origPackage = builtins.fromJSON (builtins.readFile ../../package.json);
  nameTable = {
    mainnet = "Daedalus";
    staging = "Daedalus Staging";
    testnet = "Daedalus Testnet";
  };
  newPackage = origPackage // {
    productName = nameTable.${if network == null then "testnet" else network};
    main = "main/index.js";
  };
  newPackagePath = builtins.toFile "package.json" (builtins.toJSON newPackage);

  daedalus = writeScriptBin "daedalus" ''
    #!${stdenv.shell}

    set -xe

    ${if sandboxed then ''
    '' else ''
      export PATH="${daedalus-frontend}/bin/:${daedalus-bridge}/bin:$PATH"
    ''}

    test -z "$XDG_DATA_HOME" && { XDG_DATA_HOME="''${HOME}/.local/share"; }
    export           CLUSTER=${network}
    export           NETWORK=${network}
    export      DAEDALUS_DIR="''${XDG_DATA_HOME}/Daedalus"
    export   DAEDALUS_CONFIG=${if sandboxed then "/nix/var/nix/profiles/profile-${network}/etc" else daedalus-config}
    export        REPORT_URL="$(awk '/reportServer:/ { print $2; }' $DAEDALUS_CONFIG/launcher-config.yaml)"

    mkdir -p "''${DAEDALUS_DIR}/${network}/"{Logs/pub,Secrets}
    cd "''${DAEDALUS_DIR}/${network}/"

    exec ${daedalus-bridge}/bin/cardano-launcher \
      --config ${if sandboxed then "/nix/var/nix/profiles/profile-${network}/etc/launcher-config.yaml" else "${daedalus-config}/launcher-config.yaml"}
  '';
  wrappedConfig = runCommand "launcher-config" {} ''
    mkdir -pv $out/etc/
    cp ${daedalus-config}/* $out/etc/
  '';
in daedalus // {
  cfg = wrappedConfig;
  inherit daedalus-frontend;
}
