# NixOS Configuration for seagull

This repository contains the NixOS configuration for the seagull system, managed with flakes.

## Quick Start

### System Management

Rebuild the system using the flake:

```bash
# Switch to the new configuration
sudo nixos-rebuild switch --flake .#seagull

# Build but don't switch (test changes)
sudo nixos-rebuild build --flake .#seagull

# Show configuration diff
sudo nixos-rebuild diff --flake .#seagull
```

### Development

Enter the development environment with maintenance tools:

```bash
nix develop
```

Available tools in the dev shell:
- `nixfmt` / `nixpkgs-fmt` - Nix code formatting
- `deadnix` - Find dead Nix code
- `statix` - Nix linter and analysis
- `nil` - Nix language server

### Code Quality

Format the code:
```bash
nix fmt
```

Run quality checks:
```bash
nix flake check
```

## Structure

```
/home/tom/nixos/
├── flake.nix              # Main flake definition
├── flake.lock             # Locked dependencies
├── configuration.nix      # System configuration (symlink to /etc/nixos/)
└── README.md             # This file
```

## Current Configuration

- **System**: NixOS unstable
- **Desktop**: KDE Plasma 6
- **Packages**: Firefox, Neovim, Discord, system monitoring tools
- **Services**: Tailscale, SABnzbd, PipeWire
- **Hardware**: EFI boot, latest kernel

## Getting Help

- `nixos-rebuild --help` - Rebuild command options
- `man configuration.nix` - Configuration options
- https://nixos.org/manual/nixos/stable/ - NixOS manual
- https://nixos.wiki/ - Community wiki

## Maintenance Tips

1. Always run `nix flake check` before rebuilding
2. Use `nix fmt` to keep code formatted consistently
3. Update dependencies: `nix flake update`
4. Keep backups of working configurations

## Recovery

If the system fails to boot:
1. Boot from the NixOS installation media
2. Mount your system partitions
3. Roll back to a previous generation:
   ```bash
   nix-env --list-generations --profile /nix/var/nix/profiles/system
   sudo nix-env --rollback -p /nix/var/nix/profiles/system
   ```