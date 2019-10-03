variable "vpc_cidr_block" {
  type = string
}

variable "vpc_subnet_count" {
  type = string
}

locals {
  # Split the VPC CIDR block into enough equally-sized ranges to accommodate
  # `var.vpc_subnet_count` public subnets and `var.vpc_subnet_count` private 
  # subnets.
  subnet_bits                = ceil(log(2 * var.vpc_subnet_count, 2))
  private_subnet_cidr_blocks = [for ii in range(var.vpc_subnet_count) : cidrsubnet(var.vpc_cidr_block, local.subnet_bits, ii)]
  public_subnet_cidr_blocks  = [for ii in range(var.vpc_subnet_count) : cidrsubnet(var.vpc_cidr_block, local.subnet_bits, pow(2, local.subnet_bits - 1) + ii)]

  vpc_tags = {
    "kubernetes.io/cluster/${var.kubernetes_cluster_name}" = "shared"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "random_shuffle" "aws_availability_zones" {
  input        = data.aws_availability_zones.available.names
  result_count = var.vpc_subnet_count
}

# TODO: Enable some VPC endpoints and VPC endpoint services.
# TODO: Enable IPv6 support via `enable_ipv6` and `assign_ipv6_address_on_creation`.
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2.0"

  azs                 = random_shuffle.aws_availability_zones.result
  cidr                = var.vpc_cidr_block
  private_subnets     = local.private_subnet_cidr_blocks
  private_subnet_tags = merge(local.vpc_tags, { "kubernetes.io/role/internal-elb" = 1 })
  public_subnets      = local.public_subnet_cidr_blocks
  public_subnet_tags  = merge(local.vpc_tags, { "kubernetes.io/role/elb" = 1 })
  vpc_tags            = local.vpc_tags

  create_database_subnet_group    = false
  create_elasticache_subnet_group = false
  create_redshift_subnet_group    = false
  enable_dns_hostnames            = true
  enable_dns_support              = true
  enable_nat_gateway              = true
  single_nat_gateway              = true
}

resource "aws_route53_zone" "private" {
  name = "private"

  vpc {
    vpc_id = module.vpc.vpc_id
  }
}
