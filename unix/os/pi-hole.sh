# pi-hole START

## pi-hole docker setup
  # In the pi-hole running machine
    # docker pull pihole/pihole
    # sudo systemctl disable systemd-resolved.service
  mkdir -p ~/.pi-hole
  sudo touch ~/.pi-hole/hosts ; sudo chown root ~/.pi-hole/hosts
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
       # - './hosts/:/etc/hosts' # Add this when copied from container
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
PiHoleInit() {
  cd ~/.pi-hole
  if [ -z $(docker compose ps | ag running | ag pihole) ]; then echo 'You have to run docker'; return; fi
  docker compose exec -it pihole pihole logging off
  sudo sh -c "echo 'PRIVACYLEVEL=3' >> ./etc-pihole/pihole-FTL.conf"
  sudo sh -c "echo 'DBINTERVAL=60.0' >> ./etc-pihole/pihole-FTL.conf"
  docker compose down
  docker compose up -d
}
EOF
# Clients:
  # Arch Linux:
    # Update `netctl` profile config to include the IP address
    # DNS=('192.168.1.X')

# pi-hole END
