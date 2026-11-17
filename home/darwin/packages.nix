{ pkgs, ... }:
{
  home.packages = with pkgs; [
    colima
    sketchybar-app-font
  ];
}
