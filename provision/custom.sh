# custom START

cat >> ~/.bashrc <<"EOF"
EOF

cat >> ~/.bash_aliases <<"EOF"
EOF

cat >> ~/.vimrc <<"EOF"
let g:hardtime_default_on = 0
call SetColors()
EOF

# custom END

echo "finished provisioning"
