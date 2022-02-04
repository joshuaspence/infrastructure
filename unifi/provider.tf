terraform {
  required_providers {
    remote = {
      source = "tenstad/remote"
    }

    unifi = {
      source  = "paultyng/unifi"
      version = ">= 0.33.0"
    }
  }

  experiments = [
    module_variable_optional_attrs,
  ]
}

provider "remote" {
  alias = "controller"

  conn {
    host     = var.clients["unifi_controller"].fixed_ip
    user     = var.ssh_config.username
    password = var.ssh_config.password
  }
}
