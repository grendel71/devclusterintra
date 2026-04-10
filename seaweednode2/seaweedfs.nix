# Fully declarative SeaweedFS configuration using NixOS systemd services.
# This module configures a standalone SeaweedFS node running:
#   - weed master   (metadata / cluster coordination)
#   - weed volume   (blob storage)
#   - weed filer    (POSIX-like file namespace, optional S3 gateway)
#
# Tune the options below to match your deployment.

{ config, pkgs, lib, ... }:

let
  cfg = config.services.seaweedfs;
  seaweedPkg = pkgs.seaweedfs;

  # -----------------------------------------------------------------------
  # Tuneable defaults – override from configuration.nix via config merges
  # -----------------------------------------------------------------------
  masterPort   = 9333;
  masterGrpc   = 19333;
  volumePort   = 8080;
  volumeGrpc   = 18080;
  filerPort    = 8888;
  filerGrpc    = 18888;
  s3Port       = 8333;

  dataDir      = "/mnt/seaweedfs";
  masterDir    = "${dataDir}/master";
  volumeDir    = "${dataDir}/volume";
  filerDir     = "${dataDir}/filer";

  # Peer list for the master quorum (single-node: just self)
  masterPeers  = "localhost:${toString masterPort}";

in
{
  # ---------------------------------------------------------------------------
  # Options – expose simple knobs that configuration.nix can override
  # ---------------------------------------------------------------------------
  options.services.seaweedfs = {
    enable = lib.mkEnableOption "SeaweedFS distributed file system";

    dataDir = lib.mkOption {
      type        = lib.types.str;
      default     = dataDir;
      description = "Root directory for all SeaweedFS data.";
    };

    master = {
      port = lib.mkOption {
        type    = lib.types.port;
        default = masterPort;
        description = "HTTP port for the SeaweedFS master.";
      };
      grpcPort = lib.mkOption {
        type    = lib.types.port;
        default = masterGrpc;
        description = "gRPC port for the SeaweedFS master.";
      };
      peers = lib.mkOption {
        type    = lib.types.str;
        default = masterPeers;
        description = "Comma-separated list of master peers (for HA).";
      };
    };

    volume = {
      port = lib.mkOption {
        type    = lib.types.port;
        default = volumePort;
        description = "HTTP port for the SeaweedFS volume server.";
      };
      grpcPort = lib.mkOption {
        type    = lib.types.port;
        default = volumeGrpc;
        description = "gRPC port for the SeaweedFS volume server.";
      };
      maxVolumes = lib.mkOption {
        type    = lib.types.int;
        default = 7;
        description = "Max number of volumes per volume server.";
      };
    };

    filer = {
      enable = lib.mkOption {
        type    = lib.types.bool;
        default = true;
        description = "Whether to run the SeaweedFS filer.";
      };
      port = lib.mkOption {
        type    = lib.types.port;
        default = filerPort;
        description = "HTTP port for the SeaweedFS filer.";
      };
      grpcPort = lib.mkOption {
        type    = lib.types.port;
        default = filerGrpc;
        description = "gRPC port for the SeaweedFS filer.";
      };
    };

    s3 = {
      enable = lib.mkOption {
        type    = lib.types.bool;
        default = true;
        description = "Whether to expose an S3-compatible gateway via the filer.";
      };
      port = lib.mkOption {
        type    = lib.types.port;
        default = s3Port;
        description = "Port for the S3-compatible gateway.";
      };
    };
  };

  # ---------------------------------------------------------------------------
  # Implementation
  # ---------------------------------------------------------------------------
  config = lib.mkIf cfg.enable {

    # Ensure the binary is available on the PATH
    environment.systemPackages = [ seaweedPkg ];

    # Create data directories with correct ownership before services start
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir}       0750 seaweedfs seaweedfs -"
      "d ${cfg.dataDir}/master  0750 seaweedfs seaweedfs -"
      "d ${cfg.dataDir}/volume  0750 seaweedfs seaweedfs -"
      "d ${cfg.dataDir}/filer   0750 seaweedfs seaweedfs -"
    ];

    # Dedicated system user/group (no login shell, no home)
    users.users.seaweedfs = {
      isSystemUser = true;
      group        = "seaweedfs";
      description  = "SeaweedFS service user";
    };
    users.groups.seaweedfs = {};

    # ----- Master --------------------------------------------------------
    systemd.services.seaweedfs-master = {
      description = "SeaweedFS Master Server";
      after       = [ "network.target" ];
      wantedBy    = [ "multi-user.target" ];

      serviceConfig = {
        Type             = "simple";
        User             = "seaweedfs";
        Group            = "seaweedfs";
        Restart          = "on-failure";
        RestartSec       = "5s";
        ExecStart = lib.concatStringsSep " " [
          "${seaweedPkg}/bin/weed"
          "master"
          "-port=${toString cfg.master.port}"
          "-port.grpc=${toString cfg.master.grpcPort}"
          "-mdir=${cfg.dataDir}/master"
          "-peers=${cfg.master.peers}"
        ];
        # Hardening
        NoNewPrivileges  = true;
        PrivateTmp       = true;
        ProtectSystem    = "strict";
        ReadWritePaths   = [ cfg.dataDir ];
        ProtectHome      = true;
      };
    };

    # ----- Volume --------------------------------------------------------
    systemd.services.seaweedfs-volume = {
      description = "SeaweedFS Volume Server";
      after       = [ "network.target" "seaweedfs-master.service" ];
      wants       = [ "seaweedfs-master.service" ];
      wantedBy    = [ "multi-user.target" ];

      serviceConfig = {
        Type             = "simple";
        User             = "seaweedfs";
        Group            = "seaweedfs";
        Restart          = "on-failure";
        RestartSec       = "5s";
        ExecStart = lib.concatStringsSep " " [
          "${seaweedPkg}/bin/weed"
          "volume"
          "-port=${toString cfg.volume.port}"
          "-port.grpc=${toString cfg.volume.grpcPort}"
          "-dir=${cfg.dataDir}/volume"
          "-max=${toString cfg.volume.maxVolumes}"
          "-mserver=localhost:${toString cfg.master.port}"
        ];
        NoNewPrivileges  = true;
        PrivateTmp       = true;
        ProtectSystem    = "strict";
        ReadWritePaths   = [ cfg.dataDir ];
        ProtectHome      = true;
      };
    };

    # ----- Filer (optional) -----------------------------------------------
    systemd.services.seaweedfs-filer = lib.mkIf cfg.filer.enable {
      description = "SeaweedFS Filer";
      after       = [ "network.target" "seaweedfs-master.service" "seaweedfs-volume.service" ];
      wants       = [ "seaweedfs-master.service" "seaweedfs-volume.service" ];
      wantedBy    = [ "multi-user.target" ];

      serviceConfig = {
        Type             = "simple";
        User             = "seaweedfs";
        Group            = "seaweedfs";
        Restart          = "on-failure";
        RestartSec       = "5s";
        ExecStart = lib.concatStringsSep " " (
          [
            "${seaweedPkg}/bin/weed"
            "filer"
            "-port=${toString cfg.filer.port}"
            "-port.grpc=${toString cfg.filer.grpcPort}"
            "-master=localhost:${toString cfg.master.port}"
            "-dataCenter=dc1"
          ]
          ++ lib.optionals cfg.s3.enable [
            "-s3"
            "-s3.port=${toString cfg.s3.port}"
          ]
        );
        NoNewPrivileges  = true;
        PrivateTmp       = true;
        ProtectSystem    = "strict";
        ReadWritePaths   = [ cfg.dataDir ];
        ProtectHome      = true;
      };
    };

    # ----- Firewall -------------------------------------------------------
    networking.firewall.allowedTCPPorts = lib.flatten [
      cfg.master.port
      cfg.master.grpcPort
      cfg.volume.port
      cfg.volume.grpcPort
      (lib.optionals cfg.filer.enable [
        cfg.filer.port
        cfg.filer.grpcPort
      ])
      (lib.optionals (cfg.filer.enable && cfg.s3.enable) [
        cfg.s3.port
      ])
    ];
  };
}
