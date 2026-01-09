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
    ./caddy.nix
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
  ];

  users.users.root.openssh.authorizedKeys.keys =
  [
    # change this to your ssh key
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFnx/ZGyG6ED/Pe1SUWEDeGhuAl5PV6thdet6Pu9p55z blau@blau-pc"
  ] ++ (args.extraPublicKeys or []); # this is used for unit-testing this module and can be removed if not needed

  system.stateVersion = "25.11";

  services.technitium-dns-server = {
    enable = true;
    openFirewall = true;
    firewallUDPPorts = [
      67
      68
      53
    ];
    firewallTCPPorts = [
      53
      5380

    ];
  };
  systemd.services.technitium-dns-server.serviceConfig = {
        WorkingDirectory = lib.mkForce null;
        BindPaths = lib.mkForce null;
  };
 

  services.gitea = {
    enable = true;
    #openFirewall = true;
    settings.server.ROOT_URL = "https://gitea.local.grendel71.net";
  };
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 3000 80 443 ];

  };
  networking.hostName = "orchestrator-node-67";

  networking = {
    interfaces = {
      ens18.ipv4.addresses = [{
        address = "192.168.1.50";
        prefixLength = 24;
      }];

    };
    defaultGateway = {
        address = "192.168.1.1";
        interface = "ens18";
    };
  };
}
