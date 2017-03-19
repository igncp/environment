# c START

if ! type clib > /dev/null 2>&1 ; then
  echo "installing clib"
  sudo rm -rf /tmp/clib
  git clone https://github.com/clibs/clib.git /tmp/clib
  cd /tmp/clib
  sudo make install
fi

# c END
