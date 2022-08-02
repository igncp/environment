# pi-hole START

# https://docs.pi-hole.net/guides/dns/unbound/
install_system_package unbound
mkdir -p ~/.pi-hole
cat > ~/.pi-hole/docker-compose.yml <<"EOF"
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
cat >> ~/.shell_aliases <<"EOF"
alias PiHoleStart='(cd ~/.pi-hole/ && docker compose up -d)'
alias PiHoleStop='(cd ~/.pi-hole/ && docker compose down)'
alias PiHoleLogs='(cd ~/.pi-hole/ && docker compose logs -f pihole)'
alias PiHolePassword='(cd ~/.pi-hole && docker compose exec pihole pihole -a -p)'
alias PiHoleRepl='(cd ~/.pi-hole && docker compose exec pihole /bin/bash)'
alias PiHoleUnboundUpdate=(sudo vim /etc/unbound/unbound.conf)
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
PiHoleRestardDNS() {
  cd ~/.pi-hole/
  sudo vim ./etc-pihole/custom.list && \
    docker compose exec pihole pihole restartdns
}
EOF
# Clients:
  # Arch Linux:
    # Update `netctl` profile config to include the IP address
    # DNS=('192.168.1.X')
    # Update upstream DNS for pi-hole in: http://pi-hole-url/admin/settings.php?tab=dns
        # Add logging: https://snippets.khromov.se/enable-logging-of-dns-queries-in-unbound-dns-resolver/

# pi-hole END
