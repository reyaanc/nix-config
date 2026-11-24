# New Mac

Install git, Nix and Homebrew:

```sh
xcode-select --install
curl --proto '=https' --tlsv1.2 -sSf -L https://artifacts.nixos.org/nix-installer | sh -s -- install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Clone to exactly this path, since the config symlinks point here. On a work Mac, also clone the private `nix-work` next to it at `~/Personal/nix-work`.

```sh
git clone git@github.com:reyaanc/nix-config.git ~/Personal/nix-config
```

nix-darwin won't overwrite the installer's `nix.conf`, so move it:

```sh
sudo mv /etc/nix/nix.conf /etc/nix/nix.conf.before-nix-darwin
```

First switch. If it complains about other files in `/etc`, rename them the same way and run it again.

```sh
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake ~/Personal/nix-config#personal
```

Anything that needs work stuff switches from `nix-work` instead, which pulls in this repo and adds the work bits. That's `MacBook-Pro` for the work laptop and `home` for the home laptop:

```sh
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake ~/Personal/nix-work#home --override-input nix-config ~/Personal/nix-config
```

After that every machine has the same three commands, which already know their own flake and host:

- `rebuild` applies local changes
- `update` pulls `nix-config` and rebuilds
- `rollback` goes back one generation

## By hand

- Sign in to the App Store before switching
- Sign in to 1Password
- `chsh -s /run/current-system/sw/bin/fish`
- Give OmniWM Accessibility and Input Monitoring
- Set Vicinae's hotkey to ⌘Space
- set the wallpapers in `~/Pictures/wallpapers`.
