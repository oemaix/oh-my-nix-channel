# Upstream is a small Electron app with no runtime npm dependencies.
# It declares electron ^42.11.16; use the binary build so this overlay
# does not compile Chromium.
{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  makeWrapper,
  imagemagick,
  electron_42-bin,
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

  nativeBuildInputs = [
    makeWrapper
    imagemagick
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 package.json -t $out/share/dl-desktop
    install -Dm644 icon.png -t $out/share/dl-desktop
    install -Dm644 scripts/*.js -t $out/share/dl-desktop/scripts

    install -Dm644 ro.go.hmlendea.DL-Desktop.desktop -t $out/share/applications

    # The upstream PNG is 512x512. hicolor's 512x512/apps entry only matches
    # requests of 64px and up, so menus that ask for a smaller size miss it.
    iconName=ro.go.hmlendea.DL-Desktop
    install -Dm644 icon.png $out/share/icons/hicolor/512x512/apps/$iconName.png
    install -Dm644 icon.png $out/share/pixmaps/$iconName.png
    for size in 16 22 24 32 36 48 64 72 96 128 192 256; do
      dir=$out/share/icons/hicolor/''${size}x''${size}/apps
      mkdir -p "$dir"
      magick icon.png -resize "''${size}x''${size}" "$dir/$iconName.png"
    done

    # Unpackaged Electron otherwise uses the class "electron", which does not
    # match StartupWMClass in the upstream desktop file.
    makeWrapper ${lib.getExe electron_42-bin} $out/bin/dl-desktop \
      --add-flags "--class='DL: language lessons'" \
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
