# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.berkshelf.enabled = true
  config.vm.network "private_network", ip: "192.168.33.10"

  config.vm.provision "chef_solo" do |chef|
    chef.cookbooks_path = "."
    chef.add_recipe "newrelic"
    # specify custom JSON attributes:
    chef.json = { mysql_password: "foo" }
  end
end
