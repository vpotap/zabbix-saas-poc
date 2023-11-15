packer {
    required_plugins {
        amazon = {
            version = ">= 1.0.0"
            source  = "github.com/hashicorp/amazon"
        }
    }
}


source "amazon-ebs" "aws" {

    ami_name        = "${var.ami_name}"
    ami_description = "POC image using ubuntu20.04 and zabbix"
   

    source_ami_filter {
        filters = {
            virtualization-type = "hvm"
            name                = "ubuntu/images/*ubuntu-focal-20.04-amd64-server-*"
            root-device-type    = "ebs"
        }
        owners      = ["099720109477"]
        most_recent = true
    }

    instance_type               = "${var.instance_type}"
    region                      = "${var.region}"
    #vpc_id                      = "${var.vpc_id}"
    #subnet_id                   = "${var.subnet_id}"
    #associate_public_ip_address = true

    # SSH configuration for connecting to the instance
    ssh_username    = "ubuntu"
    ssh_private_key_file = "/path/to/your/private-key.pem"
    
}

build {

    name = "zabbix-sass-poc"
    sources = [
        "source.amazon-ebs.ubuntu",
    ]

    #provisioner "ansible-local" {}
     
    provisioner "ansible" {
      playbook_file = "${var.provisioner_dir}/main.yml"
      extra_arguments = ["--skip-tags", "local", "--flush-cache"]
      
      # if user exist it overwrite ssh_username
      inventory_directory = "${var.provisioner_dir}/inventory.ini"
      galaxy_file = "${var.provisioner_dir}/requirements.yml"
      galaxy_force_install = true
      # temp
      keep_inventory_file = true

      # Specify additional environment variables if needed for using with ansible-local
      # environment_vars = ["ANSIBLE_VARS_FILE=${var.provisioner_dir}/vars/main.yml"]
    }
}