# Environment

This repo contains my personal environment configurations and some dev notes.

It is composed of scripts that provision the environment by installing
programs, generating config files, etc. Running the provision should be
idempotent where possible, so running it multiple times should leave the system
in the same state as the first time.

By design (to decrease compilation times) the provision script has no crates as
dependencies. The utility scripts that don't change often, which are compiled
separately, can have dependencies, like crates, npm modules, etc.

The sections are:

- Bash provision scripts in [src](./src)
- Nix configuration in [nix](./nix) for NixOS and [Home Manager](https://github.com/nix-community/home-manager) (used in other Unix operating systems)
    - For both cases the main entry point is the [flake.nix](./flake.nix) file
- Lua files for the neovim config in [src/lua](./src/lua/)
- Dot and config files in [src/config-files](./src/config-files)
- Some rust and bash CLI applications in [src/scripts](src/scripts)
- Additionally there are some [personal notes](./notes)

## License

MIT
