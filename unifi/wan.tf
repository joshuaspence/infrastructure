locals {
  failover_wan_subnet = "192.168.200.0/24"
  wan_dns             = ["1.1.1.1", "8.8.8.8"]
}

# TODO: Add IPv6 settings.
resource "unifi_network" "wan" {
  name    = "WAN"
  purpose = "wan"

  wan_networkgroup = "WAN"
  wan_type         = "dhcp"
  wan_dns          = local.wan_dns

  # TODO: Remove this after https://github.com/paultyng/terraform-provider-unifi/issues/107.
  lifecycle {
    ignore_changes = [dhcp_lease, ipv6_interface_type, network_group]
  }
}

resource "unifi_network" "failover_wan" {
  name    = "Failover WAN"
  purpose = "wan"

  wan_networkgroup = "WAN2"
  wan_type         = "static"
  wan_ip           = cidrhost(local.failover_wan_subnet, 2)
  wan_netmask      = cidrnetmask(local.failover_wan_subnet)
  wan_gateway      = cidrhost(local.failover_wan_subnet, 1)
  wan_dns          = local.wan_dns

  # TODO: Remove this after https://github.com/paultyng/terraform-provider-unifi/issues/107.
  lifecycle {
    ignore_changes = [dhcp_lease, ipv6_interface_type, network_group]
  }
}

# TODO: Is this actually needed?
resource "unifi_static_route" "failover_wan" {
  name     = "Failover WAN Admin UI"
  type     = "nexthop-route"
  network  = local.failover_wan_subnet
  distance = 1
  next_hop = unifi_network.failover_wan.wan_ip
}
