# Define o provider AWS
provider "aws" {
  region = var.aws_region
}

# Cria a VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.1"

  name                 = "fastfood-vpc"
  cidr                 = "10.0.0.0/16"
  azs                  = ["us-east-1a", "us-east-1b"]
  public_subnets       = ["10.0.1.0/24", "10.0.2.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
}

# Cria o cluster EKS
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "20.8.5"

  cluster_name    = var.cluster_name
  cluster_version = "1.27"
  subnet_ids      = module.vpc.public_subnets
  vpc_id          = module.vpc.vpc_id

  eks_managed_node_groups = {
    default = {
      instance_types = ["t3.medium"]
      desired_size   = 2
      min_size       = 2
      max_size       = 4
    }
  }

  enable_irsa = true
}

# Dados do cluster para autenticação no provider Kubernetes e Kubectl
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

# Provider Kubernetes (usado por outros recursos Terraform, se usar kubernetes_* resources)
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

# Define o provider do kubectl (usado para aplicar YAMLs diretamente)
terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}

provider "kubectl" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}

# Aplica os arquivos YAML no cluster via kubectl_manifest
resource "kubectl_manifest" "configmap" {
  yaml_body = file("${path.module}/k8s/configmap.yaml")
}

resource "kubectl_manifest" "secrets" {
  yaml_body = file("${path.module}/k8s/secrets.yaml")
}

resource "kubectl_manifest" "deployment" {
  yaml_body = file("${path.module}/k8s/deployment.yaml")
}

resource "kubectl_manifest" "service" {
  yaml_body = file("${path.module}/k8s/service.yaml")
}

resource "kubectl_manifest" "hpa" {
  yaml_body = file("${path.module}/k8s/hpa.yaml")
}
