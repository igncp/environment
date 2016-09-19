Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu14"
  config.vm.box_url = config.vm.box_url = 'https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box'
  config.vm.hostname = 'PROJECT_HOSTNAME'
  
  config.vm.network :forwarded_port, guest: 80, host: 9080
  config.vm.network :forwarded_port, guest: 9000, host: 9000

  config.vm.synced_folder ".", "/project"

  config.vm.provision "shell", inline: ". /project/provision/main.sh", privileged: false

  config.vm.provider "virtualbox" do |v|
    v.memory = 2024
    v.cpus = 2
  end
end
