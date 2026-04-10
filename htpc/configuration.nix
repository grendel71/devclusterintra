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
  hardware.graphics = {
	enable = true;
	extraPackages = with pkgs; [
		intel-media-driver
		vpl-gpu-rt
		intel-compute-runtime
	];
 };
 environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";     # Prefer the modern iHD backend
    # VDPAU_DRIVER = "va_gl";      # Only if using libvdpau-va-gl
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
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH+gzK8xwCY7/YsF1TeJjMrjwCjNjzRUTHB5ILNIqCL1 blau@blau-laptop"
  ] ++ (args.extraPublicKeys or []); # this is used for unit-testing this module and can be removed if not needed

  system.stateVersion = "25.11";
  services.xserver.enable = true;
  services.xserver.desktopManager.kodi.enable = true;
  services.displayManager.autoLogin.user = "kodi";
  services.xserver.displayManager.lightdm.greeter.enable = false;
  services.xserver.desktopManager.kodi.package = pkgs.kodi.withPackages (pkgs: with pkgs; [ jellyfin youtube netflix invidious ]);

  # Define a user account
  users.extraUsers.kodi.isNormalUser = true;
  users.users.kodi.openssh.authorizedKeys.keys = 
  [
	"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH+gzK8xwCY7/YsF1TeJjMrjwCjNjzRUTHB5ILNIqCL1 blau@blau-laptop"
  ];
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
  sops.secrets.wifi_psk.sopsFile = ../secrets/secrets.yaml;

  networking.wireless.networks = {
    Stevens-IoT = {
      psk = config.sops.secrets.wifi_psk.path;
    };
  };

  
}
