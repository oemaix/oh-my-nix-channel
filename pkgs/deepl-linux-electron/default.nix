{
  lib,
  appimageTools,
  fetchurl,
}:

let
  pname = "deepl-linux-electron";
  version = "1.6.1";

  src = fetchurl {
    url = "https://github.com/kumakichi/Deepl-linux-electron/releases/download/v${version}/Deepl-Linux-Electron-${version}.AppImage";
    hash = "sha256-MMXdzrLA5BF8WlcIF3+kCVuWXZ94yVp/71+iATjPuSw=";
  };

  appimageContents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm644 ${appimageContents}/*.desktop -t $out/share/applications
    install -Dm644 ${./icon.svg} $out/share/icons/hicolor/scalable/apps/${pname}.svg
    for f in $out/share/applications/*.desktop; do
      sed -i \
        -e 's/^Exec=.*/Exec=${pname} %U/' \
        -e 's/^Icon=.*/Icon=${pname}/' \
        "$f"
    done
  '';

  meta = {
    description = "Unofficial DeepL translator desktop client for Linux";
    homepage = "https://github.com/kumakichi/Deepl-linux-electron";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = pname;
  };
}
