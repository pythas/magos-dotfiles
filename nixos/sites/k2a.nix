{ config, pkgs, lib, ... }:

{
  services.httpd.virtualHosts."k2a.test" = {
    serverAliases = [ "k2a.test" "*.k2a.test" ];
    documentRoot = "/srv/www/k2a/k2a-wordpress/www/";
    extraConfig = ''
      ErrorLog "/srv/www/k2a/logs/apache_error.log"
      CustomLog "/srv/www/k2a/logs/apache_access.log" combined

      <Directory "/srv/www/k2a/k2a-wordpress/www/">
        Options +FollowSymLinks +Indexes
        AllowOverride All
        Require all granted
        DirectoryIndex index.php index.html
      </Directory>

      <FilesMatch "\.php$">
        SetHandler "proxy:unix:/run/phpfpm/php82.sock|fcgi://localhost"
      </FilesMatch>
    '';
  };

  systemd.services.httpd.serviceConfig.ReadWritePaths = [ "/srv/www/k2a/logs" ];
  systemd.services.phpfpm-php82.serviceConfig.ReadWritePaths = [ "/srv/www/k2a/logs" "/srv/www/k2a/k2a-wordpress/www" ];
}
