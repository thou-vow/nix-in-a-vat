{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf (config.specialisation != {}) {
    nixpkgs.overlays = [
      (final: prev: {
        # nix = final.lixPackageSets.latest.lix;
      })
    ];

    boot = {
      initrd.availableKernelModules = [
        "ehci_pci"
        "xhci_pci"
        "ahci"
        "usb_storage"
        "uas"
        "sd_mod"
        "usbhid"
      ];
      kernelPackages = inputs.chaotic.legacyPackages.${pkgs.system}.linuxPackages_cachyos-lto;
    };

    hardware = {
      enableAllFirmware = true;
      enableAllHardware = true;
    };

    nix.package = pkgs.lixPackageSets.latest.lix;

    swapDevices = [
      {device = "/dev/disk/by-id/wwn-0x500003988168a3bd-part3";}
    ];
  };
}
