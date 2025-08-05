# nix-webapps

Easily create single-page webapps, powered by your normal browser,
instead of an outdated homebrew chromium shipped with electron.

Very similar in idea to COSMIC's
[quick-wbapps](https://github.com/cosmic-utils/web-apps), except the
created applications don't need to be managed with a GUI tool, and are
simply declaratively installed, just like any normal nix package.

## Installation

Since this project exposes its functionality entirely as a library of
builder functions, it has to be used as an overlay (even with flakes,
as there is no standard output for exposing builder functions yet).

### With flakes

Add to your flake inputs:

```nix
# Note that overriding recursive inputs with `.follows` is not
# necessary; this repository uses its inputs only for testing with
# `checks`.
nix-webapps.url = "github:TLATER/nix-webapps";
```

Then, overlay your platform's `pkgs` with the overlay:

```nix
{ inputs, ... }: {
  # NixOS' configuration.nix
  nixpkgs.overlays = [
    inputs.nix-webapps.overlays.default
  ];
}
```

### Without flakes

Importing the project is out of scope due to the many ways this could
be achieved, however we recommend using
[niv](https://github.com/nmattia/niv).

The `overlay.nix` file in this repository can be used as follows:

```nix
{ sources, ...}: {
  nixpkgs.overlays = [
    (import "${sources.nix-webapps}/overlay.nix")
  ];
}
```

## Usage

The project consists of two builders, `mkChromiumApp` and
[`mkFirefoxApp`](./lib/mk-firefox-app.nix#2). Click the links to see
in-code reference docs.

Both are builder functions that create standard nix packages which can
simply be added to `environment.systemPackages` or `home.packages`.

### mkFirefoxApp

An example says more than a thousand words, this creates, for example,
an app for Discord:

```nix
# configuration.nix
{ pkgs, ... }: let
  discord = mkFirefoxApp {
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
in {
  environment.systemPackages = [
    discord
  ];
}
```

The resulting package will add both a `discord` binary to `$PATH`, as
well as a `.desktop` file to the system applications folder, which
should show up in application launchers as usual.

Extensions from rycee's [NUR
repo](https://nur.nix-community.org/repos/rycee/) can be added, as
demonstrated.

Unfortunately getting Firefox to open links in your normal browser is
not possible; copying links out is the best alternative. Alt+1-9 can
be used to switch tabs even without the UI if you get stuck.

## Contributing

Contributions are welcome! See [CONTRIBUTING.md](./CONTRIBUTING.md)
for hints on how the repository works, and what you should do to get
patches approved.
