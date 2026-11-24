{ config, lib, ... }:
let
  clear = "printf '\\033[2J\\033[3J\\033[1;1H'";
in
{
  programs.fish = {
    enable = true;

    interactiveShellInit = lib.concatStrings (lib.mapAttrsToList (name: hex: "set -g theme_${name} ${hex}\n") config.theme.colors) + ''
      set fish_greeting

      set -g fish_key_bindings fish_vi_key_bindings

      set -g fish_cursor_default     block
      set -g fish_cursor_insert      line
      set -g fish_cursor_visual      block
      set -g fish_cursor_replace     underscore
      set -g fish_cursor_replace_one underscore

      bind -M insert ctrl-a beginning-of-line
      bind -M insert ctrl-e end-of-line
      bind -M insert ctrl-w backward-kill-word

      set -g fish_transient_prompt 1
    '';

    functions = {
      # Empty so vi mode changes repaint the whole prompt, which draws the mode character
      fish_mode_prompt = "";
    };

    shellAliases = {
      inherit clear;
      celar = clear;
      claer = clear;
    };
  };

  xdg.configFile."fish/functions/fish_prompt.fish".source = ../../config/fish/functions/fish_prompt.fish;
}
