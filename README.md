# magos-dotfiles

This is a NixOS configuration using Flakes and Home Manager. It manages the system for the host magos and includes a LazyVim setup.

## Structure
* flake.nix: Entry point that locks software versions.
* nixos/configuration.nix: System hardware and service settings.
* nixos/home.nix: User packages and application settings.
* nvim/: LazyVim configuration files.

## Installation

### 1. Prerequisite
Install NixOS 25.11 and ensure you have an internet connection.

### 2. Clone the Repository
```bash
git clone https://github.com/your-username/magos-dotfiles ~/magos-dotfiles
cd ~/magos-dotfiles
```

### 3. Generate Hardware Config
If on new hardware, run:
```bash
sudo nixos-generate-config --show-hardware-config > ./nixos/hardware-configuration.nix
```

### 4. Apply the Configuration
Run:
```bash
sudo nixos-rebuild switch --flake .#magos
```

## Adding a WordPress Site

This configuration uses a **Pure Flake** approach. Each WordPress site is a separate Flake that exports a NixOS module.

### 1. Prepare the Site Flake
Ensure the site repository (e.g., `/srv/www/mysite`) has a `flake.nix` that exports `nixosModules.vhost`.

### 2. Register in `flake.nix`
Edit `~/magos-dotfiles/flake.nix` to register the site:

1.  **Add to `inputs`:**
    ```nix
    mysite.url = "path:/srv/www/mysite";
    ```
2.  **Add to `sites` list:**
    ```nix
    sites = [
      inputs.k2a.nixosModules.vhost
      inputs.mysite.nixosModules.vhost
    ];
    ```

### 3. Rebuild
```bash
git add flake.nix
sudo nixos-rebuild switch --flake .#magos
```

## Maintenance

### Rebuild After Changes
Run:
```bash
git add .
sudo nixos-rebuild switch --flake .#magos
```

### Update Packages
Run:
```bash
nix flake update
sudo nixos-rebuild switch --flake .#magos
```

### Garbage Collection
Run:
```bash
sudo nix-collect-garbage -d
```

## Important Notes
* Read-Only Config: Neovim files in ~/.config/nvim are read-only. Edit files in ~/magos-dotfiles/nvim and rebuild to apply changes.
* Nix-LD: This config enables nix-ld so LazyVim's Mason manager can run binaries on NixOS.
* Git Tracking: Flakes only see files tracked by Git. Always run git add . before rebuilding.
