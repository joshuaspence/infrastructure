variable "vpc_name" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "vpc_subnet_count" {
  type = string
}

locals {
  subnet_bits = ceil(log(2 * var.vpc_subnet_count, 2))

  private_subnet_cidr_blocks = [for ii in range(var.vpc_subnet_count) : cidrsubnet(var.vpc_cidr_block, local.subnet_bits, ii)]
  public_subnet_cidr_blocks  = [for ii in range(var.vpc_subnet_count) : cidrsubnet(var.vpc_cidr_block, local.subnet_bits, pow(2, local.subnet_bits - 1) + ii)]

  vpc_tags = {
    "kubernetes.io/cluster/${var.kubernetes_cluster_name}" = "shared"
  }
}

resource "random_shuffle" "aws_availability_zones" {
  input        = data.aws_availability_zones.available.names
  result_count = var.vpc_subnet_count
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2.0"

  name = var.vpc_name
  cidr = var.vpc_cidr_block

  azs             = random_shuffle.aws_availability_zones.result
  private_subnets = local.private_subnet_cidr_blocks
  public_subnets  = local.public_subnet_cidr_blocks

  create_database_subnet_group    = false
  create_elasticache_subnet_group = false
  create_redshift_subnet_group    = false
  enable_nat_gateway              = true

  private_subnet_tags = merge(local.vpc_tags, { "kubernetes.io/role/internal-elb" = 1 })
  public_subnet_tags  = merge(local.vpc_tags, { "kubernetes.io/role/elb" = 1 })
  vpc_tags            = local.vpc_tags
}
