# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "debian/stretch64"
  config.vm.box_check_update = false

  config.vm.provider "libvirt" do |lv, override|
    config.vm.hostname = "debstack"

    lv.driver = "kvm"
    lv.memory = 2048
    lv.cpus = 2
    #lv.storage_pool_name = 'linux'
    lv.input :type => "tablet", :bus => "usb"
    config.vm.synced_folder ".", "/vagrant", type: "rsync", rsync__exclude: [ ".git" ]
    config.vm.provision "shell", inline: "/vagrant/provision.sh"
    config.vm.provision "shell", privileged: false, inline: "cd /home/vagrant/work && make"
  end
end
