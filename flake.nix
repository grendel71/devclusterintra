{
  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=25.11";
  inputs.disko.url = "github:nix-community/disko";
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
  inputs.comin.url = "github:nlewo/comin";
  inputs.comin.inputs.nixpkgs.follows = "nixpkgs";
  inputs.sops-nix.url = "github:Mic92/sops-nix";
  inputs.sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  outputs =
    {
      nixpkgs,
      disko,
      nixos-facter-modules,
      comin,
      sops-nix,
      ...
    }:
    {
      nixosConfigurations.hetzner-cloud = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          ./configuration.nix
        ];
      };
      # tested with 2GB/2CPU droplet, 1GB droplets do not have enough RAM for kexec
      nixosConfigurations.digitalocean = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./digitalocean.nix
          disko.nixosModules.disko
          { disko.devices.disk.disk1.device = "/dev/vda"; }
          ./configuration.nix
        ];
      };
      nixosConfigurations.hetzner-cloud-aarch64 = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          disko.nixosModules.disko
          ./configuration.nix
        ];
      };

      # Use this for all other targets
      # nixos-anywhere --flake .#generic --generate-hardware-config nixos-generate-config ./hardware-configuration.nix <hostname>
      nixosConfigurations.generic = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          ./configuration.nix
          ./hardware-configuration.nix
        ];
      };
      nixosConfigurations.onode1 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          ./onode1/configuration.nix
          ./onode1/hardware-configuration.nix
        ];
      };
      nixosConfigurations.controlNode = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          sops-nix.nixosModules.sops
          ./controlnode/configuration.nix
          ./controlnode/hardware-configuration.nix
          comin.nixosModules.comin
          ({...}: {
            services.comin = {
              enable = true;
              hostname = "controlNode";
              remotes = [{
                name = "origin";
                url = "https://gitea.local.grendel71.net/grendel71/devclusterintranix.git";
                branches.main.name = "main";
              }];
            };
          })
        ];
      };
      nixosConfigurations.node1 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          sops-nix.nixosModules.sops
          ./node1/configuration.nix
          ./node1/hardware-configuration.nix
          comin.nixosModules.comin
          ({...}: {
            services.comin = {
              enable = true;
              hostname = "node1";
              remotes = [{
                name = "origin";
                url = "https://gitea.local.grendel71.net/grendel71/devclusterintranix.git";
                branches.main.name = "main";
              }];
            };
          })
        ];
      };
      nixosConfigurations.node2 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          sops-nix.nixosModules.sops
          ./node2/configuration.nix
          ./node2/hardware-configuration.nix
          comin.nixosModules.comin
          ({...}: {
            services.comin = {
              enable = true;
              hostname = "node2";
              remotes = [{
                name = "origin";
                url = "https://gitea.local.grendel71.net/grendel71/devclusterintranix.git";
                branches.main.name = "main";
              }];
            };
          })
        ];
      };
      nixosConfigurations.gpunode1 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          sops-nix.nixosModules.sops
          ./gpunode1/configuration.nix
          ./gpunode1/hardware-configuration.nix
          comin.nixosModules.comin
          ({...}: {
            services.comin = {
              enable = true;
              hostname = "gpunode1";
              remotes = [{
                name = "origin";
                url = "https://gitea.local.grendel71.net/grendel71/devclusterintranix.git";
                branches.main.name = "main";
              }];
            };
          })
        ];
      };
      nixosConfigurations.storageBackend = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          ./storageBackend/configuration.nix
          ./storageBackend/hardware-configuration.nix
          comin.nixosModules.comin
          ({...}: {
            services.comin = {
              enable = true;
              hostname = "storageBackend";
              remotes = [{
                name = "origin";
                url = "https://gitea.local.grendel71.net/grendel71/devclusterintranix.git";
                branches.main.name = "main";
              }];
            };
          })
        ];
      };
      nixosConfigurations.seaweednode1 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          ./seaweednode1/configuration.nix
          ./seaweednode1/hardware-configuration.nix
          comin.nixosModules.comin
          ({...}: {
            services.comin = {
              enable = true;
              hostname = "seaweednode1";
              remotes = [{
                name = "origin";
                url = "https://gitea.local.grendel71.net/grendel71/devclusterintranix.git";
                branches.main.name = "main";
              }];
            };
          })
        ];
      };
      nixosConfigurations.htpc = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          ./htpc/configuration.nix
          ./htpc/hardware-configuration.nix
          comin.nixosModules.comin
          ({...}: {
            services.comin = {
              enable = true;
              hostname = "htpc";
              remotes = [{
                name = "origin";
                url = "https://gitea.local.grendel71.net/grendel71/devclusterintranix.git";
                branches.main.name = "main";
              }];
            };
          })
        ];
      };

      nixosConfigurations.lxc-fs = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          ./lxc-fs/configuration.nix
          comin.nixosModules.comin
          ({...}: {
            services.comin = {
              enable = true;
              hostname = "lxc-fs";
              remotes = [{
                name = "origin";
                url = "https://gitea.local.grendel71.net/grendel71/devclusterintranix.git";
                branches.main.name = "main";
              }];
            };
          })
        ];
      };
      # Slightly experimental: Like generic, but with nixos-facter (https://github.com/numtide/nixos-facter)
      # nixos-anywhere --flake .#generic-nixos-facter --generate-hardware-config nixos-facter facter.json <hostname>
      nixosConfigurations.generic-nixos-facter = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          ./configuration.nix
          nixos-facter-modules.nixosModules.facter
          {
            config.facter.reportPath =
              if builtins.pathExists ./facter.json then
                ./facter.json
              else
                throw "Have you forgotten to run nixos-anywhere with `--generate-hardware-config nixos-facter ./facter.json`?";
          }
        ];
      };
    };
}
