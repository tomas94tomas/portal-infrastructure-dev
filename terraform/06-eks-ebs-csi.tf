data "tls_certificate" "cert" {
  url = aws_eks_cluster.eks_cl.identity[0].oidc[0].issuer
}

provider "kubectl" {
  host             = aws_eks_cluster.eks_cl.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.eks_cl.certificate_authority.0.data)
  token            = data.aws_eks_cluster_auth.eks_auth.token
  load_config_file = false
}

provider "helm" {
  kubernetes {
    host  = aws_eks_cluster.eks_cl.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.eks_cl.certificate_authority.0.data)
    token = data.aws_eks_cluster_auth.eks_auth.token
  }
}

resource "aws_iam_openid_connect_provider" "openid_connect" {
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cert.certificates.0.sha1_fingerprint]
  url = aws_eks_cluster.eks_cl.identity[0].oidc[0].issuer

  depends_on = [
    aws_eks_cluster.eks_cl,
  ]
}

module "ebs_csi_driver_controller" {
  source  = "DrFaust92/ebs-csi-driver/kubernetes"
  version = "3.10.0"

  ebs_csi_controller_role_name               = "${var.environment}-ebs-csi-driver-controller"
  ebs_csi_controller_role_policy_name_prefix = "${var.environment}-ebs-csi-driver-policy"
  oidc_url                                   = aws_iam_openid_connect_provider.openid_connect.url
}

resource "kubernetes_storage_class" "default" {
  metadata {
    name = "default"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  parameters = {
    type = "gp3"
    fsType = "ext4"
  }

  reclaim_policy      = "Delete"
  volume_binding_mode = "WaitForFirstConsumer"
  storage_provisioner = "ebs.csi.aws.com"
}
