{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = "nix-command flakes";
  nix.settings.auto-optimise-store = true;

  zramSwap.enable = true;
  zramSwap.memoryPercent = 150;

  boot.kernel.sysctl."kernel.sysrq" = 1;

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/nbd0";
  boot.loader.grub.useOSProber = true;
  boot.loader.grub.enableCryptodisk = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.efi.efiSysMountPoint = "/boot";

  networking.hostName = "adora";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Amsterdam";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  users.users.hey = {
    isNormalUser = true;
    initialPassword = "home";
    extraGroups = [ "wheel" ]; 
    packages = with pkgs; [
      tree
    ];
  };

  environment.systemPackages = with pkgs; [
    #
  ];
  system.stateVersion = "26.05";

}
