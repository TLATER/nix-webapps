# nix-webapps

Low-effort web "apps" with nix!

## Usage

1. **Add the Repository as an Input**:

   Add the following to your `flake.nix` file to include this repository as an input:

   ```nix
   inputs = {
     nix-webapps.url = "github:TLATER/nix-webapps";
   };
   ```

2. **Include the overlay in your NixOS configuration**:

   ```nix
   nixpkgs.overlays = [
     inputs.nix-webapps.overlays.default
   ];
   ```

3. **Build or simply install your apps**:

   ```nix
   environment.systemPackages = [
     pkgs.nix-webapps.electron
     (pkgs.nix-webapps.lib.mkChromiumApp {
       appName = "teams";
       desktopName = "Microsoft Teams";
       icon = ./Microsoft_Office_Teams.svg;
       url = "https://teams.microsoft.com";
       class = "chrome-teams.microsoft.com__-Default";
     })
   ];
   ```

## Contributing

Feel free to contribute by sending pull requests. We are a usually very
responsive team and we will help you going through your pull request from the
beginning to the end.
