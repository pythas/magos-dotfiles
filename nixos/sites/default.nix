{ config, pkgs, lib, ... }:

{
  services.httpd.virtualHosts."default" = {
    documentRoot = "/srv/www/default";
    extraConfig = ''
      <Directory "/srv/www/default">
        Options +FollowSymLinks +Indexes
        AllowOverride None
        Require all granted
        DirectoryIndex index.html
      </Directory>
    '';
  };
}
