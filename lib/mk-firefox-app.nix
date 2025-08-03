pkgs:
{
  url,
  name,
  prefs ? { },
  extensions ? [ ],
  extraArgs ? [ ],
  makeDesktopItemArgs ? { },
  firefoxBin ? pkgs.lib.getExe pkgs.firefox,
}:

let
  prefsFile =
    let
      prefs' =
        prefs // pkgs.lib.optionalAttrs (extensions != [ ]) { "extensions.autoDisableScopes" = 0; };
    in
    pkgs.writeText "firefox-webapp-profile-${name}-prefs.js" (
      "\n"
      + pkgs.lib.concatMapAttrsStringSep "\n" (
        pref: val: "user_pref(\"${pref}\", ${builtins.toJSON val}); "
      ) prefs'
    );

  combinedPrefs = pkgs.concatTextFile {
    name = "firefox-webapp-profile-${name}-combined-prefs";
    files = [
      "${pkgs.quick-webapps.src}/data/runtime/firefox/profile/user.js"
      prefsFile
    ];
    destination = "/user.js";
  };

  combinedExtensions =
    let
      # This extension prefix is shared among all Firefox extension
      # packages; comments in the home-manager Firefox module suggest
      # this may change.
      extensionPrefix = "share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}";
    in
    pkgs.buildEnv {
      name = "firefox-webapp-extensions-${name}";
      paths = map (ex: "${ex}/${extensionPrefix}") extensions;
      extraPrefix = "/extensions";
    };

  profile = pkgs.buildEnv {
    name = "firefox-webapp-profile-${name}";
    paths = [
      combinedPrefs
      "${pkgs.quick-webapps.src}/data/runtime/firefox/profile"
      combinedExtensions
    ];
    ignoreCollisions = true;
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

  passthru = { inherit profile; };
}
