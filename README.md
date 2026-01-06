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
