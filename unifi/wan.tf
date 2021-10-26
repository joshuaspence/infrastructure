resource "unifi_network" "wan" {
  name    = "WAN"
  purpose = "wan"

  wan_networkgroup = "WAN"
  wan_type         = "dhcp"
  wan_dns          = ["1.1.1.1", "8.8.8.8"]

  # TODO: Remove this after https://github.com/paultyng/terraform-provider-unifi/issues/107.
  lifecycle {
    ignore_changes = [dhcp_lease, ipv6_interface_type, network_group]
  }
}

resource "unifi_network" "failover_wan" {
  name    = "Failover WAN"
  purpose = "wan"

  wan_networkgroup = "WAN2"
  wan_type         = "dhcp"
  wan_dns          = ["1.1.1.1", "8.8.8.8"]

  # TODO: Remove this after https://github.com/paultyng/terraform-provider-unifi/issues/107.
  lifecycle {
    ignore_changes = [dhcp_lease, ipv6_interface_type, network_group]
  }
}

# TODO: Improve this.
resource "unifi_static_route" "failover_wan" {
  name      = "Failover WAN Admin UI"
  network   = "192.168.200.0/24"
  type      = "interface-route"
  interface = unifi_network.failover_wan.wan_networkgroup

  # TODO: This shouldn't be needed.
  distance = 1

  lifecycle {
    ignore_changes = [distance]
  }
}

output "gateway_config" {
  value = {
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
