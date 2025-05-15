module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "fastfood-cluster"
  cluster_version = "1.27"
  subnets         = module.vpc.public_subnets
  vpc_id          = module.vpc.vpc_id
  enable_irsa     = true
  manage_aws_auth = true
}
