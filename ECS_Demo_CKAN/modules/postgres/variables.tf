variable "name" {
  type = string
}

variable "database_name" {
  type = string
}

variable "database_password" {
  type = string
}

variable "subnet_ids" {
    type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "allowed_cidr_blocks" {
  type = list(string)
}