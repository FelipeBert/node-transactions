Vagrant.configure("2") do |config|

  config.vm.define "web01" do |web01|
    web01.vm.box = "eurolinux-vagrant/centos-stream-9"
	  web01.vm.network "private_network", ip: "192.168.10.13"
    web01.vm.hostname = "web01"

    web01.vm.provision "shell", path: "apideploy.sh"
  end
end
