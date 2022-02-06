locals {
  gateway_config = {
    firewall = {
      modify = {
        LOAD_BALANCE = {
          rule = {
            "2005" = {
              action = "accept"
              destination = {
                address = unifi_static_route.failover_wan.network
              }
            }
          }
        }
      }
    }

    protocols = {
      static = {
        arp = {
          # Enable Wake-on-LAN across different networks.
          for network in unifi_network.network : cidrhost(network.subnet, -2) => {
            hwaddr = "ff:ff:ff:ff:ff:ff"
          }
        }
      }
    }
  }
}

resource "remote_file" "gateway_config" {
  provider = remote.controller
  path     = "/srv/unifi/data/sites/default/config.gateway.json"
  content  = jsonencode(local.gateway_config)

  # TODO: This won't be needed after tenstad/terraform-provider-remote#42.
  provisioner "remote-exec" {
    connection {
      user     = var.ssh_config.username
      password = var.ssh_config.password
      host     = var.clients["unifi_controller"].fixed_ip
    }

    inline = ["chown unifi:unifi ${self.path}"]
  }
}
