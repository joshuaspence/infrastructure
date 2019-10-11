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

  worker_groups_launch_template = [
    # asg_desired_capacity
    # asg_max_size
    # asg_min_size
    # asg_recreate_on_change
    # instance_type
    # key_name
    # bootstrap_extra_args
    # kubelet_extra_args
    # subnets
    # autoscaling_enabled
    # protect_from_scale_in
    # root_kms_key_id
    # root_encrypted
    # cpu_credits
    # market_type
    # override_instance_types
    # on_demand_allocation_strategy
    # on_demand_base_capacity
    # on_demand_percentage_above_base_capacity

    {
      instance_type = "t3a.small"
    }
  ]
  workers_group_defaults = {
    autoscaling_enabled = true
    enable_monitoring   = false
    key_name            = null
  }
}

# TODO: Remove this after https://github.com/terraform-aws-modules/terraform-aws-eks/pull/549.
resource "local_file" "kubeconfig" {
  content  = module.eks.kubeconfig
  filename = pathexpand("~/.kube/config")
}

# TODO: This should be managed by the `terraform-aws-modules/eks/aws` modul
# after https://github.com/terraform-aws-modules/terraform-aws-eks/pull/355
resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = yamldecode(module.eks.config_map_aws_auth)["data"]
}
