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
  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
        PermitRootLogin = "yes";
        PasswordAuthentication = true;
        PermitEmptyPasswords = "yes";
    };
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
    pkgs.htop
    pkgs.btop
    pkgs.nfs-utils
    pkgs.seaweedfs
    
  ];
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  users.users.root.openssh.authorizedKeys.keys =
  [
    # change this to your ssh key
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFnx/ZGyG6ED/Pe1SUWEDeGhuAl5PV6thdet6Pu9p55z blau@blau-pc"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJi6qbHRgoul4fEhd1JE3/5Jo7v7pFmBwOLi2wE4QNk6 blau@Blau-S"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPDzqtLxq1uc1BW8qb3AGXARRgPT4WBvt7An4trkxS7X nixos@nixos"
  ] ++ (args.extraPublicKeys or []); # this is used for unit-testing this module and can be removed if not needed

  system.stateVersion = "25.11";

  networking.hostName = "workerNode1";

  #networking = {
  #  interfaces = {
  #    ens18.ipv4.addresses = [{
  #      address = "192.168.1.180";
  #      prefixLength = 24;
  #    }];
  #
  #  };
  #  defaultGateway = {
  #      address = "192.168.1.1";
  #      interface = "ens18";
  #  };
  #};


  networking.networkmanager.dhcp = "dhcpcd";

  #networking.nameservers = [ "192.168.1.50" ];
  networking.firewall.allowedTCPPorts = [
    6443 # k3s: required so that pods can reach the API server (running on port 6443 by default)
    2379 # k3s, etcd clients: required if using a "High Availability Embedded etcd" configuration
    2380 # k3s, etcd peers: required if using a "High Availability Embedded etcd" configuration
  ];
  networking.firewall.allowedUDPPorts = [
    8472 # k3s, flannel: required if using multi-node for inter-node networking
  ];
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.secrets.k3s_token.sopsFile = ../secrets/secrets.yaml;

  services.k3s = {
    enable = true;
    role = "agent";
    tokenFile = config.sops.secrets.k3s_token.path;
    serverAddr = "https://192.168.1.179:6443";
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
