pkgs: args:
(pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "chromium-app-${finalAttrs.appName}";
  version = "1.0.0";

  buildInputs = [ pkgs.chromium ];

  nativeBuildInputs = [
    pkgs.makeShellWrapper
    pkgs.copyDesktopItems
  ];

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    makeWrapper ${pkgs.lib.getExe pkgs.chromium} $out/bin/${finalAttrs.appName} \
      --add-flags "--enable-features=UseOzonePlatform,WebRTCPipeWireCapturer,WebUIDarkMode" \
      --add-flags "--ozone-platform-hint=auto" \
      --add-flags "--profile-directory=${args.profile or "Default"}" \
      --add-flags "--disable-sync-preferences" \
      --add-flags "--user-data-dir=\$XDG_CONFIG_HOME/chromium-${finalAttrs.appName}" \
      --add-flags "--app=${finalAttrs.url}"
    runHook postInstall
  '';

  desktopItems = [
    (pkgs.makeDesktopItem {
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
  (args)
