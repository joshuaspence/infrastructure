variable "kubernetes_cluster_name" {
  type = string
}

variable "kubernetes_cluster_version" {
  type = string
}

# TODO: `subnets` should include both public and private subnets.
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 6.0"

  cluster_name              = var.kubernetes_cluster_name
  cluster_version           = var.kubernetes_cluster_version
  cluster_enabled_log_types = ["api", "controllerManager", "scheduler"]
  subnets                   = module.vpc.public_subnets
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
    # asg_recreate_on_change
    # bootstrap_extra_args
    # kubelet_extra_args
    # subnets
    # root_kms_key_id
    # root_encrypted
    # cpu_credits
    # market_type
    # override_instance_types
    # on_demand_allocation_strategy
    # on_demand_base_capacity
    # on_demand_percentage_above_base_capacity

    {
      asg_max_size  = 10
      instance_type = "t3a.small"
    }
  ]
  workers_group_defaults = {
    asg_desired_capacity  = 0
    asg_min_size          = 0
    autoscaling_enabled   = true
    enable_monitoring     = false
    protect_from_scale_in = true

    # TODO: Figure out why worker nodes can't join the cluster without a public IP.
    # I think this will be fixed by https://github.com/terraform-providers/terraform-provider-aws/issues/6777.
    public_ip = true
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
