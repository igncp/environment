# raspberry-ubuntu START

# To setup Wifi
# sudo apt-get install -y network-manager
# nmtui

# sudo apt-get install -y raspi-config

## pi-hole docker setup
  # In the pi-hole running machine
    # docker pull pihole/pihole
    # sudo systemctl disable systemd-resolved.service
  mkdir -p ~/pi-hole
  touch ./hosts ; sudo chown root hosts
  cat > ~/pi-hole/docker-compose.yml <<"EOF"
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
  # Clients:
    # Arch Linux:
      # Update `netctl` profile config to include the IP address
          # DNS=('192.168.1.X')
  # docker compose exec -it pihole
    # pihole logging off
    # pihole logging off
  # sudo vim ./etc-pihole/pihole-FTL.conf
    # PRIVACYLEVEL=3
    # # If using SSD
    # DBINTERVAL=60.0

# raspberry-ubuntu END
