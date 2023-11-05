# Alpine Linux installation notes and scripts

# During installation, choose the disk for where to install the system.
# Choose the `sys` option during the installation.

# Enable the community repository:
apk add vim
vim /etc/apk/repositories # Uncomment the community repository

# Display services:
rc-status
rc-service --list

# Enable port forwarding in /etc/ssh/sshd_config (disabled by default in Alpine)
# After:
rc-service sshd restart

# Packages to install initially
# - xz: Required for the nix installation to unpack the nix package
# - ncurses: Required by oh-my-zsh plugins
# - less: The default less from busybox doesn't print colors correctly
apk add bash bash-completion rsync curl xz ncurses less
# Recommended general utilities: https://wiki.alpinelinux.org/wiki/How_to_get_regular_stuff_working
sudo apk add util-linux coreutils binutils findutils grep

# Required by the `nix` installation, it includes `groupadd`
sudo apk add shadow sudo docker docker-compose openrc

sudo rc-update add docker default

# Edit the `/etc/sudoers` file and uncomment the line where it allows the `wheel` group to use `sudo`
# The user should already be in the `wheel` group

# Use `su` if initially logged as the created user (not root)

# Manually change the shell from `ash` to `bash` by `vim /etc/passwd`

# Using nix: https://gist.github.com/danmack/b76ef257e0fd9dda906b4c860f94a591

# After first provision, will have to `. ~/.bashrc` and then change the shell to ZSH

# To read the system messages: `less /var/log/messages`
