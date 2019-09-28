variable "kubernetes_cluster_name" {
  type = string
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 6.0"

  cluster_name = var.kubernetes_cluster_name
  subnets      = concat(module.vpc.private_subnets, module.vpc.public_subnets)
  vpc_id       = module.vpc.vpc_id

  # TODO: Possibly use launch templates instead of launch configurations?
  # TODO: Possibly use spot instances?
  # TODO: Configure `asg_min_size`, `asg_max_size` and `asg_desired_capacity`.
  # TODO: Possibly configure `cpu_credits`.
  # TODO: Possibly enable `protect_from_scale_in`.
  worker_groups = [
    {
      instance_type = "t3a.small"
    }
  ]
  workers_group_defaults = {
    autoscaling_enabled = true
    enable_monitoring   = false
  }

  manage_aws_auth       = false
  write_aws_auth_config = false
  write_kubeconfig      = false

  map_accounts = []
  map_roles    = []
  map_users    = []

  kubeconfig_aws_authenticator_env_variables = {
    AWS_PROFILE = var.aws_profile
  }
}

resource "local_file" "kubeconfig" {
  content  = module.eks.kubeconfig
  filename = pathexpand("~/.kube/config")
}
