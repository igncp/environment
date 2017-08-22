The scripts in this directory must follow the following rules:

- If no arguments are passed, they will output the script file path or the external command with the default arguments. This is useful for combination with FZF and bash expansion, and at the same time, being able to repeat the last script with different arguments. For more info, look into the FZF section in [general.sh](../../provision/general.sh), especially the key bindings.
- Must be runnable from outside the script directory, which is normally the case.
- Must not depend on other scripts from this repo. This is strong and has several implications, one is that it will generate code duplication. However, this duplication will be local and it will come with the benefit of less complexity and a lot better maintainability.
- Must list the important external dependencies at the top of the file. It is assumed that it requires fzf.
- There is no language restriction, but generally they will be written for bash unless their complexity is high enough to favor other solutions.
- Avoid too general filenames as they will be run using fzf, so the more specific, the faster to select.
