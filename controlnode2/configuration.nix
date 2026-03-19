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

  system.stateVersion = "25.11";

  #networking = {
  #  interfaces = {
  #    ens18.ipv4.addresses = [{
  #      address = "192.168.1.185";
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

}
