#!/usr/bin/env bash

set -e

provision_setup_general_pi_hole() {
  if [ ! -f "$PROVISION_CONFIG"/pi-hole ]; then
    return
  fi

  # https://docs.pi-hole.net/guides/dns/unbound/
  install_system_package "unbound"

  mkdir -p ~/.pi-hole

  cat >~/.pi-hole/docker-compose.yml <<"EOF"
version: "3"

services:
  pihole:
    container_name: pihole
    image: pihole/pihole:latest
    ports:
      - "53:53/tcp"
      - "53:53/udp"
      - "67:67/udp"
      - "80:80/tcp"
      - "443:443/tcp"
    environment:
      TZ: 'Europe/Madrid'
    volumes:
       - './etc-pihole/:/etc/pihole/'
       - './etc-dnsmasq.d/:/etc/dnsmasq.d/'
    dns:
      - 127.0.0.1
      - 1.1.1.1
    cap_add:
      - NET_ADMIN
    restart: unless-stopped
EOF

  cat >>~/.shell_aliases <<"EOF"
alias PiHoleStart='(cd ~/.pi-hole/ && docker compose up -d)'
alias PiHoleStop='(cd ~/.pi-hole/ && docker compose down)'
alias PiHoleLogs='(cd ~/.pi-hole/ && docker compose logs -f pihole)'

PiHoleAllowedAdd() { cd ~/.pi-hole/ && docker compose exec pihole pihole -w $1; }
PiHoleAllowedRemove() { cd ~/.pi-hole/ && docker compose exec pihole pihole -w $1 -d; }

alias PiHoleAllowedList='(cd ~/.pi-hole/ && docker compose exec pihole pihole -q .)'
alias PiHoleForbidAdd='(cd ~/.pi-hole/ && docker compose exec pihole pihole -b $1)'
alias PiHoleForbidAddRegex='(cd ~/.pi-hole/ && docker compose exec pihole pihole --regex $1)' # To include subdomains like `www`: .*\.example.com
alias PiHolePassword='(cd ~/.pi-hole && docker compose exec pihole pihole -a -p)'
alias PiHoleRepl='(cd ~/.pi-hole && docker compose exec pihole /bin/bash)'
alias PiHoleRestartDNS='(cd ~/.pi-hole && docker compose exec pihole pihole restartdns)'
alias PiHoleUnboundUpdate='(sudo vim /etc/unbound/unbound.conf)'

PiHoleInit() {
  cd ~/.pi-hole
  if [ -z $(docker compose ps | ag running | ag pihole) ]; then echo 'You have to run docker'; return; fi
  docker compose exec -it pihole pihole logging off
  sudo sh -c "echo 'PRIVACYLEVEL=3' >> ./etc-pihole/pihole-FTL.conf"
  sudo sh -c "echo 'DBINTERVAL=60.0' >> ./etc-pihole/pihole-FTL.conf"
  sudo unbound-control-setup
  sudo systemctl disable --now systemd-resolved.service
  sudo systemctl enable --now unbound
  docker compose down
  docker compose up -d
}
EOF

  # Clients:
  #   Chrome:
  #     Flush DNS cache: `chrome://net-internals/#dns`
  #   Arch Linux:
  #     Update `netctl` profile config to include the IP address
  #       DNS=('192.168.1.X')
  #     If inside a VM with a network using the bridge adapter
  #       Update: `/etc/resolv.conf.head` with `nameserver IP_OF_PI_HOLE` (replace by the real IP) which is used by dhcpcd
  #     Update upstream DNS for pi-hole in: http://pi-hole-url/admin/settings.php?tab=dns
  #       Add logging: https://snippets.khromov.se/enable-logging-of-dns-queries-in-unbound-dns-resolver/
  #     To disable pi-hole:
  #       Remove DNS from `netctl` profile
  #       Restart netctl profile
  #       Remove records in `/etc/resolv.conf`
}
