# jvm-extras START

if [ ! -f ~/selenium/selenium-server.jar ]; then
  cd ~
  rm -rf selenium; mkdir -p selenium; cd selenium
  curl -L https://github.com/mozilla/geckodriver/releases/download/v0.11.1/geckodriver-v0.11.1-linux64.tar.gz | tar xz
  curl -O http://selenium-release.storage.googleapis.com/3.0/selenium-server-standalone-3.0.1.jar
  mv selenium* selenium-server.jar # java -jar -Dwebdriver.gecko.driver=~/selenium/geckodriver ~/selenium/selenium-server.jar
fi
echo 'alias SeleniumGecko="java -jar -Dwebdriver.gecko.driver=/home/igncp/selenium/geckodriver ~/selenium/selenium-server.jar"' \
  >> ~/.bash_aliases # this should be run in the VM gui screen

if [ ! -d /usr/local/lib/gradle ] > /dev/null 2>&1 ; then
  cd ~
  GRADLE_VERSION=3.2
  rm -rf gradle-*
  wget "https://services.gradle.org/distributions/gradle-$GRADLE_VERSION-bin.zip"
  unzip "gradle-$GRADLE_VERSION-bin.zip"
  rm "gradle-$GRADLE_VERSION-bin.zip"
  sudo mv "gradle-$GRADLE_VERSION" /usr/local/lib/gradle
  curl -L -s https://gist.github.com/nolanlawson/8694399/raw/gradle-tab-completion.bash \
    -o ~/gradle-tab-completion.bash
fi

cat >> ~/.bashrc <<"EOF"
export GRADLE_HOME=/usr/local/lib/gradle
export PATH=$PATH:"$GRADLE_HOME"/bin
EOF
echo "source_if_exists ~/gradle-tab-completion.bash" >> ~/.bash_sources

install_vim_package tfnico/vim-gradle

NEO4J_VERSION=3.0.7
if [ ! -d ~/.neo4j ]; then
  cd ~
  wget http://dist.neo4j.org/neo4j-community-"$NEO4J_VERSION"-unix.tar.gz
  tar -zxvf neo4j-community-"$NEO4J_VERSION"-unix.tar.gz
  rm neo4j-community-"$NEO4J_VERSION"-unix.tar.gz
  mv neo4j-community-"$NEO4J_VERSION" ./neo4j
  sudo sed -i 's/#dbms\.connector\.http\.address=0\.0\.0\.0:7474/dbms.connector.http.address=0.0.0.0:7474/' \
    ~/.neo4j/conf/neo4j.conf
  ~/.neo4j/bin/neo4j restart
fi
echo 'export PATH=$PATH:~/.neo4j/bin' >> ~/.bashrc

sudo systemctl status jenkins.service > /dev/null 2>&1
if [ $? -ne 0 ]; then
  sudo pacman -S --noconfirm jenkins
  sudo systemctl restart jenkins.service
  # sudo sed -i "s|<useSecurity>true|<useSecurity>false|" /var/lib/jenkins/config.xml && \
  #   sudo systemctl restart jenkins.service
fi

if [ ! -d /usr/local/lib/elasticsearch ]; then
  ELASTIC=elasticsearch-5.0.1
  ELASTIC_FILE="$ELASTIC".tar.gz
  cd ~
  curl -L -O https://artifacts.elastic.co/downloads/elasticsearch/$ELASTIC_FILE
  tar -xvf $ELASTIC_FILE
  rm $ELASTIC_FILE
  sudo mv $ELASTIC /usr/local/lib/elasticsearch
fi
echo "export PATH=\$PATH:/usr/local/lib/elasticsearch/bin/" >> ~/.bashrc

if [ ! -d /usr/local/lib/kibana ]; then
  cd ~
  KIBANA=kibana-5.0.1-linux-x86_64
  KIBANA_FILE="$KIBANA".tar.gz
  wget https://artifacts.elastic.co/downloads/kibana/$KIBANA_FILE
  sha1sum $KIBANA_FILE
  tar -xzf $KIBANA_FILE
  mv $KIBANA kibana
  rm $KIBANA_FILE
  sudo mv kibana /usr/local/lib/
fi
echo "export PATH=\$PATH:/usr/local/lib/kibana/bin" >> ~/.bashrc
cat >> ~/.bash_aliases <<"EOF"
alias Kibana='kibana -H 0.0.0.0'
EOF

# android
  install_pacman_package android-tools adb
  # Licenses:
  # yes | /home/igncp/android-sdk/tools/bin/sdkmanager --licenses
  cat >> ~/.bashrc <<"EOF"
  export ANDROID_HOME="/home/igncp/android-sdk"
EOF

# eclipse
  install_pacman_package eclipse-java eclipse

# jvm-extras END
