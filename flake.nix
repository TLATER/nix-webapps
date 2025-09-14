{
  description = "Browser-based webapps using nix";

  outputs =
    { self }:
    {
      overlays = {
        default = import ./overlay.nix;

        # For backwards compatibility, since the overlay used to be
        # named literally "lib".
        lib = self.overlays.default;
      };
    };
}
