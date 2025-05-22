resource "aws_eks_cluster" "eks_cl" {
  name     = "${var.environment}-${var.cluster_name}"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = [aws_subnet.public-subnet-1.id,aws_subnet.public-subnet-2.id]
  }



  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy
  ]
}

resource "aws_eks_node_group" "eks_ng" {
  cluster_name    = aws_eks_cluster.eks_cl.name
  node_group_name = "${var.environment}-${var.cluster_name}-node-group"
  node_role_arn   = aws_iam_role.ec2_role.arn
  subnet_ids = [aws_subnet.public-subnet-1.id,aws_subnet.public-subnet-2.id]
  instance_types = var.instance_types
  disk_size = var.instance_disk_size
  scaling_config {
    desired_size = local.desired_size
    max_size     = local.max_size
    min_size     = local.min_size
  }
  lifecycle {
    prevent_destroy = false
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}

provider "kubernetes" {
  host                   = aws_eks_cluster.eks_cl.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.eks_cl.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.eks_auth.token
}

data "aws_eks_cluster_auth" "eks_auth" {
  name = aws_eks_cluster.eks_cl.name
}

