# Environment

This repo contains my personal environment configurations and some dev notes.

It is composed of scripts that provision the environment by installing
programs, generating config files, etc. Running the provision should be
idempotent where possible, so running it multiple times should leave the system
in the same state as the first time.

By design (to decrease compilation times) the provision script has no crates as
dependencies. The utility scripts that don't change often, which are compiled
separately, can have dependencies, like crates, npm modules, etc.

## License

MIT
