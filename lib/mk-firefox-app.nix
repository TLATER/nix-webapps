pkgs:
/**
  Builds a Firefox-based one-page webapp.

  # Example

  ```nix
  mkFirefoxApp {
    name = "discord";
    url = "https://discord.com/app";

    prefs = {
      "extensions.htmlaboutaddons.recommendations.enabled" = false;
    };

    extensions = [ pkgs.nur.repos.rycee.firefox-addons.ublock-origin ];

    makeDesktopItemArgs = {
      comment = "All-in-one voice and text chat for gamers that's free, secure, and works on both your desktop and phone.";
      genericName = "Internet Messenger";
      categories = [
        "Network"
        "InstantMessaging"
      ];
    };
  }
  ```

  # Type

  ```
  mkFirefoxApp :: AttrSet -> Derivation
  ```

  # Arguments

  url
  : The URL that will be opened in the browser as a webapp.

  name
  : The name of the webapp. This will be used to name the binary, and
    will by default be capitalized and used as the name in the
    `.desktop` file.

  prefs
  : Firefox user preferences to set. This matches the settings in the
    `about:config` page.

  extensions
  : Firefox extensions to install. This expects Firefox addons packaged
    as in [rycee's NUR
    repo](https://nur.nix-community.org/repos/rycee/).

  extraArgs
  : Additional arguments to add to the Firefox CLI.

  makeDesktopItemArgs
  : Arguments to pass to the `makeDesktopItem` invocation.

  firefoxBin
  : The Firefox binary to use. This can be used to instead invoke the
    webapp with e.g. librewolf. The browser used must be compatible with
    Firefox profiles and its CLI interface for this to work.
*/
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
      prefs' = pkgs.lib.mergeAttrsList [
        prefs
        { "browser.startup.page" = 0; }
        (pkgs.lib.optionalAttrs (extensions != [ ]) { "extensions.autoDisableScopes" = 0; })
      ];
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
