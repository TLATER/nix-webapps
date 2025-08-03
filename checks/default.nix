{ inputs, pkgs }: pkgs.lib.mergeAttrsList [ (import ./firefox.nix { inherit inputs pkgs; }) ]
