# Environment

This repo contains my personal environment configurations

It is mostly bash scripts and configuration files

It tries to automate the most number of tasks and make the updates as fast as possible

The focus is in:

- Productivity
- Simplicity
- Maintainability

Some approaches are not usual, but this setup has already been very convinient:

- Creating the content of files from the scripts instead of having dotfiles
    - Minimizing the configuration points boosts productivity
- Having a big script file (~ 4k lines) instead of many smaller ones
    - One file eases editing and search, and 4k is not too many lines
- Having code duplication in scripts
    - No interdependencies between scripts, very simple maintainability
- Output commands from scripts instead of calling them
    - Creating scripts that can be used for FZF improves the terminal productivity

## License

MIT
