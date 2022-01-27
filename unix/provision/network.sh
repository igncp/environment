# network START

install_system_package vnstat

# USB Modem
  install_system_package modemmanager ModemManager
  install_system_package usb_modeswitch
  install_system_package nm-connection-editor
  install_system_package wvdial
  install_system_package libmbim mbimcli

  cat >> ~/.shell_aliases <<"EOF"
alias USBModemManagerStart='sudo systemctl start ModemManager'
alias USBModemManagerList='sudo mmcli --list-modems'
alias USBModemShowModem0='sudo mmcli --modem=/org/freedesktop/ModemManager1/Modem/0' # from USBModemManagerList
USBModemSetPin() { sudo mmcli --sim=/org/freedesktop/ModemManager1/SIM/0 --pin="$1"; }
EOF

# Software Access Point
  # https://wiki.archlinux.org/index.php/software_access_point
  install_system_package iw
  install_system_package hostapd # can enable service: sudo systemctl enable hostapd

  echo 'sudo vim /etc/hostapd/hostapd.conf # and remove this message'
  cat >> ~/.shell_aliases <<"EOF"
alias SoftwareAccessPointSupported='iw list | ag AP'
EOF

# network END
