# Modified from: https://bbs.archlinux.org/viewtopic.php?pid=947805#p947805
# To place in `/lib/initcpio/install/ssldec`

build() {
  add_binary "/usr/bin/openssl"
  add_runscript
}

help() {
  cat <<HELPEOF
  This hook allows for an openssl (aes-256-cbc) encrypted keyfile for LUKS.
  It relies on standard 'encrypt' hook providing decrypted '/crypto_keyfile.bin' for it.
  The number of password input attempts is hard-coded (3 by default followed by poweroff).

  Kernel Parameters:
  Two options are supported:
  1) Using a file on the device:
     ssldec=<device>:<fs-type>:<path>
  2) Reading raw data from the block device:
     ssldec=<device>:<offset>:<size>
HELPEOF
}
