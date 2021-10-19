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
  wan_type         = "static"
  wan_ip           = "192.168.200.1"
  wan_netmask      = "255.255.255.0"
  wan_dns          = ["1.1.1.1", "8.8.8.8"]

  # TODO: Remove this after https://github.com/paultyng/terraform-provider-unifi/issues/107.
  lifecycle {
    ignore_changes = [dhcp_lease, ipv6_interface_type, network_group]
  }
}
