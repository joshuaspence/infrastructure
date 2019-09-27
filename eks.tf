variable "kubernetes_cluster_name" {
  type = string
}

module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name = var.kubernetes_cluster_name
  subnets      = concat(module.vpc.private_subnets, module.vpc.public_subnets)
  vpc_id       = module.vpc.vpc_id

  worker_additional_security_group_ids = []
  worker_groups                        = [
    {
      instance_type = "t3.medium"
    }
  ]
  worker_groups_launch_template = []
  workers_additional_policies   = []
  workers_group_defaults = {
    asg_desired_capacity                     = 1
    asg_max_size                             = 3
    asg_min_size                             = 1
    autoscaling_enabled                      = false
    cpu_credits                              = "standard"
    enable_monitoring                        = false
    kubelet_extra_args                       = ""
    on_demand_allocation_strategy            = null
    on_demand_base_capacity                  = 0
    on_demand_percentage_above_base_capacity = 0
    override_instance_types                  = []
    protect_from_scale_in                    = false
    spot_allocation_strategy                 = "lowest-price"
    spot_instance_pools                      = 10
    spot_max_price                           = 10
    spot_price                               = ""
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
