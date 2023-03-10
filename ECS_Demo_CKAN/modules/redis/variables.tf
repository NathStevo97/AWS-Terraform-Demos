variable "name" {
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