Vagrant.configure("2") do |config|
    # Base VM OS configuration.
    config.vm.synced_folder '.', '/vagrant', disabled: true
    config.ssh.insert_key = false
  
    required_plugins = ["vagrant-hosts"]
    required_plugins.each do |plugin|
      unless Vagrant.has_plugin?(plugin)
        # Attempt to install plugin. Bail out on failure to prevent an infinite loop.
        system("vagrant plugin install #{plugin}") || exit!
    
        # Relaunch Vagrant so the plugin is detected. Exit with the same status code.
        exit system('vagrant', *ARGV)
      end
    end

    config.vm.provider :virtualbox do |v|
      v.memory = 2072
      v.cpus = 2
      v.customize ['modifyvm', :id, '--natnet1', '192.168.222.0/24']
    end
  
    boxes = [
      { :name => "kube-master", :ip => "10.240.0.10", :OS => "bento/ubuntu-18.04", :fqdn => "#{:name}.motherbase"},
      { :name => "kube-node1", :ip => "10.240.0.11", :OS => "bento/ubuntu-18.04", :fqdn => "#{:name}.motherbase"},
      { :name => "kube-node2", :ip => "10.240.0.12", :OS => "bento/ubuntu-18.04", :fqdn => "#{:name}.motherbase"},
    ]
  
    # Provision each of the VMs.
    boxes.each do |opts|
      config.vm.define opts[:name] do |config|
        config.vm.box = opts[:OS]
         #vm_config.vm.boot_mode = :gui
        config.vm.hostname = opts[:name]
        config.vm.network :private_network, ip: opts[:ip]
        config.vm.synced_folder ".", "/srv/salt"
        config.vm.synced_folder "pillar", "/srv/pillar"
        config.vm.provision :hosts, :sync_hosts => true
        config.vm.provision "shell", inline: <<-SHELL
            wget -O - https://repo.saltstack.com/py3/ubuntu/18.04/amd64/2018.3/SALTSTACK-GPG-KEY.pub | sudo apt-key add -
            echo "deb http://repo.saltstack.com/py3/ubuntu/18.04/amd64/2018.3 bionic main" > /etc/apt/sources.list.d/saltstack.list
            curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.14.0/bin/linux/amd64/kubectl
            chmod +x ./kubectl
            mv ./kubectl /usr/local/bin/kubectl
            apt-get update -y && \
            apt-get install -y curl salt-minion gnupg2
            echo 'master: kube-master' >> /etc/salt/minion
            systemctl restart salt-minion
        SHELL

        if opts[:name] == "kube-master"
            config.vm.provision "shell", inline: <<-SHELL
                apt-get update -y && \
                apt-get install -y curl salt-master
                systemctl restart salt-master         
            SHELL
        end
      end
    end
  end
  