{ config, lib, pkgs, ... }:
let
  cfg = config.rebuild;
  checkout = "${config.home.homeDirectory}/Personal/nix-config";
  nh = if pkgs.stdenv.hostPlatform.isDarwin then "nh darwin" else "nh os";
  overrides = lib.concatStrings (lib.mapAttrsToList (input: path: " --override-input ${input} ${path}") cfg.overrides);
in
{
  options.rebuild = {
    flake = lib.mkOption {
      type = lib.types.str;
      default = checkout;
    };
    host = lib.mkOption { type = lib.types.str; };
    overrides = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
    };
    updateInputs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
  };

  config = {
    programs.nh = {
      enable = true;
      inherit (cfg) flake;
    };

    programs.fish.functions = {
      rebuild = "${nh} switch ${cfg.flake} -H ${cfg.host} $argv --${overrides}";
      rollback =
        if pkgs.stdenv.hostPlatform.isDarwin then "sudo darwin-rebuild --rollback" else "sudo nixos-rebuild switch --rollback";
      update = ''
        git -C ${checkout} pull --ff-only
        or return
      '' + lib.optionalString (cfg.updateInputs != [ ]) ''
        nix flake update ${lib.concatStringsSep " " cfg.updateInputs} --flake ${cfg.flake}
        or return
      '' + ''
        rebuild $argv
      '';
    };
  };
}
