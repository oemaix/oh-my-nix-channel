# Upstream publishes Linux AppImages. The launcher icon is assets/icon.png
# from the same tag. hicolor-icon-theme 0.18 has no 1024x1024 directory, and
# its 512x512/apps entry only matches requests of 64px and up, so the original
# PNG is resized into the theme sizes the app list actually looks up.
{
  lib,
  stdenv,
  appimageTools,
  fetchurl,
  runCommand,
  imagemagick,
}:

let
  pname = "lv-desktop";
  version = "0.4.0";

  sources = {
    x86_64-linux = fetchurl {
      url = "https://github.com/oemaix/lv-desktop/releases/download/v${version}/lv-desktop-${version}.AppImage";
      hash = "sha256-M38/M1FXLvxRdvtfoIggaaw8mSY/QjJ5/vb+/5VW+bQ=";
    };
    aarch64-linux = fetchurl {
      url = "https://github.com/oemaix/lv-desktop/releases/download/v${version}/lv-desktop-${version}-arm64.AppImage";
      hash = "sha256-3uO6unONEYBwSLfc6/JrXK5zLguns8SJvZxWxE/FDGM=";
    };
  };

  src =
    sources.${stdenv.hostPlatform.system}
      or (throw "${pname}: unsupported system ${stdenv.hostPlatform.system}");

  icon = fetchurl {
    url = "https://raw.githubusercontent.com/oemaix/lv-desktop/v${version}/assets/icon.png";
    hash = "sha256-cNk4x59TL45XD7JhVL2qsSmXkvrx8+TbMNiudTQpa+E=";
  };

  # Sizes listed as apps directories in hicolor-icon-theme 0.18.
  icons = runCommand "lv-desktop-icons" { nativeBuildInputs = [ imagemagick ]; } ''
    for size in 16 22 24 32 36 48 64 72 96 128 192 256 512; do
      mkdir -p "$out/share/icons/hicolor/''${size}x''${size}/apps"
      magick ${icon} -resize "''${size}x''${size}" \
        "$out/share/icons/hicolor/''${size}x''${size}/apps/${pname}.png"
    done
    mkdir -p "$out/share/pixmaps"
    magick ${icon} -resize 512x512 "$out/share/pixmaps/${pname}.png"
  '';

  appimageContents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm644 ${appimageContents}/*.desktop -t $out/share/applications
    mkdir -p $out/share
    cp -a ${icons}/share/. $out/share/
    for f in $out/share/applications/*.desktop; do
      sed -i \
        -e 's|^Exec=.*|Exec=${pname} %U|' \
        -e 's|^Icon=.*|Icon=${pname}|' \
        -e 's|^Name=.*|Name=LV Desktop|' \
        "$f"
    done
  '';

  meta = {
    description = "Unofficial desktop client for Lingvist";
    homepage = "https://github.com/oemaix/lv-desktop";
    changelog = "https://github.com/oemaix/lv-desktop/releases/tag/v${version}";
    license = lib.licenses.gpl3Only;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [ ];
    mainProgram = pname;
    platforms = builtins.attrNames sources;
  };
}
