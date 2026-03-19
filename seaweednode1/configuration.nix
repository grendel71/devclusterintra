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
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
    pkgs.htop
    pkgs.btop
    pkgs.nfs-utils
    pkgs.nvidia-container-toolkit
    pkgs.seaweedfs
  ];
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  system.stateVersion = "25.11";

  networking.hostName = "seaweednode1";

  networking = {
    interfaces = {
      ens18.ipv4.addresses = [{
        address = "192.168.1.88";
        prefixLength = 24;
      }];
  
    };
    defaultGateway = {
        address = "192.168.1.1";
        interface = "ens18";
    };
  };


  #networking.networkmanager.dhcp = "dhcpcd";

  networking.nameservers = [ "1.1.1.1" ];
  networking.firewall.allowedTCPPorts = [
    6443 # k3s: required so that pods can reach the API server (running on port 6443 by default)
    2379 # k3s, etcd clients: required if using a "High Availability Embedded etcd" configuration
    2380 # k3s, etcd peers: required if using a "High Availability Embedded etcd" configuration
    8443
    9333
    8080
  ];
  networking.firewall.allowedUDPPorts = [
    8472 # k3s, flannel: required if using multi-node for inter-node networking
  ];

  nixpkgs.config.allowUnfree = true;
  #nixpkgs.config.cudaSupport = false;

  virtualisation.docker.enable = true;


}
