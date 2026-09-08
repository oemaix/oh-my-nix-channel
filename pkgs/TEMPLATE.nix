# Copy this file to pkgs/<pname>/default.nix and register it in pkgs/default.nix.
# Keep the shape identical to a nixpkgs derivation so you can later open a PR there.
{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "my-package";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "OWNER";
    repo = "REPO";
    rev = "v${finalAttrs.version}";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  meta = {
    description = "Short description of the package";
    homepage = "https://github.com/OWNER/REPO";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "my-package";
    platforms = lib.platforms.unix;
  };
})
