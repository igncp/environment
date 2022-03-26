# kotlin START

install_system_package kotlin
install_vim_package udalov/kotlin-vim

cat >> ~/.shell_aliases <<"EOF"
alias KotlinScript='kotlinc -script' # e.g. KotlinScript foo.kts
EOF

cat >> /tmp/expected-vscode-extensions <<"EOF"
fwcd.kotlin
mathiasfrohlich.Kotlin
esafirm.kotlin-formatter
EOF

# kotlin END
