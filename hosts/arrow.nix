{ config, pkgs, lib, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ../services/ssh-secure.nix
    ../network/hosts.nix

    ../scripts/system-apply.nix
  ];

  nixpkgs.config.allowUnfree = true;
  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "arrow";

  time.timeZone = "Europe/Rome";

  networking.useDHCP = false;
  networking.interfaces.ens3.useDHCP = true;
  networking.interfaces.ens10.useDHCP = true;

  boot.initrd.availableKernelModules =
    [ "ata_piix" "virtio_pci" "virtio_scsi" "xhci_pci" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/6cd1d21a-1d6b-405a-b6ec-f5e204649ea7";
    fsType = "btrfs";
  };

  swapDevices = [ ];

  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    earlySetup = true;
    font = "${pkgs.terminus_font}/share/consolefonts/ter-132n.psf.gz";
    packages = with pkgs; [ terminus_font ];
    keyMap = "it";
  };

  users = {
    mutableUsers = false;
    extraUsers.root.hashedPassword = (import ../passwords).password;

    users.giovanni = {
      isNormalUser = true;
      extraGroups = [ "wheel" "libvirtd" "docker" ];
      hashedPassword = (import ../passwords).password;
    };
  };

  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = with pkgs; [ neovim git ];

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  users.users."giovanni".openssh.authorizedKeys.keys =
    [ (import ../ssh-keys/swan.nix).key ];

  # networking.firewall.allowedTCPPorts = [ ...];
  # networking.firewall.allowedUDPPorts = [ ... ];

  system.stateVersion = "22.05";
}
