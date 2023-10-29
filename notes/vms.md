## VirtualBox

### Creating a VM

- Check the [./performance.md](./performance.md) document for host and VM changes
- After installation, remove disk
- Use bride network adaptor
- Setup ssh to use common key and don't allow password

```bash
rsync -rhv --delete ./ igncp@192.168.1.X:/home/igncp/environment/
```

- If using UI, check if audio is muted
- For full-screen press Ctrl+f

### USB

Menu > Machine > USB > Add new filter: Choose the USB to add

### Headless

```bash
VBoxHeadless \
  --startvm "$VM_NAME"
```

## UTM (Silicon chips)

- I had to rename interface name following these steps:
    - https://vitux.com/how-to-configure-networking-with-netplan-on-ubuntu/
    - https://github.com/utmapp/UTM/issues/2619
    - In another test, had to update the UTM network interface in its settings to `en1` for Ubuntu
    - Ethernet: Set the inteface to `en0`, change the driver to `device`
    - Wifi: Set the interface to `en1`, use the default driver

### Arch ARM setup

- `brew install qemu`
- `qemu-img resize  /PATH/TO/FILE.qcow2 +30G`
- From VM:
    - Update ssh config: allow root login
    - `useradd igncp`
    - `pacman -S cfdisk`
    - Resize with: `cfdisk`
    - `pacman -S parted`
    - `partprobe /dev/vda2`
    - `resize2fs /dev/vda2`
    - Reset SSH config and change root password
    - `userdel alarm && usermod -u 1000 igncp`
    - Normal setup
