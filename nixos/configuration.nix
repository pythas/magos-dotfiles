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

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
  };

  services.phpfpm.pools = {
    php82 = {
      user = "johan";
      phpPackage = pkgs.php82;
      settings = {
        "pm" = "dynamic";
        "pm.max_children" = 5;
        "pm.start_servers" = 2;
        "pm.min_spare_servers" = 1;
        "pm.max_spare_servers" = 3;
      };
    };

    php83 = {
      user = "johan";
      phpPackage = pkgs.php83;
      settings = {
        "pm" = "dynamic";
        "pm.max_children" = 5;
        "pm.start_servers" = 2;
        "pm.min_spare_servers" = 1;
        "pm.max_spare_servers" = 3;
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d /run/phpfpm 0750 johan wwwrun -"
  ];

  services.openssh.enable = true;

  environment.systemPackages = with pkgs; [
    wget
    vim
    git
    php
  ];

  systemd.services.phpfpm-php82.serviceConfig.RuntimeDirectory = "phpfpm";
  systemd.services.phpfpm-php83.serviceConfig.RuntimeDirectory = "phpfpm";

  system.stateVersion = "25.11";

}

