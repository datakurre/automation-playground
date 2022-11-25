# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "automation-playground"

  config.vm.provision "rebuild", type: "shell",
    inline: "sudo nixos-rebuild switch --flake /vagrant#vagrant --max-jobs 1 --impure"

  config.vm.graceful_halt_timeout = 120

  ## Forward VNC
  config.vm.network "forwarded_port", guest: 8000, host: 8000

  ## Forward Zeebe
  config.vm.network "forwarded_port", guest: 5701,  host: 5701
  config.vm.network "forwarded_port", guest: 26500, host: 26500

  config.vm.provider "virtualbox" do |vb, override|
    vb.gui = true
    vb.memory = 8192
    vb.cpus = 2

    override.vm.provision "remount", type: "shell",
      inline: "sudo mount -t vboxsf vagrant /vagrant -o umask=0022,gid=1000,uid=1000"
  end

end
