# Open Automation Playground

[View documentation](https://datakurre.github.io/automation-playground/)

VirtualBox based Vagrant image is available by running `vagrant up` with the following `Vagrantfile:

```ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "datakurre/automation-playground"

  config.vm.provision "rebuild", type: "shell",
    inline: "sudo nixos-rebuild switch --flake github:datakurre/automation-playground/main#vagrant"

  config.vm.graceful_halt_timeout = 120

  config.vm.provider "virtualbox" do |vb, override|
    vb.gui = true
    vb.memory = 16384
    vb.cpus = 4

    override.vm.provision "remount", type: "shell",
      inline: "sudo mount -t vboxsf vagrant /vagrant -o umask=0022,gid=1000,uid=1000"
  end

end
```
