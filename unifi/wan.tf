# TODO: Add IPv6 settings.
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
  }
}

resource "remote_file" "gateway_config" {
  conn {
    host     = var.clients["unifi_controller"].fixed_ip
    user     = var.ssh_config.username
    password = var.ssh_config.password
  }

  path    = "/srv/unifi/data/sites/default/config.gateway.json"
  content = jsonencode(local.gateway_config)
}
