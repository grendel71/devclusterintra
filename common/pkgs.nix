{config, pkgs, ...}:
{
    environment.systemPackages = map lib.lowPrio [
        pkgs.curl
        pkgs.gitMinimal
        pkgs.htop
        pkgs.btop
        pkgs.nfs-utils
    ];
}