lsblk
echo "Enter TARGET drive (example \"/dev/sda\"):"
read TARGET

echo "Enter NAME (example \"alice\"):"
read NAME 

echo "Enter PASSWORD (text is invisible):"
read -s PASSWORD 

HOSTNAME="${NAME}-pc"

CONFIG="{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = \"nix-command flakes\";
  nix.settings.auto-optimise-store = true;

  zramSwap.enable = true;
  zramSwap.memoryPercent = 150;

  boot.kernel.sysctl.\"kernel.sysrq\" = 1;

  boot.loader.grub.enable = true;
  boot.loader.grub.device = \"${TARGET}\";
  boot.loader.grub.useOSProber = true;
  boot.loader.grub.enableCryptodisk = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.efi.efiSysMountPoint = \"/boot\";

  networking.hostName = \"${HOSTNAME}\";
  networking.networkmanager.enable = true;

  time.timeZone = \"Europe/Amsterdam\";

  i18n.defaultLocale = \"en_US.UTF-8\";
  console = {
    font = \"Lat2-Terminus16\";
    keyMap = \"us\";
  };

  users.users.root.initialPassword = \"${PASSWORD}\";
  users.users.${NAME} = {
    isNormalUser = true;
    initialPassword = \"${PASSWORD}\";
    extraGroups = [ \"wheel\" ]; 
    packages = with pkgs; [
      tree
    ];
  };

  environment.systemPackages = with pkgs; [
    #
  ];
  system.stateVersion = \"26.05\";

}"

# echo "${CONFIG}" > wtf.nix
#
# exit

sudo umount /mnt/boot
sudo umount /mnt
sudo cryptsetup close crypted_adoraos
rm nixos/configuration.nix
rm nixos/hardware-configuration.nix
rmdir nixos 

sudo wipefs -a "${TARGET}"
(

echo "n"
echo   
echo   
echo "+1M"
echo "ef02"

echo "n"
echo   
echo   
echo "+1G"
echo "ef00"

echo "n"
echo   
echo   
echo 
echo "8300"

echo "w"
echo "y"
) | sudo gdisk "${TARGET}"

TARGET_PARTS=$(lsblk -l -o NAME "${TARGET}")
echo "target parts\n${TARGET_PARTS}"
TARGET_PART1=$(echo "${TARGET_PARTS}" | sed -n '3p')
TARGET_PART2=$(echo "${TARGET_PARTS}" | sed -n '4p')
TARGET_PART3=$(echo "${TARGET_PARTS}" | sed -n '5p')

TARGET_PART1="/dev/${TARGET_PART1}"
TARGET_PART2="/dev/${TARGET_PART2}"
TARGET_PART3="/dev/${TARGET_PART3}"

sudo mkfs.fat -F32 "${TARGET_PART2}"
echo -n "${PASSWORD}" | sudo cryptsetup --type=luks1 luksFormat "${TARGET_PART3}" -

echo -n "${PASSWORD}" | sudo cryptsetup open "${TARGET_PART3}" crypted_adoraos -

sudo mkfs.ext4 /dev/mapper/crypted_adoraos

sudo mount /dev/mapper/crypted_adoraos /mnt
sudo mkdir /mnt/boot
sudo mount "${TARGET_PART2}" /mnt/boot
sudo mkdir /mnt/etc

mkdir nixos
echo "${CONFIG}" > nixos/configuration.nix
nixos-generate-config --show-hardware-config --root /mnt > nixos/hardware-configuration.nix
sudo cp -r nixos /mnt/etc/
sudo nixos-install --no-root-password


