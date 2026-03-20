{
  modulesPath,
  lib,
  pkgs,
  config,
  ...
} @ args:
{
  imports = [
    ./disk-config.nix
  ];
  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  system.stateVersion = "25.11";

  networking.hostName = "workerNode3";

  #networking.networkmanager.dhcp = "dhcpcd";

  sops.age.keyFile = "/etc/nixos/age.agekey";

  services.logind.lidSwitchExternalPower = "ignore";

  networking = {
        interfaces = {
        enp0s31f6.ipv4.addresses = [{
            address = "192.168.1.243";
            prefixLength = 24;
        }];
    
        };
        defaultGateway = {
            address = "192.168.1.1";
            interface = "enp0s31f6";
        };
  };
}
