output "cluster_name" {
  value = aws_eks_cluster.eks-cluster.name
}

output "vpc_id" {
  value = data.aws_vpc.vpc.id
}
