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