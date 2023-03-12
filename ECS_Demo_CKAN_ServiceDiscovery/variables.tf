variable "admin-cidr-blocks" {
  type = list(string)
}

variable "region" {
  type = string
}

variable "availability_zone_map" {
  type = map(any)
}

variable "name" {
  type = string
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

variable "cidr" {
  type = string
}

variable "hosted_zone_id" {
  type = string
}

variable "rds_readonly_user" {
  type = string
}

variable "rds_readonly_password" {
  type = string
}

variable "ckan_admin" {
  type = string
}

variable "ckan_admin_password" {
  type = string
}