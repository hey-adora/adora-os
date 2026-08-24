rm -f hardware-configuration.nix
nixos-generate-config --show-hardware-config --no-filesystems > hardware-configuration.nix &&\
sudo nix run --extra-experimental-features "nix-command flakes" "github:nix-community/disko/latest#disko-install" -- --flake ".#b650" --disk main /dev/nvme0n1

