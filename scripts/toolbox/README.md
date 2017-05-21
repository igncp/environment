The scripts in these directories must follow the following rules:

- If no arguments are passed, they will output the script file path or the external command with the default arguments. This is useful for combination with FZF and bash expansion, and at the same time, be able to repeat the last script with different arguments.
- Must be runnable from outside the script directory.
- Must not depend on other scripts from this repo. This is strong and has some implications, one is that it will generate code duplication. However, this duplication will be local and it will come with the benefit of less complexity and a lot better mantainability.
- Must list the important external dependencies at the top of the file.
- There is no language restriction, but generally they will be written for bash unless their complexity is high enough to favor other solutions.
