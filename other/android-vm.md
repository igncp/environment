# Android VM

## Summary

- Follow this tutorial: https://visualgdb.com/tutorials/android/virtualbox/

- Download: https://www.osboxes.org/android-x86/
  - Download the ISO (first mirror currently)
  - Create partition manually, choose bootable (like in the tutorial)

- Create new VM:
  - Linux 64
  - 2000 Mbs Memory

- Click in the Menu: Input > Mouse Integration
- Docs: https://www.android-x86.org/documentation/virtualbox.html

- Choose **ONLY** Host-only Adaptor (disable NAT adaptor)
  - Not much testing, but this worked, generates an IP reachable from ADB
  - See [vbox-networking.md](./vbox-networking.md)
  - Change the type to **FAST III** (like in the tutorial)
  - `ifconfig eth0` should display the network IP, and should be reachable from other VM

- SDK version: `adb shell grep ro.build.version.sdk= system/build.prop`

## Shortcuts

- Alt + F1: Opens terminal as root
- Alt + Tab: Switches apps
- Right Control: Release mouse
