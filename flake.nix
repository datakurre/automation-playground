{
  description = "Automation playground";

  # Flakes
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/release-22.05";
  inputs.nixpkgs-unstable.url = "github:NixOS/nixpkgs/master";
  inputs.home-manager = { url = "github:rycee/home-manager/release-22.05"; inputs.nixpkgs.follows = "nixpkgs"; inputs.utils.follows = "flake-utils"; };
  inputs.parrot-rcc = { url = "github:datakurre/parrot-rcc/main"; inputs.nixpkgs.follows = "nixpkgs"; inputs.flake-utils.follows = "flake-utils"; };

  # Sources
  inputs.rcc = { url = "github:robocorp/rcc/65cb4b6f9fb30cffd61c3f0d3617d33b51390c61"; flake = false; }; # v11.31.2
  inputs.zbctl = { url = "github:camunda/zeebe/clients/go/v8.1.3"; flake = false; };

  # Systems
  outputs = { self, nixpkgs, flake-utils, home-manager, parrot-rcc, rcc, zbctl, ... }: flake-utils.lib.eachDefaultSystem (system: let pkgs = nixpkgs.legacyPackages.${system}; in {

    # Packages
    packages.camunda-modeler = pkgs.callPackage ./pkgs/camunda-modeler {};
    packages.mockoon = pkgs.callPackage ./pkgs/mockoon {};
    packages.zbctl = pkgs.callPackage ./pkgs/zbctl { src = zbctl; version = "v8.1.3"; };
    packages.rcc = pkgs.callPackage ./pkgs/rcc/rcc.nix { src = rcc; version = "v11.31.2"; };
    packages.rccFHSUserEnv = pkgs.callPackage ./pkgs/rcc { src = rcc; version = "v11.31.2"; };
    packages.zeebe = pkgs.callPackage ./pkgs/zeebe {};
    packages.zeebe-play = pkgs.callPackage ./pkgs/zeebe-play {};
    packages.zeebe-simple-monitor = pkgs.callPackage ./pkgs/zeebe-simple-monitor {};
    packages.parrot-rcc = parrot-rcc.packages.${system}.default;

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
        (import "${home-manager}/nixos")
        (nixpkgs + "/nixos/modules/virtualisation/google-compute-image.nix")
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

  }) // {

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
