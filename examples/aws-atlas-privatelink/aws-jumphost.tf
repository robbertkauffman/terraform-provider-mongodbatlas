# Comment entire file if you do NOT need a jumphost
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

resource "aws_network_interface" "primary_eni" {
  subnet_id       = aws_subnet.primary-az1.id
  security_groups = [aws_security_group.primary_default.id]
}

# Create jumphost for verifying connectivity to cluster via PE
resource "aws_instance" "ec2_jumphost" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = var.jumphost_ssh_key == "" ? null : var.jumphost_ssh_key

  network_interface {
    network_interface_id = aws_network_interface.primary_eni.id
    device_index         = 0
  }
}

output "jumphost-hostname" {
  value = aws_instance.ec2_jumphost.public_dns
}
