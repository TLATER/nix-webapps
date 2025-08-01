{
  description = "Browser-based webapps using nix";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { self, nixpkgs, ... }:
    {
      overlays = {
        default = final: prev: {
          nix-webapp-lib = {
            mkChromiumApp = import ./lib/mk-chromium-app.nix prev;
            mkFirefoxApp = import ./lib/mk-firefox-app.nix prev;
          };
        };

        # For backwards compatibility, since the overlay used to be
        # named literally "lib".
        lib = self.overlays.default;
      };

      packages.x86_64-linux.firefox-discord =
        (self.overlays.default nixpkgs.legacyPackages.x86_64-linux nixpkgs.legacyPackages.x86_64-linux)
        .nix-webapp-lib.mkFirefoxApp
          {
            name = "discord";
            url = "https://discord.com/app";
          };
    };
}
