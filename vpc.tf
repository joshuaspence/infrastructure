variable "vpc_name" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

locals {
  subnet_count = length(data.aws_availability_zones.available.names)
  subnet_bits  = ceil(log(2 * local.subnet_count, 2))

  private_subnet_cidr_blocks = [for ii in range(local.subnet_count) : cidrsubnet(var.vpc_cidr_block, local.subnet_bits, ii)]
  public_subnet_cidr_blocks  = [for ii in range(local.subnet_count) : cidrsubnet(var.vpc_cidr_block, local.subnet_bits, pow(2, local.subnet_bits - 1) + ii)]
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2.0"

  name = var.vpc_name
  cidr = var.vpc_cidr_block

  azs             = data.aws_availability_zones.available.names
  private_subnets = local.private_subnet_cidr_blocks
  public_subnets  = local.public_subnet_cidr_blocks

  create_database_subnet_group    = false
  create_elasticache_subnet_group = false
  create_redshift_subnet_group    = false
  enable_dns_hostnames            = true
  enable_dns_support              = true
  enable_nat_gateway              = true
}
