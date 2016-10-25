# jvm START

if ! type java > /dev/null 2>&1 ; then
  sudo add-apt-repository -y ppa:webupd8team/java
  sudo apt-get update
  echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections
  sudo apt-get install -y oracle-java8-installer
fi

if [ ! -f ~/selenium-server.jar ]; then
  SELENIUM_FILE_NAME=selenium-server-standalone-2.39.0.jar
  cd ~
  curl -O http://selenium-release.storage.googleapis.com/2.39/"$SELENIUM_FILE_NAME"
  mv "$SELENIUM_FILE_NAME" selenium-server.jar # java -jar ~/selenium-server.jar
fi

if ! type gradle > /dev/null 2>&1 ; then
  wget https://services.gradle.org/distributions/gradle-3.1-bin.zip
  unzip gradle-3.1-bin.zip
  rm gradle-3.1-bin.zip
  sudo mv gradle-3.1 /usr/local/lib/gradle
  curl -L -s https://gist.github.com/nolanlawson/8694399/raw/gradle-tab-completion.bash \
    -o ~/gradle-tab-completion.bash
fi

if ! type neo4j > /dev/null 2>&1 ; then
  sudo sh -c "wget -O - http://debian.neo4j.org/neotechnology.gpg.key | apt-key add -"
  sudo sh -c "echo 'deb http://debian.neo4j.org/repo stable/' > /etc/apt/sources.list.d/neo4j.list"
  sudo apt-get update
  sudo apt-get install -y neo4j
  sudo sed -i 's/#dbms\.connector\.http\.address=0\.0\.0\.0:7474/dbms.connector.http.address=0.0.0.0:7474/' \
    /etc/neo4j/neo4j.conf
  sudo service neo4j restart
fi

cat >> ~/.bashrc <<"EOF"

export GRADLE_HOME=/usr/local/lib/gradle
export PATH=$PATH:"$GRADLE_HOME"/bin
source_if_exists ~/gradle-tab-completion.bash
EOF

install_vim_package tfnico/vim-gradle

# jvm END