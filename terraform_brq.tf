terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.74.0"
    }
  }
}

#VARIABLES
variable "aws_region" {
 description = "AWS region"
 type        = string
}

variable "access_key" {
 description = "Access key AWS"
 type        = string
}

variable "secret_key" {
 description = "Secret key AWS"
 type        = string
}

variable "aws_vpc_cidr_block" {
 description = "The IPv4 CIDR block for the VPC"
 type        = string
}

variable "aws_az" {
 description = "AWS availability zone"
 type        = string
}

variable "instance_ami" {
 description = "Definição da ami da instancia"
 type        = string
}

variable "instance_type" {
 description = "Definição da ami da instancia"
 type        = string
}
#END

provider "aws" {
  region     = var.aws_region
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_vpc" "vpc_brq" {
  cidr_block = var.aws_vpc_cidr_block
  tags = {
    Name = "VPC_legal"
  }
}

resource "aws_internet_gateway" "gw_brq" {
  vpc_id = aws_vpc.vpc_brq.id
  tags = {
    Name = "Deyverson"
  }
}

resource "aws_route_table" "rotas_brq" {
  vpc_id = aws_vpc.vpc_brq.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw_brq.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.gw_brq.id
  }

  tags = {
    Name = "GustavoGomez"
  }
}

resource "aws_subnet" "subrede_brq" {
  vpc_id            = aws_vpc.vpc_brq.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.aws_az
  tags = {
    Name = "RonyRustico"
  }
}

resource "aws_route_table_association" "associacao" {
  subnet_id      = aws_subnet.subrede_brq.id
  route_table_id = aws_route_table.rotas_brq.id
}

resource "aws_security_group" "firewall" {
  name        = "abrir_portas"
  description = "Abrir porta 22 (SSH), 443 (HTTPS) e 80 (HTTP)"
  vpc_id      = aws_vpc.vpc_brq.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Dudu"
  }
}

resource "aws_network_interface" "interface_rede" {
  subnet_id       = aws_subnet.subrede_brq.id
  private_ips     = ["10.0.1.51"]
  security_groups = [aws_security_group.firewall.id]
  tags = {
    Name = "Weverton"
  }
}

resource "aws_eip" "ip_publico" {
  vpc                       = true
  network_interface         = aws_network_interface.interface_rede.id
  associate_with_private_ip = "10.0.1.51"
  depends_on                = [aws_internet_gateway.gw_brq]
}

output "ip_publico" {
  value = aws_eip.ip_publico.public_ip
}

resource "aws_instance" "app_web" {
  ami               = var.instance_ami
  instance_type     = var.instance_type
  availability_zone = var.aws_az
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.interface_rede.id
  }
  user_data = <<-EOF
               #! /bin/bash
               sudo apt-get update -y
               sudo apt-get install -y apache2
               sudo systemctl start apache2
               sudo systemctl enable apache2
               sudo bash -c 'echo "<h1>Estou funcionando! :D</h1>"  > /var/www/html/index.html'
             EOF
  tags = {
    Name = "RaphaelVeiga"
  }
}