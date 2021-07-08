# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let 
  dwm = (import ../../packages/dwm.nix);
  dwmblocks = (import ../../packages/dwmblocks.nix);
in
{
  imports = [
    ../../hardware/nvidia-prime.nix
    ../../hardware/radeon.nix
    ../../scripts/system-clean.nix
    ../../scripts/system-upgrade.nix
    ../../scripts/set-brightness.nix
    ../../scripts/battery.nix

    ../../desktop/sound.nix
    ../../desktop/x11.nix
    ../../desktop/fonts.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    kernelPackages = pkgs.linuxPackages_latest;
  };
  
  networking.hostName = "swan"; # Define your hostname.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Rome";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.eno1.useDHCP = true;
  networking.interfaces.wlp4s0.useDHCP = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "it";
  };

  # Configure keymap in X11
  services.xserver.layout = "it";
  services.xserver.xkbOptions = "eurosign:e";
  
  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.giovanni = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    openssh.authorizedKeys.keys = [
      (import ../../ssh-keys/lenovo.nix).lenovoKey
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget neovim curl git
    sudo neofetch htop
    firefox keepassxc glxinfo
    networkmanager
    gnome3.gnome-tweaks
    tdesktop lightdm
    alacritty 
    vscode openvpn

    dwm dwmblocks dmenu
    feh
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}