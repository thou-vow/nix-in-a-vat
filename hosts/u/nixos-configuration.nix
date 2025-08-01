{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./attuned-specialisation.nix
    ./drive-format.nix
    ./no-specialisation.nix
  ];

  mods = {
    flakePath = "/flake";
    nh.enable = true;
  };

  nixpkgs.overlays = builtins.attrValues inputs.self.overlays;

  boot = {
    kernel.sysctl = {
      "kernel.kexec_load_disabled" = 1;
      "kernel.nmi_watchdog" = 0;
      "vm.swappiness" = 10;
      "vm.dirty_background_ratio" = 2;
      "vm.dirty_ratio" = 5;
      "vm.vfs_cache_pressure" = 25;
    };
    kernelParams = [
      "mitigations=off"
      "zswap.enabled=1"
      "zswap.max_pool_percent=60"
      "zswap.shrinker_enabled=0"
    ];
  };

  console = {
    colors = [
      "121622"
      "ea8f80"
      "6ac27f"
      "c7a84d"
      "92a8eb"
      "db8ad4"
      "52bcce"
      "aeb8d4"
      "7683a8"
      "f5b3a7"
      "7ae092"
      "e5c25f"
      "b3c4f5"
      "eaafe4"
      "6bd8ea"
      "ced4e6"
    ];
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  environment = {
    systemPackages = with pkgs; [
      btop
      cachix
      home-manager
      ncdu
      nh
      pciutils
      unzip
      usbutils
      util-linux
      zip
    ];
  };

  hardware = {
    cpu.intel.updateMicrocode =
      config.hardware.enableRedistributableFirmware
      || config.hardware.enableAllFirmware;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "pt_BR.UTF-8";
      LC_IDENTIFICATION = "pt_BR.UTF-8";
      LC_MEASUREMENT = "pt_BR.UTF-8";
      LC_MONETARY = "pt_BR.UTF-8";
      LC_NAME = "pt_BR.UTF-8";
      LC_NUMERIC = "pt_BR.UTF-8";
      LC_PAPER = "pt_BR.UTF-8";
      LC_TELEPHONE = "pt_BR.UTF-8";
      LC_TIME = "pt_BR.UTF-8";
    };
  };

  networking = {
    hostName = "u";
    networkmanager.enable = true;
  };

  nix = {
    nixPath =
      lib.mapAttrsToList (key: _: "${key}=flake:${key}") config.nix.registry;

    registry =
      lib.mapAttrs (_: value: {flake = value;})
      (lib.filterAttrs (_: value: lib.isType "flake" value) inputs);

    settings = {
      experimental-features = ["flakes" "nix-command" "pipe-operator"];
      flake-registry = "";
      system-features = ["gccarch-skylake"];
      trusted-users = ["@wheel"];
    };
  };

  programs = {
    appimage.enable = true;
    firefox.enable = true;
    fish.enable = true;
    git.enable = true;
  };

  security = {
    rtkit.enable = true;
    polkit.enable = true;
    sudo.package = pkgs.sudo.override {withInsults = true;};
  };

  services = {
    lvm.enable = false;
    openssh.enable = true;
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
    };
    pulseaudio.enable = false;
    xserver.xkb = {
      layout = "br,us";
      options = "caps:escape_shifted_capslock,grp:win_space_toggle";
    };
  };

  system.stateVersion = "25.05";

  systemd = {
    oomd.enable = false;
    services =
      lib.mapAttrs' (name: value:
        lib.nameValuePair "hm-activation-${name}" {
          description = "Run ${name} Home Manager activation";

          wantedBy = ["user-runtime-dir@${builtins.toString value.uid}.service"];
          before = ["user@${builtins.toString value.uid}.service"];

          serviceConfig = {
            # ExecStart is defined in the modes
            RemainAfterExit = "yes";
            Type = "oneshot";
            User = name;
          };
        })
      # Only for users within home-manager group
      (lib.filterAttrs (_: value: builtins.any (group: group == "home-manager") value.extraGroups)
        config.users.users);
  };

  time.timeZone = "America/Sao_Paulo";

  users.users = {
    root.password = "123";
    thou = {
      uid = 1000;
      isNormalUser = true;
      description = "thou";
      extraGroups = ["home-manager" "networkmanager" "wheel"];
      password = "123";
      shell = pkgs.fish;
    };
  };
}
