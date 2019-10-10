# TODO: This should be managed by the `terraform-aws-modules/eks/aws` module
# after https://github.com/terraform-aws-modules/terraform-aws-eks/pull/355.
resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = yamldecode(module.eks.config_map_aws_auth)["data"]
}
