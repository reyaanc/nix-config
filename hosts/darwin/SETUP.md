# New Mac

Install git, Nix and Homebrew:

```sh
xcode-select --install
curl --proto '=https' --tlsv1.2 -sSf -L https://artifacts.nixos.org/nix-installer | sh -s -- install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Clone to exactly this path, since the config symlinks point here. On a work Mac, clone `nix-work` next to it at `~/Personal/nix-work`.

```sh
git clone git@github.com:reyaanc/nix-config.git ~/Personal/nix-config
```

nix-darwin won't overwrite the installer's `nix.conf`, so move it:

```sh
sudo mv /etc/nix/nix.conf /etc/nix/nix.conf.before-nix-darwin
```

First switch. If it complains about other files in `/etc`, rename them the same way and run it again.

```sh
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake ~/Personal/nix-config#MacBook-Pro
```

After that it's just `sudo darwin-rebuild switch --flake ~/Personal/nix-config`.

## By hand

- Sign in to the App Store before switching, or the App Store apps fail to install.
- Sign in to 1Password, which signs git commits.
- Work Mac: get `/etc/netrc` and the CA bundle from IT for the Hydra cache.
- `chsh -s /run/current-system/sw/bin/fish`, then log out and back in.
- Give OmniWM Accessibility and Input Monitoring.
- Set Vicinae's hotkey to ⌘Space.
- Copy the wallpapers into `~/Pictures/wallpapers`.
