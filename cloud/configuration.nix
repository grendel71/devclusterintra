{ config, pkgs, ... }: {
  system.stateVersion = "25.05";

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  services.cloud-init.enable = true;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
  };

  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIfsl37+JcWrenYNk12EMKzFWTqBQC9i2j6OlGF20W/5 blau@blau-pc"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH+gzK8xwCY7/YsF1TeJjMrjwCjNjzRUTHB5ILNIqCL1 blau@blau-laptop"

    ];
  };

  security.sudo.wheelNeedsPassword = false;
}