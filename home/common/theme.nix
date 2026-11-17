{ config, lib, ... }:
{
  options.theme = {
    name = lib.mkOption { type = lib.types.str; };
    font = {
      family = lib.mkOption { type = lib.types.str; };
      size = lib.mkOption { type = lib.types.int; };
    };
    colors = lib.mkOption { type = lib.types.attrsOf lib.types.str; };
    ansi = lib.mkOption { type = lib.types.listOf lib.types.str; };
    css = lib.mkOption {
      type = lib.types.lines;
      readOnly = true;
      default = ''
        :root {
          --theme-font: "${config.theme.font.family}";
        '' + lib.concatStrings (lib.mapAttrsToList (name: hex: "  --theme-${name}: #${hex};\n") config.theme.colors) + "}\n";
    };
  };

  config.theme = lib.mapAttrsRecursive (_: lib.mkDefault) {
    name = "Kanagawa Dragon";
    font = {
      family = "JetBrainsMono Nerd Font";
      size = 12;
    };
    colors = {
      bg = "181616";
      bgDark = "0d0c0c";
      bgHighlight = "282727";
      bgElevated = "201d1d";
      bgLight = "393836";
      fg = "c5c9c5";
      fgDim = "a6a69c";
      comment = "737c73";
      border = "625e5a";
      red = "c4746e";
      orange = "b6927b";
      yellow = "c4b28a";
      green = "8a9a7b";
      aqua = "8ea4a2";
      blue = "8ba4b0";
      violet = "8992a7";
      pink = "a292a3";
    };
    ansi = with config.theme.colors; [
      bgDark red green yellow blue pink aqua "c8c093"
      fgDim "e46876" "87a987" "e6c384" "7fb4ca" "938aa9" "7aa89f" fg
    ];
  };
}
