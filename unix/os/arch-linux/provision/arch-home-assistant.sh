# arch-home-assistant START

mkdir -p ~/.home-assistant

# https://www.home-assistant.io/docs/configuration/securing/

# http://localhost:8123/
cat > ~/.home-assistant/docker-compose.yml <<"EOF"
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

cat > /tmp/configuration.yaml <<"EOF"
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

# arch-home-assistant END
