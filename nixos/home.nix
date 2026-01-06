{ config, pkgs, ... }:

{
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    tree
    ghostty.terminfo
    ripgrep
    fd
    gcc
    unzip
    lua-language-server
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  xdg.configFile.nvim.source = ./../nvim; 
}
