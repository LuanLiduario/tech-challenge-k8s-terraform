data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

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
