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
    tree-sitter
    gemini-cli
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  programs.tmux = {
    enable = true;
    shortcut = "a";
    baseIndex = 1;
    newSession = true;
    mouse = true;
    keyMode = "vi";

    plugins = with pkgs; [
      tmuxPlugins.sensible
    ];
};

  programs.bash.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableBashIntegration = true;
  };

  xdg.configFile.nvim.source = ./../nvim; 
}
