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

  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  system.stateVersion = "25.11";

  networking.hostName = "controlNode";

  networking = {
    interfaces = {
      ens18.ipv4.addresses = [{
        address = "192.168.1.179";
        prefixLength = 24;
      }];
  
    };
    defaultGateway = {
        address = "192.168.1.1";
        interface = "ens18";
    };
  };

  #networking.networkmanager.dhcp = "dhcpcd";

  networking.firewall.allowedTCPPorts = [
    6443 # k3s: required so that pods can reach the API server (running on port 6443 by default)
    2379 # k3s, etcd clients: required if using a "High Availability Embedded etcd" configuration
    2380 # k3s, etcd peers: required if using a "High Availability Embedded etcd" configuration
  ];
  networking.firewall.allowedUDPPorts = [
    8472 # k3s, flannel: required if using multi-node for inter-node networking
  ];

  sops.secrets.k3s_token.sopsFile = ../secrets/secrets.yaml;

  services.k3s = {
    enable = true;
    role = "server";
    tokenFile = config.sops.secrets.k3s_token.path;
    clusterInit = true;
    extraFlags = toString [
      "--disable servicelb"
      "--disable traefik"
      "--tls-san 192.168.1.100"
    ];
  };
  

  services.openiscsi = {
    enable = true;
    name = "${config.networking.hostName}-initiatorhost";
  };
  systemd.services.iscsid.serviceConfig = {
    PrivateMounts = "yes";
    BindPaths = "/run/current-system/sw/bin:/bin";
  };
}
