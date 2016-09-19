# Vagrant Personal Cookbook

Collection of scripts (provision, etc.) and dotfiles for Vagrant for personal reference. The idea is to copy-paste them, pick the relevant parts, and NOT to clone the repository to execute them. The scripts are tested in Ubuntu boxes

They scripts follow the next points:

- Running the scripts multiple times should end in the same state as running them once (except when they don't end successfully)
- They should favor performance over being up to date in external packages, the dotfiles are copied always

Some of the conventions they take into account are:

- The shared directory is under `/project` and at least has the following structure

```
/project
  Vagrantfile
  /provision
    main.sh
    .bashrc
    ...
  /scripts
    ...
  ...
```

## License

MIT

