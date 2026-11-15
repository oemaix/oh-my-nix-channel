# Upstream is a small Electron app with no runtime npm dependencies.
# It declares electron ^42.11.16. That major is EOL in nixpkgs, so use the
# next supported binary (electron_43-bin) instead of compiling Chromium.
{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  makeWrapper,
  electron_43-bin,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "dl-desktop";
  version = "4.3.2";

  src = fetchFromGitHub {
    owner = "hmlendea";
    repo = "dl-desktop";
    rev = "v${finalAttrs.version}";
    hash = "sha256-6qnZm0s4j6hYACuzlNbkA84dQJktLTWBXvMryaAFIZ4=";
  };

  strictDeps = true;

  nativeBuildInputs = [ makeWrapper ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 package.json -t $out/share/dl-desktop
    install -Dm644 icon.png -t $out/share/dl-desktop
    install -Dm644 scripts/*.js -t $out/share/dl-desktop/scripts

    # Electron overwrites CHROME_DESKTOP at startup. With no package.json
    # desktopName, the Wayland app id is the slug of productName
    # "DL: language lessons": dl-language-lessons. The desktop file name,
    # StartupWMClass, and icon have to be that id or GNOME keeps the
    # generic executable icon.
    install -Dm644 ro.go.hmlendea.DL-Desktop.desktop \
      $out/share/applications/dl-language-lessons.desktop
    substituteInPlace $out/share/applications/dl-language-lessons.desktop \
      --replace-fail "StartupWMClass=DL: language lessons" "StartupWMClass=dl-language-lessons" \
      --replace-fail "Icon=ro.go.hmlendea.DL-Desktop" "Icon=dl-language-lessons"

    install -Dm644 icon.png \
      $out/share/icons/hicolor/512x512/apps/dl-language-lessons.png

    makeWrapper ${lib.getExe electron_43-bin} $out/bin/dl-desktop \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
      --add-flags $out/share/dl-desktop

    runHook postInstall
  '';

  meta = {
    description = "Unofficial desktop client for Duolingo";
    homepage = "https://github.com/hmlendea/dl-desktop";
    changelog = "https://github.com/hmlendea/dl-desktop/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    mainProgram = "dl-desktop";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
})
