{ config, lib, pkgs, username, ... }:

{
  imports =
  [
    ./hardware-configuration.nix
    ./modules/wordpress-vhost.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "magos";
  networking.networkmanager.enable = true;
  networking.firewall.allowedTCPPorts = [
    80
    443
    3306
  ];

  time.timeZone = "Europe/Stockholm";

  i18n.defaultLocale = "en_US.UTF-8";

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };
  users.users.wwwrun.extraGroups = [
    "users"
    username
  ];

  programs.nix-ld.enable = true;

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;

    ensureUsers = [
      {
        name = username;
        ensurePermissions = {
          "*.*" = "ALL PRIVILEGES";
        };
      }
    ];
  };

  services.phpfpm.pools = {
    php82 = {
      user = username;
      group = "users";
      phpPackage = pkgs.php82;
      settings = {
        "listen.owner" = username;
        "listen.group" = "wwwrun";
        "listen.mode" = "0660";
        "pm" = "dynamic";
        "pm.max_children" = 5;
        "pm.start_servers" = 2;
        "pm.min_spare_servers" = 1;
        "pm.max_spare_servers" = 3;
      };
    };

    php83 = {
      user = username;
      group = "users";
      phpPackage = pkgs.php83;
      settings = {
        "listen.owner" = username;
        "listen.group" = "wwwrun";
        "listen.mode" = "0660";
        "pm" = "dynamic";
        "pm.max_children" = 5;
        "pm.start_servers" = 2;
        "pm.min_spare_servers" = 1;
        "pm.max_spare_servers" = 3;
      };
    };
  };

  services.httpd = {
    enable = true;
    user = "wwwrun";
    group = "wwwrun";
    adminAddr = "admin@localhost";
    extraModules = [
      "proxy_fcgi"
      "proxy"
      "rewrite"
    ];
  };

  systemd.tmpfiles.rules = [
    "d /run/phpfpm 0750 ${username} wwwrun -"
  ];

  services.openssh.enable = true;

  environment.systemPackages = with pkgs; [
    wget
    vim
    git
    openfortivpn
  ];

  systemd.services.phpfpm-php82.serviceConfig.RuntimeDirectory = "phpfpm";
  systemd.services.phpfpm-php83.serviceConfig.RuntimeDirectory = "phpfpm";

  system.stateVersion = "25.11";

}

