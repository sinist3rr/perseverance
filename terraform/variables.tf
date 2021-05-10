# variables.tf | Auth and Application variables

variable "aws_region" {
  type = string
  description = "AWS Region"
}

variable "app_name" {
  type = string
  description = "Application Name"
}

variable "app_environment" {
  type = string
  description = "Application Environment"
}

variable "cidr" {
  description = "The CIDR block for the VPC"
  default = "10.0.0.0/16"
}

variable "public_subnets" {
  type = list(string)
  description = "List of public subnets"
}

variable "private_subnets" {
  type = list(string)
  description = "List of private subnets"
}

variable "availability_zones" {
  type = list(string)
  description = "List of availability zones"
}

variable "nasa_api_key" {
  type = string
  description = "NASA API KEY"
  default = "DEMO_KEY"
}