module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name

  cidr = "10.2.0.0/16"

  azs = var.vpc_availability_zones
  private_subnets = [
    "10.2.1.0/24",
    "10.2.2.0/24",
    "10.2.3.0/24"]
    public_subnets = [
    "10.2.11.0/24",
    "10.2.12.0/24",
    "10.2.13.0/24"]

  enable_dns_hostnames = true
  enable_dns_support = true
  map_public_ip_on_launch = true

  enable_nat_gateway = true
  single_nat_gateway = true

  create_database_subnet_group = true
  create_database_subnet_route_table = true
  create_database_internet_gateway_route = true

  create_elasticache_subnet_group = true
  create_elasticache_subnet_route_table = true

  tags = {
    Name = "ckan-poc-vpc"
  }
}
