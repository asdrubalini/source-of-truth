{ config, pkgs, lib, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ../services/ssh-secure.nix
  ];

  boot = {
    initrd.availableKernelModules = [ "uhci_hcd" "ehci_pci" "ahci" "virtio_pci" "sr_mod" "virtio_blk" ];

    kernel.sysctl = {
      "net.ipv4.conf.all.forwarding" = true;
      "net.ipv6.conf.all.forwarding" = true;
    };
  };

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/a00746d8-02d2-4b0b-8226-3745c33918c8";
      fsType = "btrfs";
      options = [ "subvol=@" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/a00746d8-02d2-4b0b-8226-3745c33918c8";
      fsType = "btrfs";
      options = [ "subvol=@home" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/a00746d8-02d2-4b0b-8226-3745c33918c8";
      fsType = "btrfs";
      options = [ "subvol=@nix" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/6CAD-375A";
      fsType = "vfat";
    };

  networking = {
    interfaces = {
      # enp1s0f0.ipv4.addresses = [ { address = "192.168.1.1"; prefixLength = 24; } ];
    };

    nameservers = [ "1.1.1.1" ];
    defaultGateway = "10.0.0.1";
  };

  hardware.cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;
  hardware.enableRedistributableFirmware = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nixpkgs.config.allowUnfree = true;
  networking.hostName = "sdr";
  time.timeZone = "Europe/Rome";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    earlySetup = true;
    font = "${pkgs.terminus_font}/share/consolefonts/ter-132n.psf.gz";
    packages = with pkgs; [ terminus_font ];
  };

  users = {
    mutableUsers = false;
    extraUsers.root.hashedPassword = (import ../passwords).password;

    users.giovanni = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      hashedPassword = (import ../passwords).password;
    };
  };

  environment.systemPackages = with pkgs; [];

  programs.neovim.enable = true;
  programs.neovim.viAlias = true;

  services.qemuGuest.enable = true;
  services.sdrplayApi.enable = true;

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  users.users."giovanni".openssh.authorizedKeys.keys =
    [
      (import ../ssh-keys/the-hydra.nix).key
      (import ../ssh-keys/proxmox.nix).key
    ];

  system.stateVersion = "22.05";
}