# magos-dotfiles

This is a NixOS configuration using Flakes and Home Manager for the host `magos`. It provides a comprehensive web development environment (Apache, PHP-FPM, MySQL) and includes a custom [LazyVim](https://www.lazyvim.org/) setup.

## Structure

*   `flake.nix`: The entry point. Defines system inputs, the `magos` host, and development shells.
*   `nixos/configuration.nix`: Main system configuration (hardware, services like Apache/MySQL, etc.).
*   `nixos/home.nix`: Home Manager configuration for user packages and dotfiles.
*   `nixos/sites/`: Directory for individual website configurations (NixOS modules).
*   `nvim/`: Complete Neovim configuration based on LazyVim.

## Installation

### 1. Prerequisite
Install NixOS 25.11 and ensure you have an internet connection.

### 2. Clone the Repository
```bash
git clone https://github.com/pythas/magos-dotfiles ~/magos-dotfiles
cd ~/magos-dotfiles
```

### 3. Generate Hardware Config
If you are deploying on new hardware, generate the hardware-specific configuration:
```bash
sudo nixos-generate-config --show-hardware-config > ./nixos/hardware-configuration.nix
```

### 4. Apply the Configuration
Run the following to build and switch to the `magos` configuration:
```bash
sudo nixos-rebuild switch --flake .#magos
```

## Web Development Setup

This configuration sets up a local LAMP stack suitable for WordPress development.

### Infrastructure
*   **Web Server**: Apache (`httpd`)
*   **Database**: MariaDB (`mysql`)
*   **PHP**: PHP-FPM with pools for `php82` and `php83`.
*   **DNS**: Sites are typically set up with `.test` domains (e.g., `k2a.test`).

### Development Environments
A development shell is defined in `flake.nix` containing tools like `php`, `composer`, `wp-cli`, and `nodejs`.

To enter the environment for the `k2a` project:
```bash
nix develop .#k2a
```

### Adding a New Site

Sites are managed as NixOS modules in `nixos/sites/`.

1.  **Create a Site Configuration**:
    Create a new file, e.g., `nixos/sites/mysite.nix`:
    ```nix
    { config, pkgs, lib, ... }:

    {
      services.httpd.virtualHosts."mysite.test" = {
        serverAliases = [ "www.mysite.test" ];
        documentRoot = "/srv/www/mysite/public";
        extraConfig = ''
          <Directory "/srv/www/mysite/public">
            Options +FollowSymLinks +Indexes
            AllowOverride All
            Require all granted
            DirectoryIndex index.php index.html
          </Directory>

          <FilesMatch "\.php$">
            # Choose your PHP version here (php82.sock or php83.sock)
            SetHandler "proxy:unix:/run/phpfpm/php82.sock|fcgi://localhost"
          </FilesMatch>
        '';
      };

      # Ensure permissions for logs and web root
      systemd.services.httpd.serviceConfig.ReadWritePaths = [ "/srv/www/mysite/logs" ];
      # Allow PHP-FPM to write to the web root if needed
      systemd.services.phpfpm-php82.serviceConfig.ReadWritePaths = [ "/srv/www/mysite/public" ];
    }
    ```

2.  **Enable the Site**:
    Import the new file in `nixos/configuration.nix`:
    ```nix
    imports =
    [
      ./hardware-configuration.nix
      ./sites/k2a.nix
      ./sites/mysite.nix # <-- Add this line
    ];
    ```

3.  **Define Development Environment**:
    Add a named devShell to `flake.nix` so you can use site-specific tools:
    ```nix
    devShells.x86_64-linux.mysite = pkgs.mkShell {
      buildInputs = [
        pkgs.php83
        pkgs.php83Packages.composer
        pkgs.wp-cli
        pkgs.nodejs_20
      ];
    };
    ```

4.  **Configure Local Environment (direnv)**:
    In your site's root directory (e.g., `/srv/www/mysite`), create a `.envrc` file to automatically load the environment.
    
    File `.envrc`:
    ```bash
    use flake ~/magos-dotfiles#mysite
    ```
    
    Then run:
    ```bash
    direnv allow
    ```

5.  **Apply Changes**:
    ```bash
    git add .
    sudo nixos-rebuild switch --flake .#magos
    ```

## Neovim (LazyVim)

The configuration in `nvim/` is a modular LazyVim setup.
*   **Location**: The files in `~/magos-dotfiles/nvim` are the source of truth.
*   **Note**: `nix-ld` is enabled on the system to allow binaries downloaded by Mason (LazyVim's package manager) to run correctly on NixOS.

## Maintenance

### Rebuild System
After making changes to any `.nix` file:
```bash
git add .
sudo nixos-rebuild switch --flake .#magos
```

### Update Flake Inputs
To update system packages (locked in `flake.lock`):
```bash
nix flake update
sudo nixos-rebuild switch --flake .#magos
```

### Garbage Collection
To free up disk space by removing old generations:
```bash
sudo nix-collect-garbage -d
```
