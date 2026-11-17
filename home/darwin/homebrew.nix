{
  home.sessionVariables = {
    HOMEBREW_PREFIX = "/opt/homebrew";
    HOMEBREW_CELLAR = "/opt/homebrew/Cellar";
    HOMEBREW_REPOSITORY = "/opt/homebrew";
  };

  programs.fish.shellInit = ''
    fish_add_path -gaP /opt/homebrew/bin /opt/homebrew/sbin /usr/local/sbin
  '';
}
