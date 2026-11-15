# Upstream publishes Linux AppImages. The launcher icon is assets/icon.png
# from the same tag. Electron publishes a Wayland app id only when
# CHROME_DESKTOP is set; otherwise the window class stays "Electron" and
# GNOME never opens this desktop file for the dash icon. The id is the
# upstream electron-builder appId. The desktop file and the icon use that
# same name. The source PNG is 1024x1024 and hicolor-icon-theme has no
# 1024 slot, so that file is installed in the 512x512 slot the theme searches.
{
  lib,
  stdenv,
  appimageTools,
  fetchurl,
  writeText,
}:

let
  pname = "lv-desktop";
  version = "0.4.0";
  # package.json build.appId. GNOME looks up <id>.desktop and <id>.png.
  appId = "app.lvdesktop.client";

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

  desktopItem = writeText "${appId}.desktop" ''
    [Desktop Entry]
    Name=LV Desktop
    Comment=Single-window Lingvist desk client
    Exec=${pname} %U
    Terminal=false
    Type=Application
    Icon=${appId}
    StartupWMClass=${appId}
    Categories=Education;
  '';

in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm644 ${desktopItem} $out/share/applications/${appId}.desktop
    install -Dm644 ${icon} $out/share/icons/hicolor/512x512/apps/${appId}.png

    mv $out/bin/${pname} $out/bin/.${pname}-unwrapped
    echo "#!${stdenv.shell}" > $out/bin/${pname}
    echo "export CHROME_DESKTOP=${appId}.desktop" >> $out/bin/${pname}
    echo "exec $out/bin/.${pname}-unwrapped \"\$@\"" >> $out/bin/${pname}
    chmod +x $out/bin/${pname}
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
