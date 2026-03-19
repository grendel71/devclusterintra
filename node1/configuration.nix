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

  networking.nameservers = [ "1.1.1.1" ]; 

}
