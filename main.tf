provider "aws" {
  # access_key = "${var.access_key}"
  # secret_key = "${var.secret_key}"
  region     = "${var.region}"
}
resource "aws_key_pair" "docker-pair" {
  key_name   = "docker-pair"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDMejoEAvBwt+GUb5S8vR9bdH7JD3AY3J+gW/PwMMtn2Yob4RZu1PuParjNkBSqYzIOVOeOp5AevvzCac2e1BCEujHMYbLfFqZjnMmxZxv5P8p/12htDG5JXph+OhB9sHsUoE+vLLFRqaqgvtoKEEcPPddF25q6f08+6neGa3L9QS2obFSjdxZGIZEdmuZz2oABOtElFjZBG5/LtlqODTWcqKnn59VVfbfHjPVqEFxis1C7ywdznTAt0o6yScdYNlwk6GOSSMEhNXnQcYLeOJ3HAFArwxkOMKmU4pV2MG4qfXoLpJtxpFur2ZLC2C5mW9eUEtxSbe0qLl36yiOdhm6T imported-openssh-key"
}
 data "aws_ami" "redhat" {
    most_recent = true
    owners = ["309956199498"] // Red Hat's account ID.
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "name"
    values = ["RHEL-7.*"]
  }
}
resource "aws_instance" "Docker" {
  ami = "${data.aws_ami.redhat.id}"
  instance_type = "t2.medium"
  security_groups = [
    "${aws_security_group.sg_docker.name}"
    ]
  key_name = "docker-pair"
  count = 2

  # user_data = <<-EOF
  #           #!/bin/bash
  #           yum -y install wget lvm2 nano yum-utils ntp net-tools git curl
  #           yum update -y
  #           yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  #           yum-config-manager --enable rhel-7-server-extras-rpms
  #           # yum-config-manager --add-repo https://download.virtualbox.org/virtualbox/rpm/el/virtualbox.repo
  #           yum makecache fast
  #           yum install -y http://vault.centos.org/centos/7.3.1611/extras/x86_64/Packages/container-selinux-2.9-4.el7.noarch.rpm
  #           yum install -y docker-ce
  #           systemctl start docker
  #           systemctl enable docker
  #           curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  #           chmod +x /usr/local/bin/docker-compose
  #           groupadd docker
  #           usermod -aG docker $USER
  #           # base=https://github.com/docker/machine/releases/download/v0.16.0 &&
  #           # curl -L $base/docker-machine-$(uname -s)-$(uname -m) >/tmp/docker-machine &&
  #           # sudo install /tmp/docker-machine /usr/local/bin/docker-machine
  #           EOF
 tags {
        Name = "Docker"
        Terraform = "true"
        Environment = "dev"
        AutoOff = "true"
    }
  provisioner "remote-exec" {
      # Install Python for Ansible
      inline = [
        "sudo rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm",
        "sudo yum -y install nano ansible git wget yum-utils ntp net-tools curl",
        # "sudo yum -y install ansible python git libselinux-python",
        "date", # Random second command to show syntax
        ]

      connection {
        type        = "ssh"
        user        = "ec2-user"
        private_key = "${file(var.ssh_key_private)}"
      }
    }
##Runs command after remote-exec
#   provisioner "local-exec" {
#       command = "ansible-playbook -u ec2-user -i '${self.public_ip},' --private-key ${var.ssh_key_private} -T 300 provision.yml" 
#     }

}

resource "aws_eip" "eip_one" {
  instance    = "${aws_instance.Docker.*.id}"
}