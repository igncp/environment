# gui-kde-plasma START

# @TODO - not confirmed

if [ ! -f ~/.check-files/plasma ]; then
  install_system_package plasma-meta
  install_system_package kde-applications
  mkdir -p ~/.check-files; touch ~/.check-files/plasma
fi

echo 'exec startplasma-x11' >> ~/.xinitrc

# gui-kde-plasma END
