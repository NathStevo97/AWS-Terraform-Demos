variable "region" {
  type = string
  description = "AWS Deployment Region"
}

variable "environment" {
  type = string
  description = "Naming Prefix"
}


variable "vpc_cidr" {
  type = string
  description = "IP Address Range for VPC"
}

variable "public_subnet1_cidr" {
  type = string
  description = "IP Allocation for Public Subnet 1"
}

variable "public_subnet2_cidr" {
  type = string
  description = "IP Allocation for Public Subnet 2"
}

variable "private_subnet1_cidr" {
  type = string
  description = "IP Allocation for Private Subnet 1"
}

variable "private_subnet2_cidr" {
  type = string
  description = "IP Allocation for Private Subnet 2"
}

variable "db_name"{
  type = string
  description = "The database name"
}
variable "db_pass"{
    type = string
    description = "The database password"
}

variable "db_user"{
  type = string
  description = "The database user"
}

variable "ami_id" {
  type = string
}