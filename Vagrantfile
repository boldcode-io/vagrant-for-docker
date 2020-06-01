# -*- mode: ruby -*-
# vi: set ft=ruby sw=2 st=2 et :

Vagrant.configure("2") do |config|
  config.vm.box = "debian/buster64"
  config.vm.box_check_update = false

  # Limit RAM of Virtual Machines
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "3500"
    vb.customize ["modifyvm", :id, "--cpuexecutioncap", "90"]
    vb.cpus = 2
    vb.linked_clone = true
  end

  # Create as many servers as needed
  config.vm.define "server" do |machine|
    machine.vm.hostname = "server"
    machine.vm.network "private_network", ip: "192.168.50.240"


    # Redirect host ports (from physical machine) to the VM
    machine.vm.network "forwarded_port", guest: 80, host: 1080
    machine.vm.network "forwarded_port", guest: 8080, host: 8080

    # Run the following install script
    machine.vm.provision "shell", path: "provision/server.sh"
  end
end

