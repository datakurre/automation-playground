{
  description = "Automation playground";

  # Flakes
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/release-22.11";
  inputs.nixpkgs-unstable.url = "github:NixOS/nixpkgs/master";
  inputs.home-manager = { url = "github:rycee/home-manager/release-22.11"; inputs.nixpkgs.follows = "nixpkgs"; inputs.utils.follows = "flake-utils"; };
  inputs.bpmn-to-image = { url = "github:bpmn-io/bpmn-to-image"; flake = false; };
  inputs.npmlock2nix = { url = "github:nix-community/npmlock2nix"; flake = false; };
  inputs.parrot-rcc = { url = "github:datakurre/parrot-rcc/main"; inputs.nixpkgs.follows = "nixpkgs"; inputs.flake-utils.follows = "flake-utils"; };

  # Sources
  inputs.rcc = { url = "github:robocorp/rcc/13a822cf33b1f27c9f042085ec6d330f5d1d8073"; flake = false; }; # v11.35.2
  inputs.zbctl = { url = "github:camunda/zeebe/clients/go/v8.1.5"; flake = false; };

  # Systems
  outputs = { self, nixpkgs, flake-utils, home-manager, npmlock2nix, bpmn-to-image, parrot-rcc, rcc, zbctl, ... }: flake-utils.lib.eachDefaultSystem (system: let pkgs = nixpkgs.legacyPackages.${system}; in {

    # Packages
    packages.camunda-modeler = pkgs.callPackage ./pkgs/camunda-modeler {};
    packages.mockoon = pkgs.callPackage ./pkgs/mockoon {};
    packages.zbctl = pkgs.callPackage ./pkgs/zbctl { src = zbctl; version = "v8.1.5"; };
    packages.rcc = pkgs.callPackage ./pkgs/rcc/rcc.nix { src = rcc; version = "v11.35.2"; };
    packages.rccFHSUserEnv = pkgs.callPackage ./pkgs/rcc { src = rcc; version = "v11.35.2"; };
    packages.zeebe = pkgs.callPackage ./pkgs/zeebe {};
    packages.zeebe-play = pkgs.callPackage ./pkgs/zeebe-play {};
    packages.zeebe-simple-monitor = pkgs.callPackage ./pkgs/zeebe-simple-monitor {};
    packages.parrot-rcc = parrot-rcc.packages.${system}.default;
    packages.bpmn-to-image = (import npmlock2nix { inherit pkgs; }).v1.build {
      src = bpmn-to-image;
      installPhase = ''
        mkdir -p $out/bin $out/lib
        cp -a node_modules $out/lib
        cp -a cli.js $out/bin/bpmn-to-image
        cp -a index.js $out/lib
        cp -a skeleton.html $out/lib
        substituteInPlace $out/bin/bpmn-to-image \
          --replace "'./'" \
                    "'$out/lib'"
        substituteInPlace $out/lib/index.js \
          --replace "puppeteer.launch();" \
                    "puppeteer.launch({executablePath: '${pkgs.chromium}/bin/chromium'});"
        wrapProgram $out/bin/bpmn-to-image \
          --set PATH ${pkgs.lib.makeBinPath [ pkgs.nodejs ]} \
          --set NODE_PATH $out/lib/node_modules
      '';
      buildInputs = [ pkgs.makeWrapper ];
      buildCommands = [];
      node_modules_attrs = {
        PUPPETEER_SKIP_DOWNLOAD = "true";
      };
    };
    packages.docs = pkgs.stdenv.mkDerivation {
      name = "open-automation-playground-docs";
      src = ./docs;
      buildInputs = [
        (pkgs.python3.withPackages(ps: [ ps.sphinx ps.myst-parser ps.sphinx_rtd_theme ]))
      ];
      phases = [ "unpackPhase" "installPhase" ];
      installPhase = ''
        sphinx-build -b html . $out
      '';
    };

    # Overlay
    overlays.default = final: prev: {
      inherit (self.packages.${system})
      camunda-modeler
      mockoon
      rcc
      rccFHSUserEnv
      zbctl
      zeebe
      zeebe-play
      zeebe-simple-monitor
      parrot-rcc
      bpmn-to-image
      ;
    };

    # Systems and images
    packages.default = (nixpkgs.lib.nixosSystem {
      modules = [
        (nixpkgs + "/nixos/modules/virtualisation/vagrant-guest.nix")
        (nixpkgs + "/nixos/modules/virtualisation/vagrant-virtualbox-image.nix")
        (import "${home-manager}/nixos")
        ({config, pkgs, ...}: { nixpkgs.overlays = [ self.overlays.${system}.default ]; })
        ./configuration-virtualbox.nix
        ./configuration-gce.nix
        ./configuration-common.nix
      ];
      inherit system;
    }).config.system.build.toplevel;

    packages.gce = (import (nixpkgs + "/nixos/lib/eval-config.nix") {
      modules = [
        (nixpkgs + "/nixos/modules/virtualisation/google-compute-image.nix")
        (import "${home-manager}/nixos")
        ({config, pkgs, ...}: { nixpkgs.overlays = [ self.overlays.${system}.default ]; })
        ./configuration-gce.nix
        ./configuration-common.nix
      ];
      inherit system;
    }).config.system.build.googleComputeImage;

    packages.vagrantbox = (import (nixpkgs + "/nixos/lib/eval-config.nix") {
      modules = [
        (nixpkgs + "/nixos/modules/virtualisation/vagrant-guest.nix")
        (nixpkgs + "/nixos/modules/virtualisation/vagrant-virtualbox-image.nix")
        (import "${home-manager}/nixos")
        ({config, pkgs, ...}: { nixpkgs.overlays = [ self.overlays.${system}.default ]; })
        ./configuration-virtualbox.nix
        ./configuration-common.nix
      ];
      inherit system;
    }).config.system.build.vagrantVirtualbox;

    # Shells
    devShells.java = pkgs.mkShell {
      buildInputs = [
        (pkgs.buildFHSUserEnv {
          name = "mvn2nix-shell";
          targetPkgs = pkgs: (with pkgs; [
            jdk17
            (maven.override { jdk = jdk17; })
            (mvn2nix.defaultPackage.${system}.override { jdk = jdk17; maven = maven.override { jdk = jdk17; }; })
          ]);
          multiPkgs = pkgs: (with pkgs; []);
          runScript = "mvn2nix";
        })
      ];
    };

    # Sphinx
    devShells.docs = pkgs.mkShell {
      buildInputs = [
        (pkgs.python3.withPackages(ps: [ ps.sphinx ps.myst-parser ps.sphinx_rtd_theme ]))
        self.packages.${system}.bpmn-to-image
      ];
    };

  }) // {

    nixosConfigurations."gce" = nixpkgs.lib.nixosSystem {
      modules = [
        (nixpkgs + "/nixos/modules/virtualisation/google-compute-image.nix")
        (import "${home-manager}/nixos")
        ({config, pkgs, ...}: { nixpkgs.overlays = [ self.overlays.x86_64-linux.default ]; })
        ./configuration-gce.nix
        ./configuration-common.nix
      ];
      system = "x86_64-linux";
    };

    nixosConfigurations."vagrant" = nixpkgs.lib.nixosSystem {
      modules = [
        (nixpkgs + "/nixos/modules/virtualisation/vagrant-guest.nix")
        (nixpkgs + "/nixos/modules/virtualisation/vagrant-virtualbox-image.nix")
        (import "${home-manager}/nixos")
        ({config, pkgs, ...}: { nixpkgs.overlays = [ self.overlays.x86_64-linux.default ]; })
        ./configuration-virtualbox.nix
        ./configuration-common.nix
      ];
      system = "x86_64-linux";
    };

  };
}
