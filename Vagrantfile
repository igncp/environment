Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu14"
  config.vm.box_url = config.vm.box_url = 'https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box'
  config.vm.hostname = 'PROJECT_HOSTNAME'

  # config.vm.network :forwarded_port, guest: 80, host: 9080
  # config.vm.network :forwarded_port, guest: 9000, host: 9000
  # for i in 9000..9050; config.vm.network :forwarded_port, guest: i, host: i; end
  # config.vm.network :forwarded_port, guest: 7474, host: 7474 # neo4j
  # config.vm.network :forwarded_port, guest: 1337, host: 1337 # sailsjs

  config.vm.synced_folder ".", "/project"

  config.vm.provision "shell", inline: ". /project/provision/provision.sh", privileged: false

  config.vm.provider "virtualbox" do |v|
    v.memory = 2024
    v.cpus = 2
    v.customize ['modifyvm', :id, '--clipboard', 'bidirectional']
  end
end
