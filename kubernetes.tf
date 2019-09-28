data "aws_eks_cluster_auth" "main" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.main.token
  load_config_file       = false
}

# TODO: This should be managed by the `terraform-aws-modules/eks/aws` module
# after https://github.com/terraform-aws-modules/terraform-aws-eks/pull/355.
resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = yamldecode(module.eks.config_map_aws_auth)["data"]
}

# TODO: Check this.
resource "kubernetes_service_account" "tiller" {
  metadata {
    name      = "tiller"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role_binding" "tiller" {
  metadata {
    name = "tiller"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.tiller.metadata[0].name
    namespace = kubernetes_service_account.tiller.metadata[0].namespace
  }
}
