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
  networking.firewall.allowedTCPPorts = [
    11434
  ];

  environment.systemPackages = with pkgs; [
    git
    nmap
    screen
    tmux
  ];
}
