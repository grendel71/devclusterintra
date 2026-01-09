echo "Enter node ip"
read ip
echo "enter nixos config path"
read path
echo "enter nixos configuration"
read config
nix run github:nix-community/nixos-anywhere -- --flake .#$config --generate-hardware-config nixos-generate-config $path/hardware-configuration.nix $ip
