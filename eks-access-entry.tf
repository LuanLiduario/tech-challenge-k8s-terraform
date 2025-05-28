resource "aws_eks_access_entry" "eks_access_entry_labrole" {
  cluster_name      = aws_eks_cluster.eks-cluster.name
  principal_arn     = var.labRole
  kubernetes_groups = ["fiap"]
  type              = "STANDARD"
}
