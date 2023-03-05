# Environment

This repo contains my personal environment configurations and some dev notes.

It is composed of mostly bash scripts and configuration files.

It tries to automate the most number of tasks and make the updates as fast as
possible.

The focus is in:

- Productivity
- Simplicity
- Maintainability

Some of the principles in the repository:

- Creating the content of configuration files from bash and rust scripts instead of from having dotfiles
    - Minimizing the configuration points boosts productivity
- Having a core big script file (~ 6k lines)
    - One file eases editing and search
- Having code duplication in toolbox scripts
    - No interdependencies between scripts, very simple maintainability
- Running the whole provision script should be very quick (less than five seconds)
    - Have fast checks to confirm if related files or directories already exist
    - Complex logic is in rust scripts, which are readable and fast

## License

MIT
