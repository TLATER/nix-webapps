{
  description = "nix-webapps tests";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nurpkgs.url = "github:nix-community/NUR";

    nix-webapps.url = "../.";
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      platforms = nixpkgs.legacyPackages.x86_64-linux.firefox.meta.platforms;
      forAllSystems = nixpkgs.lib.genAttrs platforms;
    in
    {
      checks = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        pkgs.lib.mergeAttrsList [ (import ./firefox.nix { inherit inputs pkgs; }) ]
      );
    };
}
