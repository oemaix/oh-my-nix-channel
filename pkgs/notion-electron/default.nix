{
  lib,
  stdenv,
  appimageTools,
  fetchurl,
}:

let
  pname = "notion-electron";
  version = "2.4.0";

  sources = {
    x86_64-linux = fetchurl {
      url = "https://github.com/anechunaev/notion-electron/releases/download/v${version}/Notion_Electron-${version}-x86_64.AppImage";
      hash = "sha256-jpEQb4k7nWGefzspAPppxisJMlmBNUxRwSfHsylaQKY=";
    };
    aarch64-linux = fetchurl {
      url = "https://github.com/anechunaev/notion-electron/releases/download/v${version}/Notion_Electron-${version}-arm64.AppImage";
      hash = "sha256-m4zFP5K85Y5vbdSDJ6Vh+xAtgi2138yY9djvk2qqWeA=";
    };
  };

  src =
    sources.${stdenv.hostPlatform.system}
      or (throw "${pname}: unsupported system ${stdenv.hostPlatform.system}");

  appimageContents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm644 ${appimageContents}/*.desktop -t $out/share/applications
    for f in $out/share/applications/*.desktop; do
      sed -i 's/^Exec=.*/Exec=${pname} %U/' "$f"
    done
    if [ -d ${appimageContents}/usr/share/icons ]; then
      mkdir -p $out/share
      cp -r ${appimageContents}/usr/share/icons $out/share/
    fi
  '';

  meta = {
    description = "Unofficial Notion desktop client for Linux";
    homepage = "https://github.com/anechunaev/notion-electron";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = builtins.attrNames sources;
    mainProgram = pname;
  };
}
