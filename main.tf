provider "aws" {
  # access_key = "${var.access_key}"
  # secret_key = "${var.secret_key}"
  region     = "${var.region}"
}
resource "aws_key_pair" "docker-pair" {
  key_name = "docker-pair"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
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

resource "aws_instance" "master" {
  ami = "${data.aws_ami.redhat.id}"
  instance_type = "t2.medium"
  security_groups = [
    "${aws_security_group.sg_docker.name}"
    ]
  key_name = "docker-pair"
  associate_public_ip_address = "true"
  connection {
  type        = "ssh"
  user        = "ec2-user"
  private_key = "${file(var.ssh_key_private)}"
    }  count = 1
  tags {
        Name = "Swarm-Master"
        Terraform = "true"
        Environment = "dev"
        AutoOff = "true"
    }
  user_data = <<-EOF
            #!/bin/bash
            echo 0 > /sys/fs/selinux/enforce
            EOF
  provisioner "remote-exec" {
      # Install Python for Ansible
      inline = [
            "sudo yum-config-manager --enable rhui-REGION-rhel-server-extras",
            "sudo yum-config-manager --enable extras",
            "sudo yum update -y",
            "sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo",
            "sudo rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm",
            "sudo yum makecache fast",
            "sudo yum -y install device-mapper-persistent-data wget lvm2 nano yum-utils ntp net-tools git curl docker-ce ansible",
            "sudo systemctl start docker",
            "sudo systemctl enable docker",
            "sudo curl -L \"https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose",
            "sudo chmod +x /usr/local/bin/docker-compose",
            "sudo groupadd docker",
            "sudo usermod -aG docker $USER",
            "sudo docker swarm init",
            "sudo docker swarm join-token --quiet worker > /home/ec2-user/token",
        ]
    }
  # provisioner "file" {
  # source = "proj"
  # destination = "/home/ec2-user/"
  #   }   
}

resource "aws_eip" "eip_one" {
  instance    = "${aws_instance.master.id}"
}
