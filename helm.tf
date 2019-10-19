locals {
  autoscaler_config = {
    rbac = {
      create = true
    }

    cloudProvider = "aws"
    awsRegion     = var.aws_region

    autoDiscovery = {
      clusterName = module.eks.cluster_id
      enabled     = true
    }
  }
}

# TODO: Check version of `cluster-autoscaler`.
resource "helm_release" "autoscaler" {
  name   = "autoscaler"
  chart  = "stable/cluster-autoscaler"
  values = [yamlencode(local.autoscaler_config)]
}
