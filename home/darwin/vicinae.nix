{
  launchd.agents.vicinae = {
    enable = true;
    config = {
      Program = "/Applications/Vicinae.app/Contents/MacOS/Vicinae";
      KeepAlive = true;
      RunAtLoad = true;
    };
  };
}
