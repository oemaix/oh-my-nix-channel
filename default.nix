# Non-flake / NUR-style entry point:
#   nix-build -A example-hello
#   nur.repos.<you>.example-hello
{
  pkgs ? import <nixpkgs> { },
}:
import ./pkgs { inherit pkgs; }
