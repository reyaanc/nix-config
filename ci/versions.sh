#!/usr/bin/env bash
set -euo pipefail

cp ci/hardware-configuration.nix hosts/linux/personal/
trap 'rm hosts/linux/personal/hardware-configuration.nix' EXIT

apply='c: let
  packages = c.config.environment.systemPackages ++ c.config.home-manager.users.reyaan.home.packages;
  entry = p: let d = builtins.parseDrvName p.name; in { name = p.pname or d.name; value = p.version or d.version; };
in builtins.listToAttrs (map entry packages)'

darwin=$(nix eval --json "path:$PWD#darwinConfigurations.personal" --apply "$apply")
linux=$(nix eval --json "path:$PWD#nixosConfigurations.linux" --apply "$apply")
jq -n --argjson a "$darwin" --argjson b "$linux" '$a + $b'
