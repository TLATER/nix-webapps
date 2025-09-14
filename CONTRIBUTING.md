# Contributing

Please:

1. Format your code with
   [nixfmt-rfc-style](https://github.com/NixOS/nixfmt)
2. Follow [conventional commits](https://www.conventionalcommits.org/en/v1.0.0/)
3. Create linear history, i.e., don't merge, rebase
4. Write tests

## Testing your changes

The subflake in the `checks` directory contains `checks`, which run
the browsers in a VM and asserts things about the windows they open.

The [NixOS test
infrastructure](https://nixos.org/manual/nixos/stable/#sec-nixos-tests)
is used for this. Using it *should* probably be out of scope for
documentation in this repository, but the upstream docs are scarce, so
here is nonetheless some info:

When working on the VM tests, knowing about the `driverInteractive`
passthru is essential. This is a basic feature of `runNixosTest` -
`nix run .#checks.x86_64-linux.<name>.driverInteractive` will bring up
a python shell in which the node objects are available as usual.

Running e.g. `machine.wait_for_x()` will bring up a qemu window with
an actively running test VM - in here you can do everything you'd like
to test.

Converting the result of that to a real test then just means writing a
bit of Python. Here, still, the interactive python shell is very
useful - you can simply run any commands you would expect to run in
the test in your shell, and see what they do.

## Working on the builders

### Firefox

1. Each test also contains a `passthru.testPackage` - this exports the
   package that the test uses.

   This can be used to build *just* the webapp under test so that full
   VM testing isn't necessary - very useful during development if you
   don't want the overhead of spinning up a VM every time you make a
   small change.

   Simply run `nix build .#checks.x86_64-linux.<name>.testPackage`,
   and then the output is available under `result/`. This should be
   done instead of exposing full packages under a new `packages`
   output - this repository should never export actual packages, we
   don't want to maintain a package set here.

2. The Firefox packages also contain a `passthru.profile`, which can
   similarly be used to check what the profile template for the webapp
   contains.
