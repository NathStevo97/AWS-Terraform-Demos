module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name

  cidr = local.ckan.default.cidr

  azs = local.ckan.default.zones

  enable_dns_hostnames = true
  enable_dns_support = true
  map_public_ip_on_launch = true

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnets = [
    for n in toset(values(local.zone_map)) : cidrsubnet (local.ckan.default.cidr, 8, tonumber(n))
    ]
  
  private_subnets = [
    for n in toset(values(local.zone_map)) : cidrsubnet (local.ckan.default.cidr, 8, tonumber(n) + 128 )
    ]

  tags = {
    Name = "ckan-vpc"
  }
}
