# jvm START

if ! type java > /dev/null 2>&1 ; then
  asdf plugin-add java https://github.com/halcyon/asdf-java.git
  asdf install java adoptopenjdk-14.0.2+12
  asdf global java adoptopenjdk-14.0.2+12
fi

# Oracle JDK:
# https://www.oracle.com/java/technologies/javase-downloads.html

# Open JDK
# install_system_package jdk8-openjdk java

cat >> /tmp/expected-vscode-extensions <<"EOF"
redhat.java
VisualStudioExptTeam.vscodeintellicode
vscjava.vscode-java-debug
vscjava.vscode-java-dependency
vscjava.vscode-java-pack
vscjava.vscode-java-test
vscjava.vscode-maven
EOF

# jvm END
