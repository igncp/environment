#     let users = fs::read_to_string("/etc/passwd").unwrap();

#     if !users.contains("igncp:") {
#         System::run_bash_command(
#             r###"
# useradd igncp -m
# echo "Change password on login"
# echo "igncp:igncp" | chpasswd
# chsh igncp -s /usr/bin/bash
# "###,
#         );
#     }

#     let sudoers = fs::read_to_string("/etc/sudoers").unwrap();
#     if !sudoers.contains("igncp") {
#         System::run_bash_command(
#             r###"
# echo "# igncp ALL=(ALL) ALL" >> /etc/sudoers
# echo "igncp ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers # For the initial installation
# "###,
#         );
#     }

#     System::run_bash_command(
#         r###"
# ufw allow ssh
# ufw --force enable
# "###,
#     );
#     let profile_file = fs::read_to_string("/etc/profile").unwrap();
#     if !profile_file.contains("umask") {
#         System::run_bash_command("echo 'umask 0077' >> /etc/profile");
#     }

#     if !Path::new("/home/igncp/development/environment").exists() {
#         System::run_bash_command(
#             r###"
# mkdir -p /home/igncp/development
# cp -r /root/development/environment /home/igncp/development/environment
# chown -R igncp:igncp /home/igncp/development
# "###,
#         );
#     }

#     if !Path::new("/home/igncp/.ssh").exists() {
#         System::run_bash_command(
#             r###"
# cp -r /root/.ssh /home/igncp/.ssh
# chown -R igncp:igncp /home/igncp/.ssh
# "###,
#         );
#     }

#     if !Path::new("/home/igncp/.cargo").exists() {
#         System::run_bash_command(
#             r###"
# sudo -u igncp bash -c "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"
# "###,
#         );
#     }

#     System::run_bash_command(
#         r###"
# sudo -u igncp bash -c "mkdir -p ~/.check-files && touch ~/.check-files/install"

# sed -i 's|^PermitRootLogin yes|PermitRootLogin no|' /etc/ssh/sshd_config
# sed -i 's|^#PasswordAuthentication.*|PasswordAuthentication no|' /etc/ssh/sshd_config
# sed -i 's|^PasswordAuthentication.*|PasswordAuthentication no|' /etc/ssh/sshd_config

# systemctl restart ssh
# systemctl disable --now snapd ; sudo systemctl disable --now snapd.socket

# if [ ! -f /swapfile ]; then
#     fallocate -l 1G /swapfile
#     chmod 600 /swapfile
#     mkswap /swapfile
#     swapon /swapfile
#     echo '/swapfile none swap sw 0 0' >> /etc/fstab
# fi
# "###,
#     );

#     sync_fstab(context);
# }
