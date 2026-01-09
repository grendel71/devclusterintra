{ config, modulesPath, pkgs, lib, ... }:
{
  services.caddy = {
    enable = true;
    package = pkgs.caddy.withPlugins {
      plugins = ["github.com/caddy-dns/cloudflare@v0.2.2"];
      hash = ["sha256-ea8PC/+SlPRdEVVF/I3c1CBprlVp1nrumKM5cMwJJ3U="];
    };
    globalConfig = ''
  	servers {
		listener_wrappers {
			proxy_protocol {
				timeout 2s
				allow 10.66.66.1/24
			}
			tls
		}
	}
    '';
    extraConfig = ''
# To use your own domain name (with automatic HTTPS), first make
# sure your domain's A/AAAA DNS records are properly pointed to
# this machine's public IP, then replace "example.com" below with your
# domain name.


(blau-whitelist) {
	@blocked_ips not remote_ip 192.168.1.0/24
	
	handle @blocked_ips {
		respond "Lol Nigga" 
	}
}


(default-headers) {
        header {
                -frameDeny
                -sslRedirect
                -browserXssFilter
                -contentTypeNosniff
                -forceSTSHeader
                -stsIncludeSubdomains
                -stsPreload
                -stsSeconds 15552000
                -customFrameOptionsValue SAMEORIGIN
                -customRequestHeaders X-Forwarded-Proto https
        }
}

(authentik) {
    reverse_proxy /outpost.goauthentik.io/* https://ak.grendel71.net {
	header_up Host {http.reverse_proxy.upstream.host}
    }
    forward_auth http://xiangct.home.arpa:9000 {
        uri /outpost.goauthentik.io/auth/caddy

        copy_headers X-Authentik-Username X-Authentik-Groups X-Authentik-Entitlements X-Authentik-Email X-Authentik-Name X-Authentik-Uid X-Authentik-Jwt X-Authentik-Meta-Jwks X-Authentik-Meta-Outpost X-Authentik-Meta-Provider X-Authentik-Meta-App X-Authentik-Meta-Version
    }
    
}

jaidenpapp.com {
        tls {
                dns cloudflare {env.CLOUDFLARE_API_TOKEN}
                resolvers 1.1.1.1
        }
	log {
		level INFO
		output file /var/log/caddy/access.log
	}

	reverse_proxy webserver.home.arpa:8080
}

*.grendel71.net {
	import default-headers
	tls {
		dns cloudflare {env.CLOUDFLARE_API_TOKEN}
		resolvers 1.1.1.1
	}
	log {
		level INFO
		output file /var/log/caddy/access.log
	}

	@jellyfin host jellyfin.grendel71.net
	handle @jellyfin {
		
		reverse_proxy jellyfin.home.arpa:8096
	}
	
	@authentik host ak.grendel71.net
	handle @authentik {
		reverse_proxy xiangct.home.arpa:9000
	}

	@owncloud host oc.grendel71.net
	handle @owncloud {
		redir /.well-known/carddav /remote.php/dav/ 301
    		redir /.well-known/caldav /remote.php/dav/ 301
		reverse_proxy https://nextcloud.home.arpa:443 {
		transport http {
            		tls_insecure_skip_verify
        	}
	  }
	}

	@komga host ma.grendel71.net
	handle @komga {
		reverse_proxy http://xiangct.home.arpa:25600
	}	
	@immich host photos.grendel71.net
	handle @immich {
		reverse_proxy http:/192.168.1.30:2283
	}	
	@securelog host securelog.grendel71.net
	handle @securelog {
		reverse_proxy http://xiangct.home.arpa:3000
		reverse_proxy /api/* http://xiangct.home.arpa:8067
	}
	@seafile host seafile.grendel71.net
	handle @seafile {
		reverse_proxy http://seafile:80
	}

}


*.local.grendel71.net {
	import blau-whitelist
	tls {
		dns cloudflare {env.CLOUDFLARE_API_TOKEN}
		resolvers 1.1.1.1
	}
	log {
		level INFO
		output file /var/log/caddy/access.log
	}

	@pve host pve.local.grendel71.net
	handle @pve {
		reverse_proxy https://192.168.1.156:8006 {
			transport http {
				tls_insecure_skip_verify
			}
		}
	}
	@khoj host khoj.local.grendel71.net
	handle @khoj {
		reverse_proxy http://xianggpu.home.arpa:42110
	}
	@cockpit host cockpit.local.grendel71.net
	handle @cockpit {
		reverse_proxy https://ZhangFs.home.arpa:9090 {
			transport http {
				tls_insecure_skip_verify
			}
		}
	}

	@couchdb host couchdb.local.grendel71.net
	handle @couchdb {
		reverse_proxy http://192.168.1.173:5984
	}

	@dns host dns.local.grendel71.net
	handle @dns {
		reverse_proxy http://192.168.1.50:5380
	}

	@papp host papp.local.grendel71.net
	handle @papp {
		reverse_proxy http://webserver.home.arpa:8080
	}

	@prowlarr host prowlarr.local.grendel71.net
	handle @prowlarr {
		reverse_proxy http://seedbox.home.arpa:9696
	}

	@qb host qb.local.grendel71.net
	handle @qb {
		reverse_proxy http://seedbox.home.arpa:8888
	}

	@radarr host radarr.local.grendel71.net
	handle @radarr {
		reverse_proxy http://seedbox.home.arpa:7878

	}

	@sonarr host sonarr.local.grendel71.net
	handle @sonarr {
		import authentik
		reverse_proxy http://seedbox.home.arpa:8989
		
	}

	@vaultwarden host v.local.grendel71.net
	handle @vaultwarden {
		reverse_proxy http://xiangct.home.arpa:9445
	}

	@portainer host pt.local.grendel71.net
	handle @portainer {
		reverse_proxy https://xiangct.home.arpa:9444 {
			transport http {
				tls_insecure_skip_verify	
			}
		}

	}
	@mail host mail.local.grendel71.net
	handle @mail {
		reverse_proxy http://mailcow.home.arpa
	}
	@linksys host linksys.local.grendel71.net
	handle @linksys {
		reverse_proxy http://10.45.218.239
	}
	@syncthing host syncthing.local.grendel71.net
	handle @syncthing {
		reverse_proxy http://zhangfs.home.arpa:8384
	}
	@gitea host gitea.local.grendel71.net
	handle @gitea {
		reverse_proxy http://192.168.1.50:3000
	}
}

    '';
  };
  systemd.services.caddy.serviceConfig = {
    EnvironmentFile = "/etc/caddy/cloudflare.env";
  };
}
