terraform {
  required_version = ">= 0.15"

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }

    google = {
      source = "hashicorp/google"
    }

    google-beta = {
      source = "hashicorp/google-beta"
    }

    gsuite = {
      source = "DeviaVir/gsuite"
    }

    tfe = {
      source = "hashicorp/tfe"
    }

    unifi = {
      source = "paultyng/unifi"
    }
  }

  backend "remote" {
    organization = "spence"

    workspaces {
      name = "home"
    }
  }

  experiments = [
    module_variable_optional_attrs,
  ]
}

#===============================================================================
# AWS
#===============================================================================

variable "aws_region" {
  type = string

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.aws_region))
    error_message = "AWS region should be a valid AWS region."
  }
}

variable "aws_profile" {
  type = string

  /*
  validation {
    condition     = contains([for matches in regexall("\\[(.*)\\]", file("~/.aws/credentials")) : matches[0]], var.aws_profile)
    error_message = "AWS profile not found in ~/.aws/credentials."
  }
  */
}

variable "aws_account_id" {
  type = string

  validation {
    condition     = can(regex("^\\d{12}$", var.aws_account_id))
    error_message = "Invalid AWS account ID."
  }
}

provider "aws" {
  region              = var.aws_region
  profile             = var.aws_profile
  allowed_account_ids = [var.aws_account_id]
}

#===============================================================================
# Github
#===============================================================================

variable "github_token" {
  type      = string
  sensitive = true
}

provider "github" {
  token = var.github_token
}

#===============================================================================
# Google
#===============================================================================

provider "google" {}

provider "google-beta" {
  # TODO: Why is this needed?
  credentials           = pathexpand(var.gsuite_credentials_file)
  user_project_override = true
}

data "google_organization" "main" {
  domain = var.primary_domain
}

#===============================================================================
# GSuite
#===============================================================================

variable "gsuite_credentials_file" {
  type = string

  validation {
    condition     = fileexists(var.gsuite_credentials_file)
    error_message = "Gsuite credentials file does not exist."
  }
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
# Terraform Enterprise
#===============================================================================

provider "tfe" {}

#===============================================================================
# Unifi
#===============================================================================

variable "unifi_username" {
  type = string
}

variable "unifi_password" {
  type      = string
  sensitive = true
}

variable "unifi_api_url" {
  type = string
}

variable "unifi_allow_insecure" {
  type = bool
}

provider "unifi" {
  username       = var.unifi_username
  password       = var.unifi_password
  api_url        = var.unifi_api_url
  allow_insecure = var.unifi_allow_insecure
}
