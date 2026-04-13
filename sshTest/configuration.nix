{
  modulesPath,
  lib,
  pkgs,
  config,
  ...
}@args:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
  ];

  system.stateVersion = "25.11";
  users.users.blau2 = {
    isNormalUser = true;
    home = "/home/blau2";
    description = "Alice Foobar";
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINgBdHzvVPr15wesz8sK2nqCapxTW2202oYAroxjDWQd campus\blau2@HFSL-HANLON-29"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB4wotcCd7CA3sMlP60BzFZDNTBl/6vZMrHxCh8BUvvQ campus\blau2@LIBPUB03"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIfsl37+JcWrenYNk12EMKzFWTqBQC9i2j6OlGF20W/5 blau@blau-pc"

    ];
  };

  users.users.hajin = {
    isNormalUser = true;
    home = "/home/hajin";
    description = "Hajin lim";
    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID0fQldW2bHZphOxdLX+qQgLmvGHX3yTx/JbpiW7RUc0 zero734kr@gmail.com"
    ];
  };

  services.openssh.settings.GatewayPorts = "yes";
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

  #networking.networkmanager.dhcp = "dhcpcd";

  environment.systemPackages = with pkgs; [
    git
    htop
    btop
  ];

  virtualisation.docker = {
    enable = true;
  };

  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      PermitEmptyPasswords = "yes";
    };
  };
}
