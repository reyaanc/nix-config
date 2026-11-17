{
  programs.git.signing = {
    format = "ssh";
    key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDOTCuf+sxkxWZQURnORFKHqqvToP2i9xEGvwfqHQrnq";
    signByDefault = true;
    signer = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
  };
}
