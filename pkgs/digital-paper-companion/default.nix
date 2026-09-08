{
  lib,
  appimageTools,
  fetchurl,
}:

let
  pname = "digital-paper-companion";
  # Upstream tags releases as v<version>-<build>.
  version = "0.4.1-1";

  src = fetchurl {
    url = "https://github.com/oemaix/digital-paper-companion/releases/download/v${version}/Digital.Paper.Companion_${version}_amd64.AppImage";
    hash = "sha256-YCi9m5ryW/Hag8IUKHvJ8R0q/VWJxac5i1//la7bOoo=";
  };

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
    description = "Desktop companion for Sony Digital Paper (DPT-RP1/CP1) and Fujitsu Quaderno";
    homepage = "https://github.com/oemaix/digital-paper-companion";
    license = with lib.licenses; [
      asl20
      mit
    ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = pname;
  };
}
