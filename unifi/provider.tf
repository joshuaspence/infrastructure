terraform {
  required_providers {
    remote = {
      source = "tenstad/remote"
    }

    unifi = {
      source  = "paultyng/unifi"
      version = ">= 0.41.0"
    }
  }
}

provider "remote" {
  alias = "cloud_key"

  conn {
    host     = var.clients["unifi_network_controller"].fixed_ip
    user     = "root"
    password = var.ssh_config.password
  }
}

provider "remote" {
  alias = "gateway"

  conn {
    host     = format("gateway.%s", var.networks["management"].domain_name)
    user     = var.ssh_config.username
    password = var.ssh_config.password
  }
}

provider "remote" {
  alias = "nvr"

  conn {
    host     = var.clients["unifi_protect_nvr"].fixed_ip
    user     = "root"
    password = var.ssh_config.password
  }
}
