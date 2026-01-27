{
  disko.devices = {
    disk = {
      adoraos = {
        type = "disk";
        device = "/dev/nbd0";
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
              # name = "disk-adoraos-luks";
              content = {
                type = "luks";
                name = "crypted_adoraos";
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
