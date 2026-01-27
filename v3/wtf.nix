{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = /dev/nbd0;
  boot.loader.grub.useOSProber = true;
  boot.loader.grub.enableCryptodisk = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.efi.efiSysMountPoint = /boot;

  networking.networkmanager.enable = true;

  time.timeZone = Europe/Amsterdam;

  i18n.defaultLocale = en_US.UTF-8;
  console = {
    font = Lat2-Terminus16;
    keyMap = us;
    useXkbConfig = true;
  };

  users.users.alice = {
    isNormalUser = true;
    extraGroups = [ wheel ];
    packages = with pkgs; [
      tree
    ];
  };

  environment.systemPackages = with pkgs; [
    #
  ];
  system.stateVersion = 26.05;

}
