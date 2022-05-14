# raspbian-retro-pie START

sudo apt-get install -y libvncserver-dev
cd
git clone https://github.com/hanzelpeter/dispmanx_vnc
cd dispmanx_vnc
make
sudo ./dispmanx_vncserver &

# https://retropie.org.uk/docs/Nintendo-Switch-Controllers/

# raspbian-retro-pie END
