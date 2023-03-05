variable "region" {
  type = string
  default = "eu-west-2"
}
variable "ip_whitelist" {
  type        = list(string)
  description = "A list of IPs to whitelist for access to the service"
}