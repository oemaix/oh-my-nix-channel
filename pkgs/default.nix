# Register every package here. Each one lives in pkgs/<name>/default.nix
# and is written as a nixpkgs `callPackage` file so it can be copied upstream later.
{ pkgs }:
{
  deepl-linux-electron = pkgs.callPackage ./deepl-linux-electron { };
  msty-studio = pkgs.callPackage ./msty-studio { };
  notion-electron = pkgs.callPackage ./notion-electron { };
  zen-browser-app = pkgs.callPackage ./zen-browser-app { };
}
