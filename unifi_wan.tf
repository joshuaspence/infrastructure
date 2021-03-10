resource "unifi_network" "wan" {
  name    = "WAN"
  purpose = "wan"

  wan_networkgroup = "WAN"
  wan_type         = "dhcp"

  # TODO: Remove this after https://github.com/paultyng/terraform-provider-unifi/issues/107.
  lifecycle {
    ignore_changes = [dhcp_lease, ipv6_interface_type, network_group, wan_ip]
  }
}

# TODO: Set `icmp_typename`, see https://github.com/paultyng/terraform-provider-unifi/pull/108.
resource "unifi_firewall_rule" "wan_ping" {
  name          = "ICMP Ping"
  ruleset       = "WAN_LOCAL"
  rule_index    = 2000
  action        = "accept"
  protocol      = "icmp"
  icmp_typename = "echo-request"
}
