# Overlay over nixpkgs. Use `final` so packages in this repo can depend on each other.
final: _prev: import ./pkgs { pkgs = final; }
