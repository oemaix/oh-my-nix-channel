# Upstream publishes Linux AppImages. The launcher icon is assets/icon.png
# from the same tag. Electron 42+ overwrites CHROME_DESKTOP during startup
# with package.json desktopName, or with a slug of productName/name when
# that field is absent. This package has no desktopName, so the Wayland
# app id is lv-desktop. GNOME uses the desktop file's icon only when that
# id matches the file name and StartupWMClass. The source PNG is 1024x1024
# and hicolor-icon-theme has no 1024 slot, so it is resized into the
# 512x512 slot the theme searches.
{
  lib,
  stdenv,
  appimageTools,
  fetchurl,
  writeText,
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

  icon512 = runCommand "lv-desktop-icon" { nativeBuildInputs = [ imagemagick ]; } ''
    mkdir -p $out
    magick ${icon} -resize 512x512 $out/${pname}.png
  '';

  desktopItem = writeText "${pname}.desktop" ''
    [Desktop Entry]
    Name=LV Desktop
    Comment=Single-window Lingvist desk client
    Exec=${pname} %U
    Terminal=false
    Type=Application
    Icon=${pname}
    StartupWMClass=${pname}
    Categories=Education;
  '';

in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm644 ${desktopItem} $out/share/applications/${pname}.desktop
    install -Dm644 ${icon512}/${pname}.png \
      $out/share/icons/hicolor/512x512/apps/${pname}.png
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
