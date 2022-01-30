## Arch Linux - Via netctl

- Copying the one in `/etc/netctl/examples` with static IP
- It involves adding the following:
```
IP=static
Address='192.168.1.55/24'
Gateway='192.168.1.1'
DNS=('192.168.1.1')
```

## Ubuntu Server 20.x

- `sudo vim /etc/netplan/00-installer-config.yaml`

```
network:
  ethernets:
    enp0s3:
      addresses: [192.168.1.X/24]
      gateway4: 192.168.1.1
      nameservers:
        addresses: [4.2.2.2, 8.8.8.8]
  version: 2
```

- Update the `X` in addresses with the desired number
- `sudo netplan apply`
- `reboot`
