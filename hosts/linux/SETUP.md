# New Linux box

Install NixOS from the ISO as normal, then boot into it and log in as root.

Clone to exactly this path, since the config symlinks point here:

```sh
nix-shell -p git
git clone https://github.com/reyaanc/nix-config.git /home/reyaan/Personal/nix-config
```

The installer generated a hardware config for this machine. Copy it in and `git add` it, because flakes ignore untracked files:

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

- The config doesn't set a password for `reyaan`, so run `passwd reyaan` before you log out of root.
- `chown -R reyaan /home/reyaan/Personal` so the clone isn't owned by root.
- Hyprland starts with its default config, so bind Vicinae (`vicinae toggle`) to a key yourself.
