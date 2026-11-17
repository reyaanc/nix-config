{ config, ... }:
{
  imports = [
    ./theme.nix
    ./packages.nix
    ./fish.nix
    ./fzf.nix
    ./zoxide.nix
    ./direnv.nix
    ./less.nix
    ./git.nix
    ./delta.nix
    ./ghostty.nix
    ./neovim.nix
    ./zed.nix
    ./btop.nix
    ./lazygit.nix
    ./lazydocker.nix
    ./spicetify.nix
    ./vicinae.nix
    ./claude.nix
  ];

  home.stateVersion = "26.05";

  home.sessionPath = [ "${config.home.homeDirectory}/.local/bin" ];

  _module.args.dotfile = path:
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Personal/nix-config/config/${path}";
}
