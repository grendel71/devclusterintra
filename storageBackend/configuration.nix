{
  modulesPath,
  lib,
  pkgs,
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
  ];
  users.users.root.openssh.authorizedKeys.keys =
  [
    # change this to your ssh key
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFnx/ZGyG6ED/Pe1SUWEDeGhuAl5PV6thdet6Pu9p55z blau@blau-pc"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJi6qbHRgoul4fEhd1JE3/5Jo7v7pFmBwOLi2wE4QNk6 blau@Blau-S"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPDzqtLxq1uc1BW8qb3AGXARRgPT4WBvt7An4trkxS7X nixos@nixos"
  ] ++ (args.extraPublicKeys or []); # this is used for unit-testing this module and can be removed if not needed

  system.stateVersion = "25.11";

  networking.hostName = "storageBackend";

  networking = {
    interfaces = {
      ens18.ipv4.addresses = [{
        address = "192.168.1.160";
        prefixLength = 24;
      }];
  
    };
    defaultGateway = {
        address = "192.168.1.1";
        interface = "ens18";
    };
  };


  networking.networkmanager.dhcp = "dhcpcd";

  networking.nameservers = [ "192.168.1.1" ];
  networking.firewall.allowedTCPPorts = [
    2049
  ];
  services.nfs.server = {
    enable = true;
    exports = ''
      /home/blau/nextcloud-data *(rw,sync,no_subtree_check,insecure,no_root_squash)
      /home/blau/nextcloud-db *(rw,sync,no_subtree_check,insecure,no_root_squash)
    '';
  };
 users.users.blau = {
    isNormalUser = true;
    description = "blau";
    extraGroups = [ "networkmanager" "wheel"];
    #hashedPasswordFile = config.sops.secrets.dade_passwd.path;
    packages = with pkgs; [
    #  thunderbird
    ];
    #shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFnx/ZGyG6ED/Pe1SUWEDeGhuAl5PV6thdet6Pu9p55z blau@blau-pc"
    ];
  };
}
