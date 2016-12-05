Vagrant.configure(2) do |config|
  config.vm.box = "arch14"
  config.vm.box_url = 'http://vagrant.srijn.net/archlinux-x64-2014-01-07.box'
  config.vm.hostname = 'PROJECT_HOSTNAME'

  # config.vm.network :forwarded_port, guest: 80, host: 9080
  # config.vm.network :forwarded_port, guest: 9000, host: 9000
  # for i in 9000..9050; config.vm.network :forwarded_port, guest: i, host: i; end
  # config.vm.network :forwarded_port, guest: 19999, host: 19999 # netdata
  # config.vm.network :forwarded_port, guest: 7474, host: 7474 # neo4j
  # config.vm.network :forwarded_port, guest: 1337, host: 1337 # sailsjs
  # config.vm.network :forwarded_port, guest: 27017, host: 27017 # mongodb
  # config.vm.network :forwarded_port, guest: 5601, host: 5601 # kibana

  config.vm.synced_folder ".", "/project"
  config.vm.synced_folder "~/vm-shared", "/vm-shared"

  config.vm.provision "shell", inline: ". /project/provision/provision.sh", privileged: false

  config.vm.provider "virtualbox" do |v|
    v.memory = 2024
    v.cpus = 2
    # v.gui = true
    v.customize ['modifyvm', :id, '--clipboard', 'bidirectional']
    # v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"] # fix for windows host when restarting from sleep
  end
end
