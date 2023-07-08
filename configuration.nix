{ config, pkgs, lib, ... }:

let
  user = "alien";
  password = "alien";
  hostname = "roboblast";
in {
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  time.timeZone = "Europe/Berlin";

  boot.loader.timeout = 1;

  networking = {
    hostName = hostname;
    wireless.enable = false;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 443 4444 ];
    };
  };

  systemd.user.services.leds = {
    description = "roboclub lighting";
    serviceConfig = {
      WorkingDirectory = "%h/leds";
      ExecStart = "%h/leds/robolab";
    };
    wantedBy = ["default.target"];
  };

  environment.systemPackages = with pkgs; [
    # gui
    chromium

    # cli
    neovim
    file
    pciutils

    # pi dtbo
    dtc
  ];

  services.openssh.enable = true;

  programs.fish.enable = true;

  users = {
    mutableUsers = false;
    users."${user}" = {
      isNormalUser = true;
      initialPassword = password;
      extraGroups = [ "wheel" "spi" "gpio" ];
      shell = pkgs.fish;
    };
  };

  # Enable GPU acceleration
  hardware.raspberry-pi."4" = {
    fkms-3d.enable = true;
    audio.enable = true;
    apply-overlays-dtmerge.enable = true;
  };

  # enable SPI
  hardware.deviceTree = {
    enable = true;
    overlays = [
      {
        name = "spi";
        dtboFile = ./spi0-0cs.dtbo;
      }
    ];
  };

  boot.extraModprobeConfig = ''
    options spidev bufsiz=8192
  '';

  users.groups.spi = {};
  users.groups.gpio = {};

  services.udev.extraRules = ''
    SUBSYSTEM=="spidev", KERNEL=="spidev0.0", GROUP="spi", MODE="0660"

    SUBSYSTEM=="gpio*", GROUP="gpio", MODE="0660"
    SUBSYSTEM=="bcm2835-gpiomem", GROUP="gpio", MODE="0660"
  '';

  hardware.pulseaudio.enable = true;

  services.xserver = {
    enable = true;

    displayManager = {
      lightdm.enable = true;

      autoLogin = {
        enable = true;
        user = "alien";
      };
    };

    # desktopManager.xfce.enable = true;
    desktopManager.gnome.enable = true;

    # rotate 180 deg for Elo Touchmonitor
    inputClassSections = [
      ''
        Identifier    "Elo Touchmonitor"
        MatchProduct  "Elo TouchSystems 2700 IntelliTouch(r) USB Touchmonitor Interface"
        Option        "TransformationMatrix"  "-1 0 1 0 -1 1 0 0 1"
      ''
    ];
  };

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "23.05";
}
