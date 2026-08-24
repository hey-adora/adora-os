{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    disko.url = "github:nix-community/disko/latest";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      nixpkgs,
      disko,
      home-manager,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
      };
    in
    {

      nixosConfigurations.b650 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit system inputs pkgs; };
            home-manager.backupFileExtension = "old12";

            home-manager.users.lyndonm = (
              {
                lib,
                config,
                nixpkgs,
                pkgs,
                system,
                inputs,
                ...
              }:

              {

                programs.home-manager.enable = true;

                home.stateVersion = "25.11";

                home.username = "lyndonm";
                home.homeDirectory = "/home/lyndonm";

                programs.git.enable = true;

                home.packages = with pkgs; [
                  firefox
                ];



              }
            );

          }
          (
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

              nixpkgs.config.allowUnfree = true;

              nix.settings.experimental-features = "nix-command flakes";
              nix.settings.auto-optimise-store = true;
              nix.settings.cores = 4;

              boot.kernelParams = [
                "drm.panic_screen=qr_code"
                "zswap.enabled=1"
                "zswap.compressor=zstd"
                "zswap.zpool=zsmalloc"
                "zswap.max_pool_percent=25"
                "zswap.accept_threshold_percent=90"
                "zswap.shrinker_enabled=1"
              ];

              swapDevices = [
                {
                  device = "/var/lib/swapfile";
                  size = 32 * 1024;
                }
              ];

              boot.loader.systemd-boot.enable = true;

              networking.hostName = "b650";
              networking.networkmanager.enable = true;

              services.desktopManager.plasma6.enable = true;
              services.displayManager.sddm.enable = true;

              programs.bash.enable = true;

              time.timeZone = "NZ";

              i18n.defaultLocale = "en_US.UTF-8";
              i18n.extraLocales = [ "ja_JP.UTF-8/UTF-8" ];
              console = {
                font = "Lat2-Terminus16";
                keyMap = "us";
              };

              users.users.lyndonm = {
                initialPassword = "home";
                isNormalUser = true;
                shell = pkgs.bash;
              };

              environment.systemPackages = with pkgs; [
                git
              ];
              system.stateVersion = "25.11";

            }
          )
          disko.nixosModules.disko
          {
            disko.devices = {
              disk = {

                main = {
                  type = "disk";
                  device = "/dev/disk/by-id/nvme-Samsung_SSD_990_PRO_2TB_S7DNNJ0X204141J";
                  content = {
                    type = "gpt";
                    partitions = {
                      ESP = {
                        type = "EF00";
                        size = "1G";
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




