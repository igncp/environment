# custom START

cat >> ~/.bashrc <<"EOF"
EOF

cat >> ~/.bash_aliases <<"EOF"
EOF

cat >> ~/.vimrc <<"EOF"
call SetColors()

function! SetupEnvironment()
  let l:path = expand('%:p')
  if l:path =~ '/home/igncp/foo/bar'
    let g:Fast_grep='lib'
  elseif l:path =~ '/home/igncp/bar/baz'
    let g:Fast_grep='main'
  else
    let g:Fast_grep='src'
  endif
endfunction
autocmd! BufReadPost,BufNewFile * call SetupEnvironment()
EOF

# Inter-VM communication
mkdir -p ~/vms
cat >> ~/.bash_aliases <<"EOF"
IP_OF_VM='1.2.3.4';
VMSSH() { cd ~/vms; ssh "$IP_OF_VM"; }
VMUpload() { rsync --delete -rh -e ssh "${@:3}" "$1" "$IP_OF_VM":"$HOME"/vms/"$2" ; }
VMDownload() { rsync --delete -rh -e ssh "${@:3}" "$IP_OF_VM:$1" "$HOME"/vms/"$2"; }
EOF

# For encrypted devices
cat >> ~/.bash_aliases <<"EOF"
MountEncryptedDeviceNAME() {
  CRYPT_NAME="CRYPT_NAME"
  DEVICE_PATH="/dev/sdaX"
  MOUNT_POINT="/home/igncp/POINT"

  sudo cryptsetup open "$DEVICE_PATH" "$CRYPT_NAME"
  mkdir -p "$MOUNT_POINT"
  sudo mount "/dev/mapper/$CRYPT_NAME" "$MOUNT_POINT"
}
UmountEncryptedDeviceNAME() {
  CRYPT_NAME="CRYPT_NAME"
  MOUNT_POINT="/home/igncp/POINT"

  sudo umount "$MOUNT_POINT"
  sudo cryptsetup close "$CRYPT_NAME"
}
EOF

# custom END

echo "finished provisioning"
