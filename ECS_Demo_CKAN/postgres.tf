module "postgres" {
  source = "./modules/postgres"
  name = local.ckan.default.name
  subnet_ids = module.vpc.private_subnets
  vpc_id = module.vpc.vpc_id
  allowed_cidr_blocks = [local.ckan.default.cidr]
  #database_username   = var.rds_username
  database_name       = local.ckan.default.rds_database_name
  database_password = local.ckan.default.rds_password
}