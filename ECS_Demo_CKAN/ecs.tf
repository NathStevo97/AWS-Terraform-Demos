#----- ECS --------
module "ecs" {
  source = "terraform-aws-modules/ecs/aws"
  cluster_name   = "ckan-ecs"
}

