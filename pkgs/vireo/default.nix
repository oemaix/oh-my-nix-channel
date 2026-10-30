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
  wayland,
  shared-mime-info,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "hylki";
  version = "1.46.0";

  src = fetchFromGitHub {
    owner = "hyprlab";
    repo = "hylki";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Fs0DwemwMpk+zSszXamPeI5p0kgJ7ZJmOLyxgYi9Gpg=";
  };

  cargoHash = "sha256-/jtnNjIq9RdStUlJaGp/lboMRjyKyJoe/alRH1XyoTM=";

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook4
    desktop-file-utils
    gettext
    glib
  ];

  # guess_mime() asks GIO, which reads this database.
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
    wayland
    shared-mime-info
  ];

  # native-tls / openssl-sys should use the Nix openssl, not a vendored copy.
  env.OPENSSL_NO_VENDOR = 1;

  # GIO only sees the suffix table when this database is on XDG_DATA_DIRS.
  # shared-mime-info has no setup hook, so both the tests and the wrapper need it.
  preCheck = ''
    export XDG_DATA_DIRS="${shared-mime-info}/share''${XDG_DATA_DIRS:+:}$XDG_DATA_DIRS"
  '';

  preFixup = ''
    gappsWrapperArgs+=(--prefix XDG_DATA_DIRS : "${shared-mime-info}/share")
  '';

  postInstall = ''
    install -Dm644 data/icons/hicolor/256x256/apps/co.hyprlab.Hylki.png \
      $out/share/icons/hicolor/256x256/apps/co.hyprlab.Hylki.png
    install -Dm644 data/icons/hicolor/512x512/apps/co.hyprlab.Hylki.png \
      $out/share/icons/hicolor/512x512/apps/co.hyprlab.Hylki.png
    install -Dm644 data/icons/hicolor/scalable/apps/co.hyprlab.Hylki.svg \
      $out/share/icons/hicolor/scalable/apps/co.hyprlab.Hylki.svg

    install -d $out/share/applications
    msgfmt --desktop --template=data/co.hyprlab.Hylki.desktop -d po \
      -o $out/share/applications/co.hyprlab.Hylki.desktop

    install -Dm644 data/co.hyprlab.Hylki.metainfo.xml \
      $out/share/metainfo/co.hyprlab.Hylki.metainfo.xml

    for po in po/*.po; do
      lang=$(basename "$po" .po)
      install -d $out/share/locale/$lang/LC_MESSAGES
      msgfmt -o $out/share/locale/$lang/LC_MESSAGES/hylki.mo "$po"
    done
  '';

  meta = {
    description = "GNOME-native email client with IMAP/SMTP and OAuth";
    homepage = "https://hylki.hyprlab.co";
    changelog = "https://github.com/hyprlab/hylki/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Plus;
    maintainers = [ ];
    mainProgram = "hylki";
    platforms = lib.platforms.linux;
  };
})
