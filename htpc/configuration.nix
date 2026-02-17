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
  networking.firewall = {
    allowedTCPPorts = [ 8080 ];
    allowedUDPPorts = [ 8080 ];
  };
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
    pkgs.htop
    pkgs.btop
    pkgs.nfs-utils
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
  services.xserver.enable = true;
  services.xserver.desktopManager.kodi.enable = true;
  services.displayManager.autoLogin.user = "kodi";
  services.xserver.displayManager.lightdm.greeter.enable = false;
  services.xserver.displayManager.kodi.package = pkgs.kodi.withPackages (pkgs: with pkgs; [ jellyfin ]);

  # Define a user account
  users.extraUsers.kodi.isNormalUser = true;

  networking.hostName = "htpc";
  services.tailscale.enable = true;
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

  networking.wireless.enable  = true;

  networking.wireless.networks = {
    Stevens-IoT = {
      psk = "jZZ739FxJ8";
    };
  };
}
