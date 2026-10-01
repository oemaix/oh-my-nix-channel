# Register every package here. Each one lives in pkgs/<name>/default.nix
# and is written as a nixpkgs `callPackage` file so it can be copied upstream later.
{ pkgs }:
let
  # Upstream renamed Vireo to Hylki. Keep the old attribute so existing configs still evaluate.
  hylki = pkgs.callPackage ./vireo { };
in
{
  deepl-linux-electron = pkgs.callPackage ./deepl-linux-electron { };
  digital-paper-companion = pkgs.callPackage ./digital-paper-companion { };
  inherit hylki;
  msty-studio = pkgs.callPackage ./msty-studio { };
  notion-electron = pkgs.callPackage ./notion-electron { };
  vireo = hylki;
  zen-browser-app = pkgs.callPackage ./zen-browser-app { };
}
