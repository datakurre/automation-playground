# Playground for Vagrant

[Open Automation Playground](https://github.com/datakurre/automation-playground) is also available for [Oracle VM VirtualBox](https://www.virtualbox.org/) with [HashiCorp Vagrant](https://www.vagrantup.com/) with the following `Vagrantfile`:

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

With the `Vagrantfile` above, the playground can be started with:

```bash
vagrant up
```

and upgraded with:

```bash
vagrant provision
```

stopped with:

```bash
vagrant halt
```

and deleted with:

```bash
vagrant destroy -f
vagrant box remove datakurre/automation-playground -f
```

