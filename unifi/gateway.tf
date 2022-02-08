/**
 * TODO: Configure the following:
 *
 * - Device interfaces (Settings > Ports)
 * - Advanced config (Settings > Config > Advanced)
 */

locals {
  domain = unifi_network.network["main"].domain_name

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

    system = {
      # TODO: Maybe move these to Route53.
      static-host-mapping = {
        host-name = {
          "setup.ubnt.com" = {
            alias = ["setup"]
            inet  = [cidrhost(unifi_network.network["main"].subnet, 1)]
          }

          "homeassistant.${local.domain}" = {
            alias = ["homeassistant"]
            inet  = [unifi_user.client["home_assistant"].fixed_ip]
          }

          "unifi.${local.domain}" = {
            alias = ["unifi"]
            inet  = [unifi_user.client["unifi_controller"].fixed_ip]
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
