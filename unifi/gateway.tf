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
}
