#!/usr/bin/env bash

set -euo pipefail

cat >/tmp/bukkit.yml <<"EOF"
# kubectl cp minecraft:bukkit.yml bukkit.yml
settings:
  allow-end: true
  warn-on-overload: true
  permissions-file: permissions.yml
  update-folder: update
  plugin-profiling: false
  connection-throttle: -1
  query-plugins: true
  deprecated-verbose: default
  shutdown-message: Server closed
  minimum-api: none
  use-map-color-cache: true
spawn-limits:
  monsters: 70
  animals: 10
  water-animals: 5
  water-ambient: 20
  water-underground-creature: 5
  axolotls: 5
  ambient: 15
chunk-gc:
  period-in-ticks: 600
ticks-per:
  animal-spawns: 400
  monster-spawns: 1
  water-spawns: 1
  water-ambient-spawns: 1
  water-underground-creature-spawns: 1
  axolotl-spawns: 1
  ambient-spawns: 1
  autosave: 6000
aliases: now-in-commands.yml
EOF

mkdir -p ~/misc/minecraft_server

cd ~/misc/minecraft_server

docker run \
  -it \
  --rm \
  --name minecraft_server \
  -p 25565:25565 \
  -e EULA=TRUE \
  -e VERSION=1.21.1 \
  -e ONLINE_MODE=false \
  -e TYPE=PAPER \
  -e PORT=25565 \
  -v $(pwd):/data \
  -v /tmp/bukkit.yml:/data/bukkit.yml \
  itzg/minecraft-server:latest
