variable "kubernetes_cluster_name" {
  type = string
}

variable "kubernetes_cluster_version" {
  type = string
}

# TODO: Tweak logging settings.
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 6.0"

  cluster_name              = var.kubernetes_cluster_name
  cluster_version           = var.kubernetes_cluster_version
  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  subnets                   = concat(module.vpc.private_subnets, module.vpc.public_subnets)
  vpc_id                    = module.vpc.vpc_id

  # TODO: Disable public access to cluster endpoint.
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  manage_aws_auth       = false
  write_aws_auth_config = false
  write_kubeconfig      = false

  kubeconfig_aws_authenticator_env_variables = {
    AWS_PROFILE = var.aws_profile
  }

  # TODO: Possibly use spot instances?
  # TODO: Configure `asg_min_size`, `asg_max_size` and `asg_desired_capacity`.
  # TODO: Possibly configure `cpu_credits`.
  # TODO: Possibly enable `protect_from_scale_in`.
  worker_groups_launch_template = [
    {
      instance_type = "t3a.small"
    }
  ]
  workers_group_defaults = {
    autoscaling_enabled = true
    enable_monitoring   = false
  }
}

# TODO: Remove this after https://github.com/terraform-aws-modules/terraform-aws-eks/pull/549.
resource "local_file" "kubeconfig" {
  content  = module.eks.kubeconfig
  filename = pathexpand("~/.kube/config")
}
