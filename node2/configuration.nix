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

  system.stateVersion = "25.11";

  networking.hostName = "workerNode2";

  networking = {
    interfaces = {
      ens18.ipv4.addresses = [{
        address = "192.168.1.252";
        prefixLength = 24;
      }];
  
    };
    defaultGateway = {
        address = "192.168.1.1";
        interface = "ens18";
    };
  };


  #networking.networkmanager.dhcp = "dhcpcd";

}
