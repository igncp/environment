#!/usr/bin/env bash

# Download Ubuntu Server: http://releases.ubuntu.com/
# Create new Virtual Box image
  # VDI > Dynamically Allocated > Choose dir and Size
  # Tested with 30Gb disk and 2Gb memory
# Choose ISO and boot Ubuntu Server
# Add shared folder
  # Menu > Devices > Shared Folders > Settings > Add new
  # Check: Make Permanent, Auto-Mount
  # Used names: project
# Follow wizard of Ubuntu Server
  # Choose to install SSH Server
  # Takes several minutes to install
# Once finishes, remove disk
# Reboot
# Create ~/vms directory
# Configure network (see in this project: other/vbox-networking.md)
# Copy this file via rsync and run it

set -e

sudo apt-get update
sudo apt-get install -y virtualbox-guest-dkms
sudo apt-get install -y virtualbox-guest-utils
sudo usermod -a -G vboxsf igncp
sudo reboot

# From this point it can clone the environment there
# and start building the provision. The first time the project will be in
# ** `/media/sf_project` **
