{ config, lib, ... }:
let
  c = config.theme.colors;
in
{
  programs.fzf = {
    enable = true;
    colors = lib.mapAttrsRecursive (_: lib.mkDefault) {
      fg = "#${c.fg}";
      "bg+" = "#${c.bgHighlight}";
      gutter = "-1";
      hl = "#${c.blue}";
      "hl+" = "#${c.blue}";
      info = "#${c.comment}";
      prompt = "#${c.blue}";
      pointer = "#${c.red}";
      marker = "#${c.red}";
      spinner = "#${c.red}";
      header = "#${c.yellow}";
      separator = "#${c.yellow}";
      border = "#${c.border}";
      scrollbar = "#${c.border}";
      query = "#${c.fg}:regular";
    };
  };
}
