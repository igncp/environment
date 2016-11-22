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

if [ ! -d /usr/local/lib/gradle ] > /dev/null 2>&1 ; then
  cd ~
  GRADLE_VERSION=3.2
  rm -r gradle-*
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

if ! type neo4j > /dev/null 2>&1 ; then
  sudo sh -c "wget -O - http://debian.neo4j.org/neotechnology.gpg.key | apt-key add -"
  sudo sh -c "echo 'deb http://debian.neo4j.org/repo stable/' > /etc/apt/sources.list.d/neo4j.list"
  sudo apt-get update
  sudo apt-get install -y neo4j
  sudo sed -i 's/#dbms\.connector\.http\.address=0\.0\.0\.0:7474/dbms.connector.http.address=0.0.0.0:7474/' \
    /etc/neo4j/neo4j.conf
  sudo service neo4j restart
fi

sudo /etc/init.d/jenkins status > /dev/null 2>&1
if [ $? -ne 0 ]; then
  # 2.X
    wget -q -O - https://pkg.jenkins.io/debian/jenkins-ci.org.key | sudo apt-key add -
    sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
    sudo apt-get update
    sudo apt-get install -y jenkins
  # 1.x
    # JENKINS_DEB="jenkins_1.652_all.deb"
    # cd ~ && wget "http://pkg.jenkins-ci.org/debian/binary/$JENKINS_DEB"
    # sudo dpkg -i ~/"$JENKINS_DEB"
    # sudo apt-get install -fy
  sleep 25 # arbitrary wait so the server is up
  curl -o ~/jenkins-cli.jar localhost:8080/jnlpJars/jenkins-cli.jar
  sudo mkdir -p /usr/local/lib/jenkins
  sudo mv ~/jenkins-cli.jar /usr/local/lib/jenkins
cat > ~/jenkins-cli <<"EOF"
#!/usr/bin/env bash
sudo java -jar /usr/local/lib/jenkins/jenkins-cli.jar $@
EOF
  chmod +x ~/jenkins-cli
  sudo mv ~/jenkins-cli /usr/local/bin
  # sudo sed -i "s|<useSecurity>true|<useSecurity>false|" /var/lib/jenkins/config.xml && \
  #   sudo service jenkins restart # disable security
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
