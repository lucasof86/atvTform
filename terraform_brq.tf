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
#END

provider "aws" {
  region     = var.aws_region
  access_key = var.access_key
  secret_key = var.secret_key
}