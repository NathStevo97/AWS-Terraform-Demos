variable "vpc_name" {
  type = string
}

variable "vpc_availability_zones" {
  type = list(string)
}

variable "admin-cidr-blocks" {
  type = list(string)
}

variable "rds_database_name" {
  type = string
}

variable "rds_username" {
  type = string
}

variable "rds_password" {
  type = string
}

variable "hosted_zone" {
  type = string
}

variable "datastore_readonly_password" {
  type = string
}

variable "ckan_admin" {
  type = string
}

variable "ckan_admin_password" {
  type = string
}

variable "region" {
  type = string
}