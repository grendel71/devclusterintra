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

  networking.networkmanager.dhcp = "dhcpcd";

  sops.age.keyFile = "/etc/nixos/age.agekey";

}
