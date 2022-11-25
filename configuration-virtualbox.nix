{ config, pkgs, ... }: {

  swapDevices = [{
    device = "/var/swap";
    size = 4096;
  }];

  services.xserver.videoDrivers = [ "virtualbox" "vmware" "cirrus" "vesa" ];
  users.extraUsers.vagrant.extraGroups = [ "vboxsf" ];
  virtualisation.virtualbox.guest.enable = true;
  virtualisation.virtualbox.guest.x11 = true;

  virtualbox = {
    vmDerivationName = "nixos-ova-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}";
    vmFileName = "parrot-rcc-nixos-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}.ova";
    vmName = "parrot-rcc (NixOS ${config.system.nixos.label} ${pkgs.stdenv.hostPlatform.system})";
    memorySize = 8 * 1024;
  # params = { usbehci = "off"; };
  };

}
