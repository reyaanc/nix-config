{ config, lib, ... }:
let
  c = config.theme.colors;
  gradient = name: start: mid: end: ''
    theme[${name}_start]="#${start}"
    theme[${name}_mid]="#${mid}"
    theme[${name}_end]="#${end}"
  '';
in
{
  programs.btop = {
    enable = true;
    settings = lib.mapAttrs (_: lib.mkDefault) {
      color_theme = "theme";
      theme_background = false;
      proc_sorting = "memory";
      save_config_on_exit = false;
    };
    themes.theme = ''
      theme[main_bg]="#${c.bg}"
      theme[main_fg]="#${c.fg}"
      theme[title]="#${c.fg}"
      theme[hi_fg]="#${c.blue}"
      theme[selected_bg]="#${c.bgHighlight}"
      theme[selected_fg]="#${c.fg}"
      theme[inactive_fg]="#${c.comment}"
      theme[graph_text]="#${c.fgDim}"
      theme[meter_bg]="#${c.bgHighlight}"
      theme[proc_misc]="#${c.aqua}"
      theme[cpu_box]="#${c.border}"
      theme[mem_box]="#${c.border}"
      theme[net_box]="#${c.border}"
      theme[proc_box]="#${c.border}"
      theme[div_line]="#${c.bgLight}"
    ''
    + gradient "temp" c.green c.yellow c.red
    + gradient "cpu" c.green c.yellow c.red
    + gradient "free" c.green c.aqua c.blue
    + gradient "cached" c.blue c.violet c.pink
    + gradient "available" c.aqua c.blue c.violet
    + gradient "used" c.yellow c.orange c.red
    + gradient "download" c.blue c.violet c.pink
    + gradient "upload" c.green c.yellow c.orange;
  };
}
