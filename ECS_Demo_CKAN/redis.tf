module "redis" {
    source = "./modules/redis"
    name = local.ckan.default.name
    subnet_ids = module.vpc.private_subnets
    vpc_id = module.vpc.vpc_id
    allowed_cidr_blocks = [local.ckan.default.cidr]
}