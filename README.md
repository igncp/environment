# Environment

This repo contains my personal environment configurations

It is mostly bash scripts and configuration files

It tries to automate the most number of tasks and make the updates as fast as possible

The focus is in:

- Productivity
- Simplicity
- Maintainablity

Some approaches are not usual, but this setup has already been very convinient:

- creating the content of files from the scripts instead of having dotfiles: minimizing the configuration points boosts productivity
- having a big script file (~ 4k lines) instead of many smaller ones: one file eases editing and search, and 4k is not too many lines
- code duplication in scripts: no interdependencies between scripts, very simple maintainability
- output commands from scripts instead of calling them: creating scripts that can be called FZF improves the terminal productivity

## License

MIT
