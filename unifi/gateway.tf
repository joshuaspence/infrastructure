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
  }
}

# TODO: Configure UXG ports

# TODO: I can't use the `remote_file` resource due to golang/go#8657.
resource "ssh_resource" "multicast_relay" {
  host  = "gateway"
  user  = var.ssh_config.username
  agent = true

  file {
    content = format(
      "INTERFACES='%s'\nRELAY='%s'\n",
      join(" ", [for network in unifi_network.network : format("br%d", network.vlan_id) if network.purpose != "guest"]),
      join(" ", [for device_discovery in local.device_discovery : format("255.255.255.255:%d", device_discovery.broadcast_port)]),
    )
    destination = "/etc/default/multicast-relay"
  }

  file {
    content     = file("${path.module}/scripts/multicast_relay.sh")
    destination = "/etc/init.d/multicast-relay"
    permissions = "0755"
  }

  commands = ["/etc/init.d/multicast-relay restart"]
}
