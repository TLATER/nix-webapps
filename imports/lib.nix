{ ... }:

{
  flake = {
    overlays.lib = (
      final: prev: {
        nix-webapps-lib = {
          mkChromiumApp =
            args:
            (prev.stdenvNoCC.mkDerivation (finalAttrs: {
              pname = "chromium-app-${finalAttrs.appName}";
              version = "1.0.0";

              buildInputs = [ prev.chromium ];

              nativeBuildInputs = [
                prev.makeBinaryWrapper
                prev.copyDesktopItems
              ];

              dontUnpack = true;
              dontConfigure = true;
              dontBuild = true;

              installPhase = ''
                runHook preInstall
                makeWrapper ${prev.lib.getExe prev.chromium} $out/bin/${finalAttrs.appName} \
                  --add-flags "--enable-features=UseOzonePlatform,WebRTCPipeWireCapturer,WebUIDarkMode" \
                  --add-flags "--ozone-platform-hint=auto" \
                  --add-flags "--disable-sync-preferences" \
                  --add-flags "--user-data-dir=\$XDG_CONFIG_HOME/chromium-${finalAttrs.appName}" \
                  --add-flags "--app=${finalAttrs.url}"
                runHook postInstall
              '';

              desktopItems = [
                (prev.makeDesktopItem {
                  name = finalAttrs.appName;
                  exec = finalAttrs.appName;
                  icon = finalAttrs.icon or finalAttrs.appName;
                  desktopName = finalAttrs.desktopName or finalAttrs.appName;
                  genericName = finalAttrs.genericName or finalAttrs.appName;
                  categories = finalAttrs.categories or [ ];
                  startupWMClass = finalAttrs.class or finalAttrs.appName;
                })
              ];
            })).overrideAttrs
              (args);
        };
      }
    );
  };
}
