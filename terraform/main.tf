# main.tf | Main Configuration

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.37"
    }
  }
  backend "s3" {
    bucket = "myapp-tfbucket"
    key = "state/state.tfstate"
    region = "eu-west-3"
  }
}

provider "aws" {
  region = var.aws_region
}
