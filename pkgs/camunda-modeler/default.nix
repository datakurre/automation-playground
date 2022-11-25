{ pkgs, stdenv, libXScrnSaver, makeWrapper, fetchurl, wrapGAppsHook, glib, gtk3, unzip, atomEnv, libuuid, at-spi2-atk, at-spi2-core, nodePackages, autoPatchelfHook, gcc-unwrapped, libdrm, mesa, libxkbcommon, libxshmfence, lib, libappindicator-gtk3, libglvnd }:

let

  mkElectron = import "${pkgs.path}/pkgs/development/tools/electron/generic.nix" { inherit stdenv libXScrnSaver makeWrapper fetchurl wrapGAppsHook glib gtk3 unzip atomEnv libuuid at-spi2-atk at-spi2-core libdrm mesa libxkbcommon libxshmfence lib libappindicator-gtk3 libglvnd; };
  electron = mkElectron "17.1.0" {
    x86_64-linux = "1s18zrmqiiks9nq27nw2s65wcl0rqhxc6b343wg6qdk9b65c4vhh";
  };

  bpmn-js-token-simulation-plugin = fetchurl {
    url = "https://github.com/bpmn-io/bpmn-js-token-simulation-plugin/archive/b433c1454e0edf415372b58fe897569b75cf2c40.tar.gz";
    sha256 = "sha256-5D1wElJrwZeKoiWhVRv2UCaLTs5jebZCTaKrOr9ZgF4=";
  };

  camunda-modeler-robot-plugin = fetchurl {
    url = "https://github.com/datakurre/camunda-modeler-robot-plugin/archive/4c5805fbbde8e28c9c123cdeb4069d66054be402.tar.gz";
    sha256 = "sha256-dnvzBgJtiIqJUYCZc0QuXG1HIcl7AdudprTgRonrjEM=
";
  };

  asar = stdenv.mkDerivation rec {
    name = "camunda-modeler-${version}-asar";
    version = "5.5.1";
    src = fetchurl {
      url = "https://github.com/camunda/camunda-modeler/releases/download/v${version}/camunda-modeler-${version}-linux-x64.tar.gz";
      sha256 = "sha256-HZrzUKwY4xKA2MKvz3tHbv5GYgKQq05iZj2smXyJ2iQ=";
    };
    nativeBuildInputs = [ nodePackages.asar autoPatchelfHook gcc-unwrapped ];
    installPhase = ''
      asar extract ./resources/app.asar $out
    '';
  };

in

stdenv.mkDerivation rec {
  name = "camunda-modeler-${version}";
  version = "5.5.1";
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
