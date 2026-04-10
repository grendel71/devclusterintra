{
  modulesPath,
  lib,
  pkgs,
  config,
  ...
} @ args:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
    ./seaweedfs.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
    pkgs.htop
    pkgs.btop
  ];
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  system.stateVersion = "25.11";

  networking.hostName = "seaweednode2";

  networking = {
    interfaces = {
      ens18.ipv4.addresses = [{
        address = "192.168.1.89";  # Update to your actual IP
        prefixLength = 24;
      }];
    };
    defaultGateway = {
      address = "192.168.1.1";
      interface = "ens18";
    };
  };

  networking.nameservers = [ "1.1.1.1" ];

  # -------------------------------------------------------------------------
  # SeaweedFS – fully declarative via the services.seaweedfs module
  # -------------------------------------------------------------------------
  services.seaweedfs = {
    enable = true;

    # All SeaweedFS data lives on the secondary disk mounted at /mnt
    dataDir = "/mnt/seaweedfs";

    master = {
      port     = 9333;
      grpcPort = 19333;
      # For a single-node cluster, peers points only to self.
      # For an HA cluster, add the other master IPs here:
      #   peers = "192.168.1.89:9333,192.168.1.90:9333,192.168.1.91:9333";
      peers = "localhost:9333";
    };

    volume = {
      port       = 8080;
      grpcPort   = 18080;
      maxVolumes = 7;   # increase if you add more disks / need more volumes
    };

    filer = {
      enable   = true;
      port     = 8888;
      grpcPort = 18888;
    };

    s3 = {
      enable = true;
      port   = 8333;
    };
  };

  # Secondary data disk (adjust device path to match hardware)
  fileSystems."/mnt" = {
    device  = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi1-part1";
    fsType  = "ext4";
    options = [
      "users"  # allow any user to mount/unmount
      "nofail" # don't halt boot if the disk is missing
    ];
  };
}
