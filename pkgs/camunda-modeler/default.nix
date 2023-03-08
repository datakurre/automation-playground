{ pkgs, stdenv, libXScrnSaver, makeWrapper, fetchurl, wrapGAppsHook, glib, gtk3, unzip, atomEnv, libuuid, at-spi2-atk, at-spi2-core, nodePackages, autoPatchelfHook, gcc-unwrapped, libdrm, mesa, libxkbcommon, libxshmfence, lib, libappindicator-gtk3, libglvnd }:

let

  modelerVersion = "5.8.0";

  mkElectron = import "${pkgs.path}/pkgs/development/tools/electron/generic.nix" { inherit stdenv libXScrnSaver makeWrapper fetchurl wrapGAppsHook glib gtk3 unzip atomEnv libuuid at-spi2-atk at-spi2-core libdrm mesa libxkbcommon libxshmfence lib libappindicator-gtk3 libglvnd; };
  electron = mkElectron "20.2.0" {
    x86_64-linux = "sha256-wONSLeNIGbg49KNd3zDGKDxhvhu43/Agic2j9kGTiq0=";
  };

  bpmn-js-token-simulation-plugin = fetchurl {
    url = "https://github.com/bpmn-io/bpmn-js-token-simulation-plugin/archive/85aa974ae5877dfa4bca585c258132a429566dca.tar.gz";
    sha256 = "sha256-/g9YuE48XbVy/zdFTWgV568Z7Yxp9hNKh9BsI16meyc=";
  };

  camunda-modeler-robot-plugin = fetchurl {
    url = "https://github.com/datakurre/camunda-modeler-robot-plugin/archive/4c5805fbbde8e28c9c123cdeb4069d66054be402.tar.gz";
    sha256 = "sha256-dnvzBgJtiIqJUYCZc0QuXG1HIcl7AdudprTgRonrjEM=
";
  };

  asar = stdenv.mkDerivation rec {
    name = "camunda-modeler-${version}-asar";
    version = modelerVersion;
    src = fetchurl {
      url = "https://github.com/camunda/camunda-modeler/releases/download/v${version}/camunda-modeler-${version}-linux-x64.tar.gz";
      sha256 = "sha256-v1K3CIE+gYnhn2af5Rzx8R3/M/42xTIjHXQ69pgnsZI=";
    };
    nativeBuildInputs = [ nodePackages.asar autoPatchelfHook gcc-unwrapped ];
    installPhase = ''
      asar extract ./resources/app.asar $out
    '';
  };

in

stdenv.mkDerivation rec {
  name = "camunda-modeler-${version}";
  version = modelerVersion;
  src = asar;
  unpackPhase = "";
  nativeBuildInputs = [ electron makeWrapper nodePackages.asar autoPatchelfHook gcc-unwrapped ];
  installPhase = ''
    mkdir -p $out/var/lib/camunda/resources/plugins $out/bin

    cp -a $src build
    chmod u+w -R build
    substituteInPlace build/lib/index.js \
      --replace "let resourcesPaths = [" \
                "let resourcesPaths = [\"$out/var/lib/camunda/resources\","
    asar pack build $out/var/lib/camunda/app.asar

    cd $out/var/lib/camunda/resources/plugins

    tar xzvf ${bpmn-js-token-simulation-plugin}
    tar xzvf ${camunda-modeler-robot-plugin}

    makeWrapper ${electron}/bin/electron $out/bin/camunda-modeler \
      --add-flags "$out/var/lib/camunda/app.asar"
  '';
}
