resource "aws_eks_access_policy_association" "eks_access_policy_labrole" {
  cluster_name  = aws_eks_cluster.eks-cluster.name
  policy_arn    = var.policyArn
  principal_arn = var.labRole

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.eks_access_entry_labrole]
}