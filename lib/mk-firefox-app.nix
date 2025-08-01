pkgs:
{
  url,
  name,
  extraArgs ? [ ],
  makeDesktopItemArgs ? { },
  firefoxBin ? pkgs.lib.getExe pkgs.firefox,
}:

let
  profile = pkgs.buildEnv {
    name = "firefox-webapp-profile-${name}";
    paths = [ "${pkgs.quick-webapps.src}/data/runtime/firefox/profile" ];
  };

  binary = pkgs.writers.writeNuBin name {
    makeWrapperArgs = [
      "--prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.xorg.lndir ]}"
      "--set WEBAPP_EXE ${firefoxBin}"
      "--set WEBAPP_NAME ${name}"
      "--set WEBAPP_URL ${url}"
      "--set WEBAPP_PROFILE_TEMPLATE ${profile}"
    ]
    ++ pkgs.lib.optional (
      extraArgs != [ ]
    ) "--set WEBAPP_ARGS ${pkgs.lib.concatStringsSep " " extraArgs}";
  } ./firefox-webapp.nu;

  desktopItem = pkgs.makeDesktopItem (
    pkgs.lib.recursiveUpdate
      {
        name = "net.tlater.nix_webapp.firefox.${name}";
        desktopName =
          (pkgs.lib.toUpper (builtins.substring 0 1 name))
          + (builtins.substring 1 (builtins.stringLength name) name);
        exec = pkgs.lib.getExe binary;

        startupNotify = true;
        terminal = false;
        type = "Application";

        startupWMClass = "net.tlater.nix_webapp.firefox.${name}";
      }

      makeDesktopItemArgs
  );
in
pkgs.buildEnv {
  name = "firefox-webapp-${name}";
  paths = [
    binary
    desktopItem
  ];

  meta.mainProgram = name;
}
