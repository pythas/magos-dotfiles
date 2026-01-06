{ config, lib, pkgs, ... }:

{
  imports =
  [
    ./hardware-configuration.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "magos";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Stockholm";

  i18n.defaultLocale = "en_US.UTF-8";

  users.users.johan = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  programs.nix-ld.enable = true;

  environment.systemPackages = with pkgs; [
    wget
    vim
    git
  ];

  services.openssh.enable = true;

  system.stateVersion = "25.11";

}

