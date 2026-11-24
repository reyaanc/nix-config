{ config, lib, ... }:
let
  channel = hex: offset: lib.fromHexString (builtins.substring offset 2 hex) / 255.0;
  rgba = hex: alpha: {
    red = channel hex 0;
    green = channel hex 2;
    blue = channel hex 4;
    inherit alpha;
  };
in
{
  programs.omniwm = {
    enable = true;
    settings = lib.recursiveUpdate (lib.importTOML ../../config/omniwm/settings.toml) {
      borders.color = rgba config.theme.colors.blue 0.7;
    };
  };
}
