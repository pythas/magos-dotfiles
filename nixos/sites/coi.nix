{ config, pkgs, lib, ... }:

{
  services.httpd.virtualHosts."coi.test" = {
    serverAliases = [ "coi.test" ];
    documentRoot = "/srv/www/coi/www/";
    extraConfig = ''
      ErrorLog "/srv/www/coi/logs/apache_error.log"
      CustomLog "/srv/www/coi/logs/apache_access.log" combined

      <Directory "/srv/www/coi/www/">
        Options +FollowSymLinks +Indexes
        AllowOverride All
        Require all granted
        DirectoryIndex index.html
      </Directory>
    '';
  };

  systemd.tmpfiles.rules = [
    "d /srv/www/coi/logs 0750 wwwrun wwwrun -"
  ];
}
