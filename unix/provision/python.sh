# python START

if [ "$PROVISION_OS" == "LINUX" ]; then
  install_system_package python-pip pip
elif [ "$PROVISION_OS" == "MAC" ] && ! type pip3 > /dev/null 2>&1 ; then
  brew install python@3.8
fi

# python-extras available

# python END
