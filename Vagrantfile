# -*- mode: ruby -*-
# vi: set ft=ruby :

################################################################################
#
# Copyright 2013 Crown copyright (c)
# Land Information New Zealand and the New Zealand Government.
# All rights reserved
#
# This program is released under the terms of the new BSD license. See the
# LICENSE file for more information.
#
################################################################################

#
### CONFIGURATION SECTION
#

Vagrant.require_version ">= 1.8.0"

box = "bento/ubuntu-14.04"

# Canonical cloud box.
# box = "trusty-canonical"
# box_url_base = "http://cloud-images.ubuntu.com/vagrant/trusty/current"
# box_url_name = "trusty-role-cloudimg-amd64-vagrant-disk1.box"
# box_url = box_url_base + "/" + box_url_name


ROLES = {
    "gazetteer" => {
        "memory" => "1024",
        "ports" => [
            ["5432", "15432"],
        ],
        "count" => "1",
    },
}


#
### DON'T CHANGE ANYTHING UNDER THIS LINE
#

Vagrant.configure(2) do |config|

    # config.vm.box_url = box_url
    config.vm.box = box

    config.ssh.forward_agent = true
    config.vm.synced_folder '.', '/vagrant'

    # configure additional files sharing for development
    if File.exist?('vagrant-dev.dir')
        dev_sf = File.read('vagrant-dev.dir').strip
        config.vm.synced_folder dev_sf, '/vagrant-dev'
        puts "INFO: Sharing content of '#{dev_sf}' in '/vagrant-dev'"
    end


    # loop over all configured roles
    ROLES.each do | (role, cfg) |

        insts = Array.new

        # loop over all role instances`
        (1..cfg["count"].to_i).each do |i|

            if i == 1
                host = "#{role}"
            else
                host = "#{role}-#{i}"
            end

            config.vm.define host do |inst|

                insts.push(host)

                # IP address
                inst.vm.network "private_network",
                    type: "dhcp"

                # hostname
                inst.vm.hostname = host

                # ports forwarding
                cfg["ports"].each do | port |
                    inst.vm.network "forwarded_port",
                        guest: port[0],
                        host: port[1],
                        auto_correct: true
                end


                ### PRODUCTION DEPLOYMENT
                inst.vm.provision "deploy", type: "ansible" do |ansible|
                    ansible.playbook = "deployment/#{role}-deploy.yml"
                    ansible.limit = "all"
                    ansible.verbose = "vv"
                    ansible.groups = {
                        "#{role}" => insts,
                    }
                    ansible.extra_vars = {
                        HOST_NAME: "#{host}",
                        PROJECT_NAME: "vagrant",
                        ROLE_NAME: "#{role}",
                        SYSTEM_NETWORK_DEVICE: "eth1",
                    }

                    # load password from file if exists
                    if File.exist?('ansible-password.txt')
                        ansible.vault_password_file = "ansible-password.txt"
                    else
                        ansible.ask_vault_pass = true
                    end
                end

                ### TEST
                if File.exist?("deployment/" + role + "-test.yml")
                    inst.vm.provision "test", type: "ansible" do |ansible|
                        ansible.playbook = "deployment/#{role}-test.yml"
                        ansible.limit = "all"
                        ansible.verbose = "vv"
                        ansible.extra_vars = {
                            HOST_NAME: "#{host}",
                            PROJECT_NAME: "vagrant",
                            ROLE_NAME: "#{role}",
                            SYSTEM_NETWORK_DEVICE: "eth1",
                        }

                        # load password from file if exists
                        if File.exist?('ansible-password.txt')
                            ansible.vault_password_file = "ansible-password.txt"
                        else
                            ansible.ask_vault_pass = true
                        end
                    end
                else
                    puts "WARNING: Role '#{role}' is missing integration tests !"
                end

                ### DEVELOPMENT SUPPORT
                if File.exist?("deployment/" + role + "-develop.yml")
                    inst.vm.provision "develop", type: "ansible" do |ansible|
                        ansible.playbook = "deployment/#{role}-develop.yml"
                        ansible.limit = "all"
                        ansible.verbose = "vv"
                        ansible.extra_vars = {
                            HOST_NAME: "#{host}",
                            PROJECT_NAME: "vagrant",
                            ROLE_NAME: "#{role}",
                            SYSTEM_NETWORK_DEVICE: "eth1",
                        }

                        # load password from file if exists
                        if File.exist?('ansible-password.txt')
                            ansible.vault_password_file = "ansible-password.txt"
                        else
                            ansible.ask_vault_pass = true
                        end
                    end
                end


                ### PROVIDERS CONFIGURATION
                # VirtualBox
                inst.vm.provider "virtualbox" do |vb, override|
                    vb.customize ["modifyvm", :id, "--memory", cfg["memory"]]
                    vb.customize ["modifyvm", :id, "--nictype1", "virtio"]
                    vb.customize ["modifyvm", :id, "--nictype2", "virtio"]
    #               vb.gui = true
                end

                # Parallels
                inst.vm.provider "parallels" do |pl, override|
                    pl.memory = cfg["memory"]
                end
            end
        end
    end
end

# vim: set ts=4 sts=4 sw=4 et:
