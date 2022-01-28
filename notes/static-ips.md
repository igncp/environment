### Arch Linux

- Trigger `dhcpcd` which will automatically pick one

#### Ubuntu Server 18.x

- `enp0s3` is the NAT adapter
- `enp0s8` is the "Host-only Adapter"
- The `enp0s8` must have allocated a static IP.

- `sudo vim /etc/netplan/50-cloud-init.yaml`

```
network:
  ethernets:
    enp0s3:
      dhcp4: true
    enp0s8:
      addresses: [IP_ADDRESS/MASK]
  version: 2
```

- And example for `[IP_ADDRESS/MASK]` is `192.168.111.103/24`
- `sudo netplan apply`
- `reboot`
