# rm -f hardware-configuration.nix
# nixos-generate-config --show-hardware-config --no-filesystems > hardware-configuration.nix &&\
# sudo nix run --extra-experimental-features "nix-command flakes" "github:nix-community/disko/latest#disko-install" -- --write-efi-boot-entries --flake ".#adora" --disk main /dev/vda
#
rm -f hardware-configuration.nix
nixos-generate-config --show-hardware-config --no-filesystems > hardware-configuration.nix &&\
git add . &&\
sudo nix run --extra-experimental-features "nix-command flakes" "github:nix-community/disko/latest#disko-install" -- --flake ".#main" --disk main /dev/vda

