# @TODO
# ubuntu-retropie START

if [ ! -d ~/RetroPie-Setup ]; then
  sudo apt install -y git dialog unzip xmlstarlet

  cd ~
  git clone --depth=1 https://github.com/RetroPie/RetroPie-Setup.git
  cd RetroPie-Setup
  sudo ./retropie_setup.sh
  cd
fi

# ubuntu-retropie END
