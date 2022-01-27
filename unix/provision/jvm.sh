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

install_vim_package tfnico/vim-gradle

cat >> ~/.shell_aliases <<"EOF"
alias GradleProjects='./gradlew -q projects'
alias GradleTasks='./gradlew -q tasks'
alias GradleHelpTask='./gradlew -q help --task'
alias GradleDependencies='./gradlew -q buildEnvironment'
EOF

install_vim_package udalov/kotlin-vim

cat >> /tmp/expected-vscode-extensions <<"EOF"
redhat.java
VisualStudioExptTeam.vscodeintellicode
vscjava.vscode-java-debug
vscjava.vscode-java-dependency
vscjava.vscode-java-pack
vscjava.vscode-java-test
vscjava.vscode-maven
EOF

cat >> /tmp/expected-vscode-extensions <<"EOF"
fwcd.kotlin
mathiasfrohlich.Kotlin
esafirm.kotlin-formatter
EOF

# jvm-extras available

# jvm END
