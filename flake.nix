{
  inputs = {
    # nixpkgs.url = "path:/nix/var/nix/profiles/per-user/root/channels/nixos/";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    #nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11/2khx1dqp2hr4wfmpbn1jmw8q8ypzrd99";
    # nixpkgs.url = "path:/nix/store/2khx1dqp2hr4wfmpbn1jmw8q8ypzrd99-nixos-25.11.4506.078d69f03934/nixos";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko/latest";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    helium.url = "github:AlvaroParker/helium-nix";
    helium.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { nixpkgs, disko, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      target = "/dev/sda";
      time = "Europe/Paris";
      hostname = "qqq-pc";
      user = "qqq";
      email = "example@email.com";

      # minimalBase = {
      #   isoImage.squashfsCompression = "gzip -Xcompression-level 1";
      #   systemd.services.sshd.wantedBy = inputs.nixpkgs.lib.mkForce [ "multi-user.target" ];
      # };
    in
    {
      homeConfigurations."${user}" = inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        extraSpecialArgs = { inherit nixpkgs system inputs; };

        modules = [
          (

            {
              lib,
              config,
              nixpkgs,
              pkgs,
              system,
              inputs,
              ...
            }:

            with lib.hm.gvariant;

            {

              programs.home-manager.enable = true;
              nixpkgs.config.allowUnfree = true;
              home.username = "${user}";
              home.homeDirectory = "/home/${user}";

              systemd.user.startServices = true;
              home.shellAliases."ll" = "eza -lhag";
              home.shell.enableShellIntegration = true;
              home.enableDebugInfo = false;

              home.stateVersion = "25.11";
              home.packages =
                with pkgs;
                [
                  firefox
                  nixfmt
                  lua-language-server

                  # sys tools
                  smartmontools
                  eza

                ]
                ++ [ inputs.helium.packages."${system}".default ];

              home.sessionVariables = {
                QT_QPA_PLATFORM = "wayland";
                EDITOR = "nvim";
              };

              xdg.enable = true;
              xdg.mime.enable = true;
              xdg.mimeApps.enable = false;

              i18n.inputMethod.enable = true;
              i18n.inputMethod.type = "fcitx5";
              i18n.inputMethod.fcitx5.waylandFrontend = true;
              i18n.inputMethod.fcitx5.addons = with pkgs; [
                fcitx5-mozc
                fcitx5-gtk
                kdePackages.fcitx5-qt
                fcitx5-tokyonight
              ];
              # i18n.inputMethod.ibus.engines = with pkgs.ibus-engines; [ mozc ];

              fonts.fontconfig.enable = true;
              fonts.fontconfig.defaultFonts.serif = [ "Noto Serif" ];
              fonts.fontconfig.defaultFonts.sansSerif = [ "Noto Sans" ];
              fonts.fontconfig.defaultFonts.monospace = [
                "Noto Sans Mono"
                "Symbola"
              ];
              fonts.fontconfig.defaultFonts.emoji = [ "Noto Color Emoji" ];

              programs.alacritty.enable = true;

              # zellij
              programs.zellij.enable = true;
              programs.zellij.enableZshIntegration = true;
              programs.zellij.settings."theme" = "catppuccin-frappe";

              programs.neovim.enable = true;
              xdg.configFile."nvim".enable = true;
              # xdg.configFile."nvim".source = "/home/${user}/.config/home-manager/nvim";
              xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "/home/${user}/dotfile/nvim";
              programs.neovim.plugins = with pkgs.vimPlugins; [
                catppuccin-nvim
                telescope-nvim
                nvim-treesitter.withAllGrammars
                none-ls-nvim
                nvim-lspconfig
                nvim-cmp
                luasnip
                cmp_luasnip
                friendly-snippets
                cmp-nvim-lsp
                # lsp-progress-nvim
                lualine-nvim
                trouble-nvim
                plenary-nvim
                harpoon2
                smear-cursor-nvim
                neoscroll-nvim
                telescope-ui-select-nvim
                # marks-nvim
                nvim-treesitter-context
                nvim-web-devicons
                outline-nvim
                neo-tree-nvim
                marks-nvim

              ];

              # man
              programs.man.enable = true;
              programs.man.generateCaches = false;

              # zsh
              programs.zsh.enable = true;
              programs.zsh.dotDir = "${config.xdg.configHome}/zsh";
              programs.zsh.envExtra = ''
                GTK_IM_MODULE="fcitx"
                QT_IM_MODULE="fcitx"
                SDL_IM_MODULE="fcitx"
                XMODIFIERS="@im=fcitx"
              '';
              programs.zsh.enableCompletion = true;
              programs.zsh.autosuggestion.enable = true;
              programs.zsh.syntaxHighlighting.enable = true;
              programs.zsh.oh-my-zsh.enable = true;
              programs.zsh.oh-my-zsh.extraConfig = ''
                DISABLE_MAGIC_FUNCTIONS="true"
              '';
              programs.zsh.oh-my-zsh.plugins = [ "git" ];
              programs.zsh.oh-my-zsh.theme = "spaceship";
              programs.zsh.oh-my-zsh.custom = "$HOME/.zsh-custom";
              home.file.".zsh-custom/themes/spaceship.zsh-theme".source =
                "${pkgs.spaceship-prompt}/share/zsh/themes/spaceship.zsh-theme";

              # git
              programs.git.enable = true;
              programs.git.settings.user.name = "${user}";
              programs.git.settings.user.email = "${email}";
              programs.git.settings.extraConfig.safe.directory = "*";

              # atuin
              programs.atuin.enable = true;
              programs.atuin.daemon.enable = true;
              programs.atuin.enableBashIntegration = true;
              programs.atuin.enableZshIntegration = true;

            }
          )
        ];
      };

      nixosConfigurations.adoraos = nixpkgs.lib.nixosSystem {

        system = "${system}";
        specialArgs = { inherit inputs; };
        # minimalIso = inputs.nixpkgs.lib.nixosSystem {
        #   system = "x86_64-linux";
        #   modules = [
        #     "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        #     minimalBase
        #   ];
        # };
        modules = [
          # "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          # minimalBase
          disko.nixosModules.disko
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
                ./cachix.nix
              ];

              nixpkgs.config.allowUnfree = true;

              nix.settings.experimental-features = "nix-command flakes";
              nix.settings.auto-optimise-store = true;
              nix.settings.cores = 2;

              zramSwap.enable = true;
              zramSwap.memoryPercent = 150;

              # hardware.nvidia.open = true;
              # hardware.nvidia.nvidiaSettings = true;
              # hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.legacy_480;
              # hardware.nvidia.modesetting.enable = true;
              # hardware.nvidia.powerManagement.enable = true;

              # hardware.graphics.enable = true;
              # hardware.graphics.enable32Bit = true;
              # hardware.graphics.extraPackages = with pkgs; [
              #   mesa.opencl
              #   nvidia-vaapi-driver
              #   intel-media-driver
              #   intel-vaapi-driver
              #   libvdpau-va-gl
              # ];
              # hardware.graphics.extraPackages32 = with pkgs.pkgsi686Linux; [ intel-vaapi-driver ];

              # boot.kernelPackages = pkgs.linuxPackages_latest;
              # boot.kernelParams = [
              #   "radeon.si_support=0"
              #   "amdgpu.si_support=1"
              #   "radeon.cik_support=0"
              #   "amdgpu.cik_support=1"
              #   "drm.panic_screen=qr_code"
              # ];

              # services.pipewire.enable = true;
              # services.pipewire.pulse.enable = true;
              # services.pipewire.alsa.enable = true;
              # services.pipewire.alsa.support32Bit = true;
              # services.pipewire.jack.enable = true;
              # services.libinput.enable = true;

              boot.kernel.sysctl."kernel.sysrq" = 1;

              # boot.crashDump.enable = true;
              # boot.initrd.enable = true;
              # boot.initrd.systemd.enable = true;

              boot.loader.grub.enable = true;
              boot.loader.grub.device = "${target}";
              boot.loader.grub.useOSProber = true;
              boot.loader.grub.enableCryptodisk = true;
              boot.loader.grub.efiSupport = true;
              boot.loader.grub.efiInstallAsRemovable = true;
              boot.loader.efi.canTouchEfiVariables = false;
              boot.loader.efi.efiSysMountPoint = "/boot";

              networking.hostName = "${hostname}";
              networking.networkmanager.enable = true;
              hardware.bluetooth.enable = true;

              # services.desktopManager.plasma6.enable = true;
              # services.displayManager.sddm.enable = true;
              # services.displayManager.sddm.wayland.enable = true;

              programs.zsh.enable = true;

              # users.groups.libvirtd.members = [ "${user}" ];
              # virtualisation.libvirtd.enable = true;
              # programs.virt-manager.enable = true;

              time.timeZone = "${time}";

              i18n.defaultLocale = "en_US.UTF-8";
              # i18n.extraLocales = [ "ja_JP.UTF-8/UTF-8" ];
              console = {
                font = "Lat2-Terminus16";
                keyMap = "us";
              };
              fonts.packages = with pkgs; [
                noto-fonts
                noto-fonts-cjk-sans
                noto-fonts-color-emoji
              ];

              users.users."${user}" = {
                initialPassword = "home";
                isNormalUser = true;
                extraGroups = [ "wheel" ];
                shell = pkgs.zsh;
                packages = with pkgs; [ zsh ];
              };

              environment.systemPackages = with pkgs; [ neovim ];
              # environment.variables."RUSTICL_ENABLE" = "radeonsi";

              system.stateVersion = "25.11";

            }
          )
          disko.nixosModules.disko
          {
            disko.devices = {
              disk = {
                adoraos = {
                  type = "disk";
                  device = "${target}";
                  content = {
                    type = "gpt";
                    partitions = {
                      MBR = {
                        size = "1M";
                        type = "EF02";
                        priority = 1;
                      };
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
                      luks = {
                        size = "100%";
                        type = "luks";
                        # name = "disk-adoraos-luks";
                        content = {
                          type = "luks";
                          name = "crypted";
                          extraFormatArgs = [ "--type luks1" ];
                          # passwordFile = "/tmp/pss.txt";
                          settings = {
                            allowDiscards = true;
                          };
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
            };
          }
        ];
      };

    };
}
