{ inputs, pkgs }:
let
  inherit (inputs.self.overlays.default pkgs pkgs) nix-webapp-lib;

  mkTestMachine = webapp: {
    imports = [ "${inputs.nixpkgs}/nixos/tests/common/x11.nix" ];
    environment.systemPackages = [ webapp ];
  };

  testPage = pkgs.writeText "test.html" ''
    <html>
      <head>
        <title>Test Webapp</title>
      </head>
      <body>
        <h1>Hello World!</h1>
      </body>
    </html>
  '';
in
{
  firefox =
    let
      webapp = nix-webapp-lib.mkFirefoxApp {
        url = "file://${testPage}";
        name = "webapp";
      };
    in
    pkgs.testers.runNixOSTest {
      name = "run-firefox-webapp";
      nodes.machine = mkTestMachine webapp;
      enableOCR = true;

      testScript = ''
        machine.wait_for_x()
        machine.execute("xterm -e 'webapp; sleep 20' >&2 &")
        machine.wait_for_window("Test Webapp", 20)
        machine.screenshot("webapp")

        # If the window is rendered with the browser bar visible,
        # `test.htm` will be part of the url and therefore visible
        # on-screen. Hence, this is a pretty good way to ensure the
        # UI-hiding features are working.
        #
        # We avoid including the `l` of `html`, because it may be read
        # as a 1 by the OCR.
        assert "test.htm" not in machine.get_screen_text_variants()[0]
      '';
    };

  firefox-with-custom-prefs =
    let
      webapp = nix-webapp-lib.mkFirefoxApp {
        url = "file://${testPage}";
        name = "webapp";
        prefs = {
          "app.shield.optoutstudies.enabled" = false;
        };
      };
    in
    pkgs.testers.runNixOSTest {
      name = "run-firefox-webapp-custom-prefs";
      nodes.machine = mkTestMachine webapp;

      testScript = ''
        machine.wait_for_x()
        machine.execute("xterm -e 'webapp; sleep 20' >&2 &")
        machine.wait_for_window("Test Webapp", 20)
        machine.succeed("grep app.shield.optoutstudies.enabled ~/.local/share/firefox-webapps/webapp/user.js")
      '';
    };

  firefox-with-extensions =
    let
      nur = (inputs.nurpkgs.overlays.default pkgs pkgs).nur;

      webapp = nix-webapp-lib.mkFirefoxApp {
        url = "about:addons";
        name = "webapp";
        prefs = {
          "extensions.htmlaboutaddons.recommendations.enabled" = false;
          "extensions.ui.lastCategory" = "addons://list/extension";
        };
        extensions = [ nur.repos.rycee.firefox-addons.ublock-origin ];
      };
    in
    pkgs.testers.runNixOSTest {
      name = "run-firefox-webapp-extensions";
      nodes.machine = mkTestMachine webapp;
      enableOCR = true;

      testScript = ''
        machine.wait_for_x()
        machine.execute("xterm -e 'webapp; sleep 20' >&2 &")
        machine.wait_for_window("Add-ons Manager", 20)
        machine.screenshot("webapp")
        assert "uBlock Origin" in machine.get_screen_text_variants()[0]
      '';
    };
}
