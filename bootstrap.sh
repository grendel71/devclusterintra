echo "Enter node ip"
read ip
echo "enter nixos config path"
read path
echo "enter nixos configuration"
read config

mkdir -p /tmp/extra-files/etc/nixos
cp ./age.agekey /tmp/extra-files/etc/nixos/age.agekey
chmod 600 /tmp/extra-files/etc/nixos/age.agekey

nix run github:nix-community/nixos-anywhere -- --flake .#$config --extra-files /tmp/extra-files --generate-hardware-config nixos-generate-config $path/hardware-configuration.nix $ip

rm -rf /tmp/extra-files
