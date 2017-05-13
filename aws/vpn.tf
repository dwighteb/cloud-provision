provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_vpc" "main" {
  tags {
    Name = "Main"
  }
}

data "aws_subnet_ids" "public" {
  vpc_id = "${data.aws_vpc.main.id}"
  tags {
    Name = "Public us-east-1d"
  }
}

data "aws_security_group" "sshinbound" {
  tags {
    Name = "SSH-Inbound"
  }
}

data "aws_security_group" "vpninbound" {
  tags {
    Name = "VPN-Inbound"
  }
}

resource "aws_instance" "vpn" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.nano"
  subnet_id     = "${data.aws_subnet_ids.public.ids[0]}"
  key_name      = "dwighteb@20160709.mbp3"
  associate_public_ip_address = true
  ipv6_address_count = 1  // terraform destroys if this isn't set

  vpc_security_group_ids =
    ["${data.aws_security_group.sshinbound.id}",
     "${data.aws_security_group.vpninbound.id}"]

  tags {
    Name = "DockerCloud"
  }
}

output "instance_ip" {
  value = "${aws_instance.vpn.public_ip}"
}
