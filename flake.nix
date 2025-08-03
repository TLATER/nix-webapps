{
  description = "Browser-based webapps using nix";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { self, nixpkgs, ... }@inputs:
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

      checks.x86_64-linux = import ./checks {
        inherit inputs;
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
      };
    };
}
