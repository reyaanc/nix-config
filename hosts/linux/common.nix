{
  networking.networkmanager.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  programs.hyprland.enable = true;
}
