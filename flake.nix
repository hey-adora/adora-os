{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    disko.url = "github:nix-community/disko/latest";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      nixpkgs,
      disko,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
      };
    in
    {

      nixosConfigurations.myserver = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
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
              #nix.settings.cores = 4;

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
                  size = 1 * 1024;
                }
              ];

              boot.loader.systemd-boot.enable = true;

              networking.hostName = "myserver";
              networking.networkmanager.enable = true;

              programs.bash.enable = true;


              time.timeZone = "Europe/Berlin";

              i18n.defaultLocale = "en_US.UTF-8";
              console = {
                font = "Lat2-Terminus16";
                keyMap = "us";
              };

              services.openssh = {
                enable = true;
                ports = [ 64999 ];
                settings = {
                  PasswordAuthentication = false;
                  KbdInteractiveAuthentication = false;
                  PermitRootLogin = "yes";
                  AllowUsers = [
                    "alice"
                    "root"
                  ];
                };
              };

              users.users.alice = {
                initialPassword = "home";
                isNormalUser = true;
                openssh.authorizedKeys.keys = [
                  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFcNLaEyw6ot4z6wQvEDZn1cVPE9i5ntHz0vw7QCAPqG adora@heyadora.com"
                ];
                extraGroups = [
                  "wheel"
                ];
                shell = pkgs.bash;
              };

              environment.systemPackages = with pkgs; [
                git
                firefox
              ];
              system.stateVersion = "25.11";

            }
          )
          disko.nixosModules.disko
          {
            disko.devices = {
              disk = {
                main = {
                  device = "/dev/vda";
                  type = "disk";
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

