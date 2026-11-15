# Upstream publishes Linux AppImages. The window and launcher icon is
# assets/icon.png from the same tag (1024x1024), not a resized stand-in.
{
  lib,
  stdenv,
  appimageTools,
  fetchurl,
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

  appimageContents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm644 ${appimageContents}/*.desktop -t $out/share/applications
    install -Dm644 ${icon} $out/share/icons/hicolor/1024x1024/apps/${pname}.png
    for f in $out/share/applications/*.desktop; do
      sed -i \
        -e 's|^Exec=.*|Exec=${pname} %U|' \
        -e 's|^Icon=.*|Icon=${pname}|' \
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
