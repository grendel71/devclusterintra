{config, pkgs, ...}:
{
    environment.systemPackages = with pkgs; [
        curl
        gitMinimal
        htop
        btop
        nfs-utils
    ];
}