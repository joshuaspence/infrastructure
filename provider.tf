terraform {
  required_version = ">= 0.12.6"
}

variable "aws_region" {
  type = string
}

provider "aws" {
  region  = var.aws_region
  profile = "personal"
}

data "aws_availability_zones" "available" {
  state = "available"
}

variable "gsuite_impersonated_user_email" {
  type = string
}

provider "gsuite" {
  credentials             = pathexpand("~/.gsuite/personal.json")
  impersonated_user_email = var.gsuite_impersonated_user_email

  oauth_scopes = [
    "https://www.googleapis.com/auth/admin.directory.domain",
    "https://www.googleapis.com/auth/admin.directory.group",
    "https://www.googleapis.com/auth/admin.directory.user",
    "https://www.googleapis.com/auth/apps.groups.settings",
  ]
}
