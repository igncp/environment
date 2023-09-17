# @TODO
# arch-home-assistant START

mkdir -p ~/.home-assistant

# https://www.home-assistant.io/docs/configuration/securing/

# http://localhost:8123/
cat >~/.home-assistant/docker-compose.yml <<"EOF"
version: '3'
services:
  homeassistant:
    container_name: homeassistant
    image: "ghcr.io/home-assistant/home-assistant:stable"
    volumes:
      - './config:/config'
      - /etc/localtime:/etc/localtime:ro
    restart: unless-stopped
    privileged: true
    network_mode: host
EOF

sudo mkdir -p ~/.home-assistant/config

cat >/tmp/configuration.yaml <<"EOF"
default_config:

tts:
  - platform: google_translate

automation: !include automations.yaml
script: !include scripts.yaml
scene: !include scenes.yaml

homeassistant:
  auth_mfa_modules:
    - type: totp
EOF

sudo mv /tmp/configuration.yaml ~/.home-assistant/config/configuration.yaml

## CLI
# Install as root (using `sudo su`): pip install homeassistant-cli click==7.1.2
# Add the `HASS_SERVER` and `HASS_TOKEN` environment variables in `/root/.bashrc`
# Run as root so the token is not logged into `journald` (which can be read passwordless by users in the `wheel` group)
# Some commands like `info` don't work in newer versions

# arch-home-assistant END
