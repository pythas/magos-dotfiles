{ lib, config, ... }:
with lib;
let
  cfg = config.services.wordpress-vhosts;
in
{
  options.services.wordpress-vhosts = mkOption {
    type = types.attrsOf (types.submodule ({ name, ... }: {
      options = {
        enable = mkEnableOption "WordPress Vhost";
        aliases = mkOption {
          type = types.listOf types.str;
          default = [];
          description = "Additional server aliases.";
        };
        documentRoot = mkOption {
          type = types.str;
          description = "Path to the document root.";
        };
        logDir = mkOption {
          type = types.str;
          description = "Directory for Apache logs.";
        };
        phpVersion = mkOption {
          type = types.enum [ "php82" "php83" ];
          default = "php83";
          description = "PHP version to use (php82 or php83).";
        };
      };
    }));
    default = {};
    description = "Configuration for WordPress virtual hosts.";
  };

  config = mkIf (cfg != {}) {
    services.httpd.virtualHosts = mapAttrs (name: site: {
      serverAliases = [ name ] ++ site.aliases;
      documentRoot = site.documentRoot;
      extraConfig = ''
        ErrorLog "${site.logDir}/apache_error.log"
        CustomLog "${site.logDir}/apache_access.log" combined

        <Directory "${site.documentRoot}">
          Options +FollowSymLinks +Indexes
          AllowOverride All
          Require all granted
          DirectoryIndex index.php index.html
        </Directory>

        <FilesMatch "\.php$">
          SetHandler "proxy:unix:/run/phpfpm/${site.phpVersion}.sock|fcgi://localhost"
        </FilesMatch>
      '';
    }) cfg;

    systemd.services.httpd.serviceConfig.ReadWritePaths = 
      unique (map (site: site.logDir) (attrValues cfg));

    systemd.services.phpfpm-php82.serviceConfig.ReadWritePaths = 
      unique (flatten (map (site: 
        if site.phpVersion == "php82" then [ site.logDir site.documentRoot ] else []
      ) (attrValues cfg)));

    systemd.services.phpfpm-php83.serviceConfig.ReadWritePaths = 
      unique (flatten (map (site: 
        if site.phpVersion == "php83" then [ site.logDir site.documentRoot ] else []
      ) (attrValues cfg)));
  };
}
