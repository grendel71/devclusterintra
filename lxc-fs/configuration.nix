{ config, modulesPath, pkgs, lib, ... }:
{
  imports = [ (modulesPath + "/virtualisation/proxmox-lxc.nix") ];
  nix.settings = { sandbox = false; };
  nixpkgs.config.allowUnfree = true;  
  proxmoxLXC = {
    manageNetwork = false;
    privileged = true;
  };
  security.pam.services.sshd.allowNullPassword = true;
  services.fstrim.enable = false; # Let Proxmox host handle fstrim
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
        PermitRootLogin = "yes";
        PasswordAuthentication = true;
        PermitEmptyPasswords = "yes";
    };
  };
  # Cache DNS lookups to improve performance
  services.resolved = {
    extraConfig = ''
      Cache=true
      CacheFromLocalhost=true
    '';
  };
  users.users.root.openssh.authorizedKeys.keys =
  [
    # change this to your ssh key
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFnx/ZGyG6ED/Pe1SUWEDeGhuAl5PV6thdet6Pu9p55z blau@blau-pc"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJi6qbHRgoul4fEhd1JE3/5Jo7v7pFmBwOLi2wE4QNk6 blau@Blau-S"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPDzqtLxq1uc1BW8qb3AGXARRgPT4WBvt7An4trkxS7X nixos@nixos"
  ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  environment.systemPackages = with pkgs; [
	  git
	  htop
    btop
    screenfetch
    neovim
  ];
  system.stateVersion = "25.05";

  networking.hostName = "lxc-fs";

  users.users.blau = {
    isNormalUser = true;
    uid = 101000;
    #gid = 101000;
    extraGroups = ["wheel" "networkmanager"];

  };

  users.users.nextcloud = {
    isNormalUser = true;
    uid = 1041;
    #gid = 101000;
    #extraGroups = ["wheel" "networkmanager"];

  };
  networking.firewall.allowedTCPPorts = [
    2049
  ];
  services.nfs.server = {
    enable = true;
    exports = ''
      /mnt/grendel *(rw,sync,no_subtree_check,insecure,no_root_squash)
      /mnt/torrents *(rw,sync,no_subtree_check,insecure,no_root_squash)
    '';
  };

  services.samba = {
  enable = true;
  securityType = "user";
  openFirewall = true;
  settings = {
    "private" = {
      "path" = "/mnt/grendel";
      "browseable" = "yes";
      "read only" = "no";
      "guest ok" = "no";
      "create mask" = "0644";
      "directory mask" = "0755";
      "force user" = "blau";
      "force group" = "users";
    };
  };
};

services.samba-wsdd = {
  enable = true;
  openFirewall = true;
};

networking.firewall.enable = true;
networking.firewall.allowPing = true;

  #system.autoUpgrade.flake = "github:grendel71/home-nix-infra";
  #system.autoUpgrade.enable = true;

}
