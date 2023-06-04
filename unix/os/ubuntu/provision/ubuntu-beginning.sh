# ubuntu-beginning START

install_system_package() {
  PACKAGE="$1"
  if [ "$PACKAGE" == "task" ]; then
    PACKAGE="taskwarrior"
  elif [ "$PACKAGE" == "the_silver_searcher" ]; then
    PACKAGE="silversearcher-ag"
  fi
  if [ ! -z "$2" ]; then CMD_CHECK="$2"; else CMD_CHECK="$1"; fi
  if ! type "$CMD_CHECK" > /dev/null 2>&1 ; then
    echo "doing: sudo apt-get install -y $PACKAGE"
    sudo apt-get install -y "$PACKAGE"
  fi
}

# ubuntu-beginning END
