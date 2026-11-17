{ pkgs, ... }:
{
  home.packages = with pkgs; [
    awscli2
    docker-client
    fd
    ffmpeg-full
    gdu
    gh
    helmfile
    imagemagickBig
    jq
    kubernetes-helm
    kustomize
    librsvg
    mutagen
    neovim
    nodejs
    poppler-utils
    resvg
    ripgrep
    _7zz
    statix
    terraform
    todoist-cli
    typst
    uv

    nerd-fonts.hack
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
  ];
}
