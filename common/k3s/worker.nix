{config, inputs, pkgs, ...}:
{
    networking.firewall.allowedTCPPorts = [
        6443 # k3s: required so that pods can reach the API server (running on port 6443 by default)
        2379 # k3s, etcd clients: required if using a "High Availability Embedded etcd" configuration
        2380 # k3s, etcd peers: required if using a "High Availability Embedded etcd" configuration
    ];
    networking.firewall.allowedUDPPorts = [
        8472 # k3s, flannel: required if using multi-node for inter-node networking
    ];
    sops.secrets.k3s_token.sopsFile = ../secrets/secrets.yaml;

    services.k3s = {
        enable = true;
        role = "agent";
        tokenFile = config.sops.secrets.k3s_token.path;
        serverAddr = "https://192.168.1.100:6443";
    };

    services.openiscsi = {
        enable = true;
        name = "${config.networking.hostName}-initiatorhost";
    };
    systemd.services.iscsid.serviceConfig = {
        PrivateMounts = "yes";
        BindPaths = "/run/current-system/sw/bin:/bin";
    };
}