rm -f hardware-configuration.nix
nixos-generate-config --show-hardware-config --no-filesystems > hardware-configuration.nix &&\
git add.
sudo nix run --extra-experimental-features "nix-command flakes" "github:nix-community/disko/latest#disko-install" -- --flake ".#b650" --disk main /dev/disk/by-id/nvme-Samsung_SSD_990_PRO_2TB_S7DNNJ0X204141J

