# Packaged from the official AppImage. Named zen-browser-app so it does not
# shadow a future zen-browser attribute in nixpkgs when used as an overlay.
{
  lib,
  stdenv,
  appimageTools,
  fetchurl,
}:

let
  pname = "zen-browser-app";
  version = "1.24b";

  sources = {
    x86_64-linux = fetchurl {
      url = "https://github.com/zen-browser/desktop/releases/download/${version}/zen-x86_64.AppImage";
      hash = "sha256-xesF42xf/cLYwgtE5HA/JeDyhhGOWbqQP4LSEhtKfic=";
    };
    aarch64-linux = fetchurl {
      url = "https://github.com/zen-browser/desktop/releases/download/${version}/zen-aarch64.AppImage";
      hash = "sha256-6pC3awuh0z//MAQt+WV4hxzzAKoovkWm1tDWQ27zzek=";
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
    description = "Firefox-based browser focused on privacy and customization";
    homepage = "https://zen-browser.app";
    license = lib.licenses.mpl20;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = builtins.attrNames sources;
    mainProgram = pname;
  };
}
