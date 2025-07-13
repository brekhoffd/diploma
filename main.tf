################################################################

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

################################################################

data "aws_vpc" "default" {
  default = true
}

################################################################

locals {
  ingress_ports = [
    {
      port = 22
      cidr = var.allowed_ssh_cidr
    },
    {
      port = 3001
      cidr = var.allowed_kuma_cidr
    }
  ]
}

################################################################

resource "aws_security_group" "kuma_sg" {
  name        = "uptime-kuma-sg"
  description = "Allow SSH and Uptime Kuma access"
  vpc_id      = data.aws_vpc.default.id

  dynamic "ingress" {
    for_each = local.ingress_ports
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = [ingress.value.cidr]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "uptime-kuma-sg"
  }
}

################################################################

resource "aws_instance" "uptime_kuma" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.aws_key_name
  vpc_security_group_ids = [aws_security_group.kuma_sg.id]

  user_data              = file("${path.module}/uptime_kuma.sh")

  tags = {
    Name = var.instance_name
  }
}
