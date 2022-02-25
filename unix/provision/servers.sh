# apache START

install_system_package apache apachectl
install_system_package lynx # dependency of apachectl

check_file_exists ~/project/provision/httpd.conf
sudo cp ~/project/provision/httpd.conf /etc/httpd/conf/httpd.conf

# chmod o+x /home/$USER # necessary to follow symlinks: https://bbs.archlinux.org/viewtopic.php?id=77791
if [ ! -f ~/.check-files/apache-ssl ]; then
  # ssl: https://localhost:8443 from the host. http://stackoverflow.com/a/18602774
  cd /etc/httpd/conf
  sudo rm -rf server.key server.crt
  sudo openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:4096 -out server.key
  sudo chmod 400 server.key
  sudo openssl req -new -sha256 -key server.key -out server.csr -subj "/C=GB/ST=London/L=London/O=Global Security/OU=IT Department/CN=localhost"
  sudo openssl x509 -req -days 1095 -in server.csr -signkey server.key -out server.crt
  sudo apachectl restart
  touch ~/.check-files/apache-ssl
fi

cat >> ~/.shell_aliases <<"EOF"
  alias ApacheRestart='sudo apachectl restart'
  alias ApacheStatus='sudo apachectl status'
  # It needs provision.sh as it may append stuff to the config file
  alias ModifyApacheConf='$EDITOR ~/project/provision/httpd.conf; provision.sh; echo "/etc/httpd/conf/httpd.conf";
    diff ~/project/provision/httpd.conf /etc/httpd/conf/httpd.conf --color=always'
  ModifyApacheLog() { Sudo $EDITOR /var/log/httpd/error_log; }
EOF

sudo chown igncp /srv/http/
sudo rm -f /srv/http/*

sudo apachectl restart &

cat >> ~/.vimrc <<"EOF"
au BufRead,BufNewFile error_log setfiletype httpd
" quick error_log
  autocmd FileType php vnoremap <leader>kk yoerror_log('a' . print_r(a, true));<c-c>FaFavpT'i$<c-c>vi'yf'i: <c-c>llfavp
EOF

# apache END
