# oh-my-nix-channel

Extra [Nix](https://nixos.org) packages that are missing from nixpkgs, provided as a
standalone overlay. Works with and without flakes.

## Packages

| Attribute | Description | Platforms | License |
|---|---|---|---|
| `deepl-linux-electron` | Unofficial DeepL translator desktop client | x86_64-linux | MIT |
| `digital-paper-companion` | Companion for Sony Digital Paper and Fujitsu Quaderno | x86_64-linux | Apache-2.0 / MIT |
| `msty-studio` | Desktop app for local and online AI models | x86_64-linux | unfree |
| `notion-electron` | Unofficial Notion desktop client | x86_64-linux, aarch64-linux | MIT |
| `zen-browser-app` | Firefox-based browser focused on privacy | x86_64-linux, aarch64-linux | MPL-2.0 |

All packages repackage the official binary releases (AppImages).
`zen-browser-app` carries the `-app` suffix so the overlay will not shadow a
future `zen-browser` attribute in nixpkgs.

## Try a package without installing

With flakes enabled:

```bash
# run it once
nix run github:oemaix/oh-my-nix-channel#zen-browser-app

# or put it on PATH for the current shell session
nix shell github:oemaix/oh-my-nix-channel#notion-electron
```

Without flakes:

```bash
nix-shell -p '(import (builtins.fetchTarball
  "https://github.com/oemaix/oh-my-nix-channel/archive/main.tar.gz") {}).notion-electron'
```

Note: the non-flake variant builds against your system's `<nixpkgs>`, so the first
run may download a large dependency closure.

## Install on NixOS — without flakes (`configuration.nix`)

Add the overlay, then use the packages like any other `pkgs.*` attribute:

```nix
{ config, pkgs, ... }:
{
  nixpkgs.overlays = [
    (import "${builtins.fetchTarball
      "https://github.com/oemaix/oh-my-nix-channel/archive/main.tar.gz"}/overlay.nix")
  ];

  environment.systemPackages = with pkgs; [
    zen-browser-app
    notion-electron
  ];
}
```

`main.tar.gz` is rolling. To pin an exact state, use a commit URL instead:
`https://github.com/oemaix/oh-my-nix-channel/archive/<commit-sha>.tar.gz`.

## Install on NixOS — with flakes

Add the input and either the ready-made module or the overlay:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    oh-my-nix = {
      url = "github:oemaix/oh-my-nix-channel";
      inputs.nixpkgs.follows = "nixpkgs"; # build against your nixpkgs
    };
  };

  outputs = { nixpkgs, oh-my-nix, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      modules = [
        ./configuration.nix
        oh-my-nix.nixosModules.overlay   # adds the packages to pkgs.*
      ];
    };
  };
}
```

Then in `configuration.nix`:

```nix
environment.systemPackages = with pkgs; [ zen-browser-app notion-electron ];
```

Alternatively, skip the overlay and reference one package directly:

```nix
environment.systemPackages = [
  oh-my-nix.packages.${pkgs.system}.zen-browser-app
];
```

## Home Manager

Same overlay, different option:

```nix
nixpkgs.overlays = [ /* as above, tarball or flake input */ ];
home.packages = with pkgs; [ notion-electron ];
```

## Classic channel (`nix-env`)

```bash
nix-channel --add https://github.com/oemaix/oh-my-nix-channel/archive/main.tar.gz oh-my-nix
nix-channel --update
nix-env -f '<oh-my-nix>' -iA notion-electron
```

## Unfree packages

`msty-studio` is proprietary.

- `nix run github:oemaix/oh-my-nix-channel#msty-studio` works out of the box
  (the flake's own package set allows unfree).
- As an overlay user you need `nixpkgs.config.allowUnfree = true;`
  (or `NIXPKGS_ALLOW_UNFREE=1` for `nix-env`/`nix-shell`).

---

## Maintainer notes

### Add a package

1. Copy `pkgs/TEMPLATE.nix` to `pkgs/<pname>/default.nix` and fill in source,
   build, and `meta`.
2. Register it in `pkgs/default.nix`.
3. `nix build .#<pname>` and `nix run .#<pname>`.

Keep each `default.nix` free of repo-specific helpers, so a later nixpkgs PR
is a copy, not a rewrite.

### Update a package

Bump `version` in `pkgs/<name>/default.nix`, refresh the hash with
`nix store prefetch-file <url>` (on a hash mismatch, Nix also prints the
expected value at build time).

New Msty Studio versions are announced at
`https://next-assets.msty.studio/app/beta/linux/latest-linux.yml`;
the versioned download lives at
`https://next-assets.msty.studio/app/releases/<version>/linux/MstyStudio_x86_64.AppImage`.

### Submit to nixpkgs

When a package is stable: clone [nixpkgs](https://github.com/NixOS/nixpkgs)
separately, copy `pkgs/<pname>/default.nix` into the right category, follow
[CONTRIBUTING.md](https://github.com/NixOS/nixpkgs/blob/master/CONTRIBUTING.md),
and run `nixpkgs-review`. Packages built from unfree binaries usually stay here.

### Layout

```text
flake.nix                 flake outputs: packages, overlay, NixOS module
overlay.nix               nixpkgs overlay
default.nix               non-flake / channel entry point
pkgs/default.nix          package registry
pkgs/<name>/default.nix   one derivation, nixpkgs style
pkgs/TEMPLATE.nix         starting point for a new package
```

### Develop

```bash
nix fmt <files>
nix flake check    # builds every package
nix build .#<name>
```
