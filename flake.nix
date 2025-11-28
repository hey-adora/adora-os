{
  description = "Home Manager configuration of hey";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko/latest";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, disko, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {

      packages."x86_64-linux".default = pkgs.hello;

      homeConfigurations."hey" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        extraSpecialArgs = { inherit nixpkgs system inputs; };

        modules = [
          (

            { lib, config, nixpkgs, pkgs, system, inputs, ... }:

            with lib.hm.gvariant;

            {

              nixpkgs.config.allowUnfree = true;

              home.stateVersion = "25.11";
              home.packages = with pkgs; [ neovim ];

            }

          )
        ];
      };

      nixosConfigurations.adora = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ({ config, lib, pkgs, ... }:

            {
              imports = [ ./hardware-configuration.nix ./cachix.nix ];

              nixpkgs.config.allowUnfree = true;

              nix.settings.experimental-features = "nix-command flakes";
              nix.settings.auto-optimise-store = true;
              nix.settings.cores = 4;

              boot.kernelPackages = pkgs.linuxPackages_latest;

              boot.initrd.enable = true;
              boot.initrd.systemd.enable = true;
              boot.loader.grub.enable = true;
              boot.loader.grub.device = "/dev/vga";
              boot.loader.grub.useOSProber = true;
              boot.loader.grub.enableCryptodisk = true;
              boot.loader.grub.efiSupport = true;
              boot.loader.grub.efiInstallAsRemovable = true;
              boot.loader.efi.efiSysMountPoint = "/boot";

              networking.hostName = "adora"; # Define your hostname.
              networking.networkmanager.enable = true;

              programs.zsh.enable = true;

              # Set your time zone.
              time.timeZone = "Europe/Paris";

              i18n.defaultLocale = "en_US.UTF-8";
              i18n.extraLocales = [ "ja_JP.UTF-8/UTF-8" ];
              console = {
                font = "Lat2-Terminus16";
                keyMap = "us";
                # useXkbConfig = true; # use xkb.options in tty.
              };

              users.users.hey = {
                initialPassword = "home";
                isNormalUser = true;
                openssh.authorizedKeys.keys = [
                  # todo: add your ssh public key(s) here, if you plan on using ssh to connect
                ];
                extraGroups = [ "wheel" ];
                shell = pkgs.zsh;
                packages = with pkgs; [ home-manager zsh ];
              };

              environment.systemPackages = with pkgs; [ neovim ];

              environment.variables."RUSTICL_ENABLE" = "radeonsi";
              system.stateVersion = "25.11";

            })
          disko.nixosModules.disko
          {
            disko.devices = {
              disk = {
                main = {
                  # When using disko-install, we will overwrite this value from the commandline
                  device = "/dev/disk/by-id/some-disk-id";
                  type = "disk";
                  content = {
                    type = "gpt";
                    partitions = {
                      MBR = {
                        type = "EF02"; # for grub MBR
                        size = "1M";
                        priority = 1; # Needs to be first partition
                      };
                      ESP = {
                        type = "EF00";
                        size = "500M";
                        content = {
                          type = "filesystem";
                          format = "vfat";
                          mountpoint = "/boot";
                          mountOptions = [ "umask=0077" ];
                        };
                      };
                      root = {
                        size = "100%";
                        content = {
                          type = "filesystem";
                          format = "ext4";
                          mountpoint = "/";
                        };
                      };
                    };
                  };
                };
              };
            };
          }
        ];
      };

    };
}
