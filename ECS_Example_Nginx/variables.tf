variable "aws_region" {
  description = "Configuring AWS as provider"
  type        = string
  default     = "eu-west-2"
}

# vpc variable
variable "vpc_cidr" {
  description = "CIDR block for main"
  type        = string
  default     = "10.0.0.0/16"
}

# availability zones variable
variable "availability_zones" {
  type    = string
  default = "eu-west-2a"
}