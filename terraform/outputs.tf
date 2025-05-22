output "endpoint" {
  value = aws_eks_cluster.eks_cl.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.eks_cl.certificate_authority[0].data
}

output "cluster-name" {
  value = aws_eks_cluster.eks_cl.name
}

output "cluster-id" {
  value = aws_eks_cluster.eks_cl.id
}

output "oidc_provider_url" {
  description = "The URL of the IAM OIDC provider"
  value       = aws_iam_openid_connect_provider.openid_connect.url
}

output "cluster-region" {
  value = var.region
}
