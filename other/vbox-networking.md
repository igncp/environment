# Setup Virtual Box Networking

## SSH between guests (same laptop)

- File > Preferences > Network > Host-only Networks > Create
    - Enable DHCP server (first ending in 100, third 101, forth 254)
    - Save
- With the VMs shutdown, add a second Network Adapter in each one of type "Host-only Adapter"
  - Keep the NAT adapter as first one
  - Choose the previously created Adapter

Then each machine will need to have a static IP. This can be seen with:
  - `ifconfig -a`

### Arch Linux

- Run `sh ~/init.sh` to trigger `dhcpcd` which will automatically pick one

### Ubuntu Server 14.x

- `eth0` is the NAT adapter
- `eth1` is the "Host-only Adapter"
- The `eth1` must have allocated a static IP.

- `sudo vim /etc/network/interfaces`
```
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp

auto eth1
iface eth1 inet static
  address 192.168.111.103
  netmask 255.255.255.0
  network 192.168.111.0
```

- `sudo reboot`

### Ubuntu Server 18.x

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

### Debugging

- Use `ping IP_ADDRESS` from the host, and once working, from the VMs
- Use `ipconfig` in Windows and `ifconfig -a` in linux
- Make sure NAT adapter is the first one

## SSH between laptops, same network

These steps worked, but not all may be necessary

- Create a 'Bidged Network Adapter', but not the first one
- Choose the default one
- Run `dhcpcd`
- Wait a couple of minutes
- Run `ifconfig -a` inside the guest to get the IP
- Start the SSH service
- SSH into the machine
