terraform {
  required_version = ">= 0.12.6"

  backend "remote" {
    organization = "spence"

    workspaces {
      name = "home"
    }
  }
}

#===============================================================================
# AWS
#===============================================================================

variable "aws_region" {
  type = string
}

variable "aws_profile" {
  type = string
}

# TODO: Possibly set `allowed_account_ids`.
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

#===============================================================================
# GSuite
#===============================================================================

variable "gsuite_credentials_file" {
  type = string
}

variable "gsuite_impersonated_user_email" {
  type = string
}

provider "gsuite" {
  credentials             = pathexpand(var.gsuite_credentials_file)
  impersonated_user_email = var.gsuite_impersonated_user_email

  oauth_scopes = [
    "https://www.googleapis.com/auth/admin.directory.domain",
    "https://www.googleapis.com/auth/admin.directory.group",
    "https://www.googleapis.com/auth/admin.directory.user",
    "https://www.googleapis.com/auth/apps.groups.settings",
  ]
}

#===============================================================================
# Helm
#===============================================================================

provider "helm" {
  kubernetes {
    config_context = var.kubernetes_config_context
  }

  version = ">= 0.10.4"
}

#===============================================================================
# Kubernetes
#===============================================================================

variable "kubernetes_config_context" {
  type = string
}

provider "kubernetes" {
  config_context = var.kubernetes_config_context
}
