final: prev: {
  nix-webapp-lib = {
    mkChromiumApp = import ./lib/mk-chromium-app.nix prev;
    mkFirefoxApp = import ./lib/mk-firefox-app.nix prev;
  };
}
