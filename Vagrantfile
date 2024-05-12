# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "centos/7"

  config.vm.provider "virtualbox" do |v|
    v.memory = 256
    v.cpus = 1
  end

  config.vm.define "nfs_server" do |nfs_server|
    nfs_server.vm.network "private_network", ip: "192.168.50.10", virtualbox__intnet: "internal"
    nfs_server.vm.hostname = "nfs-server"
    nfs_server.vm.provision "shell", path: "nfs_server.sh"
  end

  config.vm.define "nfs_client" do |nfs_client|
    nfs_client.vm.network "private_network", ip: "192.168.50.11", virtualbox__intnet: "internal"
    nfs_client.vm.hostname = "nfs-client"
    nfs_client.vm.provision "shell", path: "nfs_client.sh"
  end

end
