# New Linux box

```sh
nix-shell -p git
git clone https://github.com/reyaanc/nix-config.git /home/reyaan/Personal/nix-config
```

Copy generated hardware configuration in and `git add` it, because flakes ignore untracked files:

```sh
cd /home/reyaan/Personal/nix-config
cp /etc/nixos/hardware-configuration.nix hosts/linux/personal/
git add hosts/linux/personal/hardware-configuration.nix
```

The host is called `linux` for now. Rename `networking.hostName` in `personal/default.nix` and `nixosConfigurations.linux` in `flake.nix` to the real hostname if you want, then switch:

```sh
nixos-rebuild switch --flake .#linux
```

After that it's just `sudo nixos-rebuild switch --flake ~/Personal/nix-config`.

## By hand

- run `passwd reyaan` before logging out 
- `chown -R reyaan /home/reyaan/Personal`
