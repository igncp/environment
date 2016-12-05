# jvm START

install_pacman_package jdk8-openjdk java

if [ ! -f ~/selenium-server.jar ]; then
  SELENIUM_FILE_NAME=selenium-server-standalone-2.39.0.jar
  cd ~
  curl -O http://selenium-release.storage.googleapis.com/2.39/"$SELENIUM_FILE_NAME"
  mv "$SELENIUM_FILE_NAME" selenium-server.jar # java -jar ~/selenium-server.jar
fi

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

# jvm END
