{
  description = "Browser-based webapps using nix";

  outputs =
    { self, ... }:
    {
      overlays = {
        default = final: prev: {
          nix-webapp-lib = {
            mkChromiumApp = import ./lib/mk-chromium-app.nix prev;
          };
        };

        # For backwards compatibility, since the overlay used to be
        # named literally "lib".
        lib = self.overlays.default;
      };
    };
}
