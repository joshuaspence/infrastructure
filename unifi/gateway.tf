/**
 * TODO: Configure the following:
 *
 * - Device interfaces (Settings > Ports)
 * - Advanced config (Settings > Config > Advanced)
 */

locals {
  domain = unifi_network.network["main"].domain_name

  # TODO: Figure out how to do this on the UXG-Pro.
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

    service = {
      bcast-relay = local.bcast_relay_config
    }
  }
}
