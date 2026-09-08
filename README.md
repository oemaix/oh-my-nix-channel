# oh-my-nix-channel

Personal [Nix](https://nixos.org) packages as a **standalone overlay**, not a nixpkgs fork.
Packages are written in nixpkgs `callPackage` style so they can later be submitted upstream.

## Packages

| Attribute | Description | Platforms | License |
|---|---|---|---|
| `deepl-linux-electron` | Unofficial DeepL translator desktop client | x86_64-linux | MIT |
| `msty-studio` | Desktop app for local and online AI models | x86_64-linux | unfree |
| `notion-electron` | Unofficial Notion desktop client | x86_64-linux, aarch64-linux | MIT |
| `zen-browser-app` | Firefox-based browser focused on privacy | x86_64-linux, aarch64-linux | MPL-2.0 |

All packages repackage official binary releases (AppImages).
`zen-browser-app` is named with the `-app` suffix so the overlay will not shadow a
future `zen-browser` attribute in nixpkgs.

`msty-studio` is unfree; overlay consumers need `nixpkgs.config.allowUnfree = true`
(the flake's own `packages` output already allows it).

## Use

Replace `oemaix` after the repo is on GitHub.

### Flake (one package)

```bash
nix run github:oemaix/oh-my-nix-channel#zen-browser-app
nix build github:oemaix/oh-my-nix-channel#notion-electron
```

Or as an input of your own flake:

```nix
{
  inputs.oh-my-nix.url = "github:oemaix/oh-my-nix-channel";

  # …
  # inputs.oh-my-nix.packages.${pkgs.system}.notion-electron
}
```

### NixOS overlay

Makes every package in this repo available as `pkgs.<name>`:

```nix
{
  inputs.oh-my-nix.url = "github:oemaix/oh-my-nix-channel";

  outputs = { nixpkgs, oh-my-nix, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      modules = [
        oh-my-nix.nixosModules.overlay
        ({ pkgs, ... }: {
          nixpkgs.config.allowUnfree = true; # for msty-studio
          environment.systemPackages = [
            pkgs.zen-browser-app
            pkgs.notion-electron
          ];
        })
      ];
    };
  };
}
```

You can also append `oh-my-nix.overlays.default` to `nixpkgs.overlays` yourself.

### Without flakes

```bash
nix-build -A notion-electron
```

## Add a package

1. Copy `pkgs/TEMPLATE.nix` to `pkgs/<pname>/default.nix`.
2. Fill in source, build, and `meta`.
3. Register it in `pkgs/default.nix`.
4. Build and run:

   ```bash
   nix build .#my-package
   nix run .#my-package
   ```

Keep each `default.nix` free of repo-specific helpers. That is what makes a later nixpkgs PR a copy, not a rewrite.

## Update a package

Bump `version` in `pkgs/<name>/default.nix`, then refresh the hash:

```bash
nix store prefetch-file <url>
```

For a wrong hash, Nix also prints the expected value on build.

## Later: submit to nixpkgs

When a package is stable:

1. Clone [nixpkgs](https://github.com/NixOS/nixpkgs) **separately** (do not merge it into this repo).
2. Copy `pkgs/<pname>/default.nix` into the right nixpkgs category.
3. Follow [CONTRIBUTING.md](https://github.com/NixOS/nixpkgs/blob/master/CONTRIBUTING.md) and run `nixpkgs-review`.

This repo stays the overlay for packages that are not upstream yet.
Note: packages built from mutable "latest" URLs or unfree binaries are usually
not accepted upstream; those stay here permanently.

## Layout

```text
flake.nix                 flake outputs: packages, overlay, NixOS module
overlay.nix               nixpkgs overlay
default.nix               non-flake / NUR entry point
pkgs/default.nix          package registry
pkgs/<name>/default.nix   one derivation, nixpkgs style
pkgs/TEMPLATE.nix         starting point for a new package
```

## Develop

```bash
nix fmt <files>
nix flake check    # builds every package
nix build .#<name>
```
