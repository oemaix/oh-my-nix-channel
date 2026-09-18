{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  wrapGAppsHook4,
  desktop-file-utils,
  gettext,
  glib,
  gtk4,
  libadwaita,
  webkitgtk_6_0,
  glib-networking,
  openssl,
  libsecret,
  poppler,
  dbus,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "vireo";
  version = "1.33.4";

  src = fetchFromGitHub {
    owner = "hyprlab";
    repo = "vireo";
    rev = "v${finalAttrs.version}";
    hash = "sha256-CYQfdKkevj9D0AP4xSm1EkYbzlC2xGPMqK4I7yd6PIk=";
  };

  cargoHash = "sha256-OnHXtsdmjKHuCC3nxVv7ixwmMXBzU9TPTAYY3E1aYuQ=";

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook4
    desktop-file-utils
    gettext
    glib
  ];

  buildInputs = [
    gtk4
    libadwaita
    webkitgtk_6_0
    glib
    glib-networking
    openssl
    libsecret
    poppler
    dbus
  ];

  # native-tls / openssl-sys should use the Nix openssl, not a vendored copy.
  env.OPENSSL_NO_VENDOR = 1;

  postInstall = ''
    install -Dm644 data/icons/hicolor/256x256/apps/co.hyprlab.Vireo.png \
      $out/share/icons/hicolor/256x256/apps/co.hyprlab.Vireo.png
    install -Dm644 data/icons/hicolor/512x512/apps/co.hyprlab.Vireo.png \
      $out/share/icons/hicolor/512x512/apps/co.hyprlab.Vireo.png
    install -Dm644 data/icons/hicolor/scalable/apps/co.hyprlab.Vireo.svg \
      $out/share/icons/hicolor/scalable/apps/co.hyprlab.Vireo.svg

    install -d $out/share/applications
    msgfmt --desktop --template=data/co.hyprlab.Vireo.desktop -d po \
      -o $out/share/applications/co.hyprlab.Vireo.desktop

    install -Dm644 data/co.hyprlab.Vireo.metainfo.xml \
      $out/share/metainfo/co.hyprlab.Vireo.metainfo.xml

    for po in po/*.po; do
      lang=$(basename "$po" .po)
      install -d $out/share/locale/$lang/LC_MESSAGES
      msgfmt -o $out/share/locale/$lang/LC_MESSAGES/vireo.mo "$po"
    done
  '';

  meta = {
    description = "GNOME-native email client with IMAP/SMTP and OAuth";
    homepage = "https://vireo.hyprlab.co";
    changelog = "https://github.com/hyprlab/vireo/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Plus;
    maintainers = [ ];
    mainProgram = "vireo";
    platforms = lib.platforms.linux;
  };
})
