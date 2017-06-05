# Vagrant Personal Cookbook

Points to consider before using any of the content:

- The objective is to copy-paste what you need, picking the relevant parts, in opposition to cloning the repository in order to execute them. In this way they don't require backwards compatibility

- They are designed and tested under [Arch Linux](https://www.archlinux.org/)

Some of the conventions they take into account are:

- Running the scripts multiple times should result in the same state as running them once (except when they don't end successfully)

- The scripts should favor performance over being up to date in external packages, the dotfiles are copied always. Only the very fast operations are run always without checks

- The shared directory is `/project` in the guest machine, and it has the following structure

```
/project
  Vagrantfile
  provision/
    provision.sh
    ...
  scripts/
    ...
  src/
    ...
  ...
```

- Normally `provision.sh` is the only file under the `provision` directory, and contains all the provisions in a single file, so it is easier to reason about. The reason to be a directory is to place configuration files that can be copy-pasted directly (e.g. `apache.conf`).

- The order of the provisioners inside `provision.sh` is `general.sh` as first, then `vim.sh`, and then the rest, being `custom.sh` the last one, to separate custom tweaks so it is easier to update the rest of the provisioners by replacing them.

- The `/vm-shared` directory in the guest points to `~/vm-shared` in the host, and it is shared between all the VMs.

## License

MIT
