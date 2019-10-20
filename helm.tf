/**
 * TODO: All `helm_release` resources should depend on the `eks` module, see
 * https://github.com/hashicorp/terraform/issues/2430.
 */

# TODO: Check version of `cluster-autoscaler`.
resource "helm_release" "autoscaler" {
  name   = "autoscaler"
  chart  = "stable/cluster-autoscaler"

  set {
    name  = "autoDiscovery.clusterName"
    value = module.eks.cluster_id
  }

  set {
    name  = "autoDiscovery.enabled"
    value = "true"
  }

  set {
    name  = "awsRegion"
    value = var.aws_region
  }

  set {
    name  = "cloudProvider"
    value = "aws"
  }

  set {
    name  = "rbac.create"
    value = "true"
  }
}
