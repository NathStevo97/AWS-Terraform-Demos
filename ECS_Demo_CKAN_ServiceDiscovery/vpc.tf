# VPC

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.name}-vpc"

  cidr = var.cidr

  azs             = formatlist("%s%s", var.region, keys(var.availability_zone_map))

  private_subnets = [for n in toset(values(var.availability_zone_map)) : cidrsubnet(var.cidr, 8, tonumber(n) + 128)]
  /*
  private_dedicated_network_acl = true
  private_inbound_acl_rules = [
    merge(local.acls.http, { rule_number = 100, cidr_block = var.cidr }),
    merge(local.acls.https, { rule_number = 101, cidr_block = var.cidr }),
    merge(local.acls.ntp, { rule_number = 102 }),
    merge(local.acls.ephemeral, { rule_number = 103 }),
  ]
  private_outbound_acl_rules = [
    merge(local.acls.all, { rule_number = 100, cidr_block = var.cidr }),
    merge(local.acls.http, { rule_number = 101 }),
    merge(local.acls.https, { rule_number = 102 }),
    merge(local.acls.smtp, { rule_number = 103 }),
    merge(local.acls.ephemeral, { rule_number = 104 }),
  ]
  */

  public_subnets  = [for n in toset(values(var.availability_zone_map)) : cidrsubnet(var.cidr, 8, tonumber(n))]
  /*
  public_dedicated_network_acl = true
  public_inbound_acl_rules = [
    merge(local.acls.http, { rule_number = 100 }),
    merge(local.acls.https, { rule_number = 101 }),
    merge(local.acls.ntp, { rule_number = 102 }),
    merge(local.acls.smtp, { rule_number = 103 }),
    merge(local.acls.ephemeral, { rule_number = 104 }),
    merge(local.acls.ephemeral, { rule_number = 105, protocol = "udp" })
  ]
  public_outbound_acl_rules = [
    merge(local.acls.all, { rule_number = 100, cidr_block = var.cidr }),
    merge(local.acls.http, { rule_number = 101 }),
    merge(local.acls.https, { rule_number = 102 }),
    merge(local.acls.ntp, { rule_number = 103 }),
    merge(local.acls.smtp, { rule_number = 104 }),
    merge(local.acls.ephemeral, { rule_number = 105 }),
  ]
  */

  enable_dns_hostnames    = true
  enable_dns_support      = true
  map_public_ip_on_launch = true

  enable_nat_gateway = true
  single_nat_gateway = true

}