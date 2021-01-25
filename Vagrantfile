require 'yaml'

WORKERS_COUNT = 2

def add_host(inventory, name, addr)
  inventory["all"]["hosts"][name] = {
    "ansible_host" => addr,
    "ansible_ssh_private_key_file" => ".vagrant/machines/#{name}/virtualbox/private_key"
  }
end

def init_inventory()
  { "all" => { "vars" => { "ansible_user" => "vagrant" }, "hosts" => {} } }
end

def dump_inventory(inventory)
  File.new("inventory.yml", "w").write(inventory.to_yaml)
end

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"
  config.vm.provider "virtualbox" do |v|
    v.linked_clone = true
    v.memory = 2048
    v.cpus = 2
  end

  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y python3-minimal
  # SHELL

  inventory = init_inventory
  WORKERS_COUNT.times do |num|
    worker_name = sprintf("wk%03d", num)
    worker_addr = "192.168.51.#{ 100 + num }"
    config.vm.define worker_name do |worker|
      worker.vm.network "private_network", ip: worker_addr
      worker.vm.hostname  = worker_name
    end
    add_host(inventory, worker_name, worker_addr)
  end

  dump_inventory(inventory)
end
