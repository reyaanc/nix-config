{ pkgs, ... }:
{
  home.packages = with pkgs; [
    awscli2
    docker-client
    fd
    ffmpeg-full
    gdu
    gh
    imagemagickBig
    jq
    librsvg
    mutagen
    neovim
    nodejs
    poppler-utils
    resvg
    ripgrep
    _7zz
    statix
    todoist-cli
    typst
    uv

    nerd-fonts.hack
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
  ];
}
