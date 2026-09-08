# Msty Studio is proprietary; consumers need `nixpkgs.config.allowUnfree = true`.
{
  lib,
  appimageTools,
  fetchurl,
}:

let
  pname = "msty-studio";
  version = "2.0.0";

  src = fetchurl {
    url = "https://next-assets.msty.studio/app/releases/${version}/linux/MstyStudio_x86_64.AppImage";
    hash = "sha256-syY2+L00SMZonqNgWrcX9aFQmWiTkU51bbSVQE/1ltQ=";
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
    description = "Desktop app for working with local and online AI models";
    homepage = "https://msty.ai/products/studio/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = pname;
  };
}
