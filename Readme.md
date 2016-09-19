# Vagrant Personal Cookbook

Points to consider before using any of the content:

- The objective is to copy-paste what you need, picking the relevant parts, in opposition to cloning the repository in order to execute them. In this way they don't require backwards compatibility

- They are tested under Ubuntu boxes

Some of the conventions they take into account are:

- Running the scripts multiple times should result in the same state as running them once (except when they don't end successfully)

- The scripts should favor performance over being up to date in external packages, the dotfiles are copied always. Only the very fast operations are run always without checks

- The shared directory is `/project` in the guest machine, and it has the following structure

```
/project
  Vagrantfile
  /provision
    main.sh
    .bashrc
    ...
  /scripts
    ...
  /src
    ...
  ...
```

## License

MIT

