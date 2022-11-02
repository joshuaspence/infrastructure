locals {
  wan_dns = ["1.1.1.1", "8.8.8.8"]
}

# TODO: Add IPv6 settings.
resource "unifi_network" "wan" {
  name    = "WAN"
  purpose = "wan"

  wan_networkgroup    = "WAN"
  wan_type            = "dhcp"
  wan_type_v6         = "dhcpv6"
  wan_dhcp_v6_pd_size = 48
  wan_dns             = local.wan_dns

  # TODO: Remove this after https://github.com/paultyng/terraform-provider-unifi/issues/107.
  lifecycle {
    ignore_changes = [dhcp_lease, dhcp_v6_dns_auto, dhcp_v6_lease, ipv6_interface_type, ipv6_ra_preferred_lifetime, ipv6_ra_valid_lifetime, network_group]
  }
}

# TODO: Create traffic route for `192.168.0.2`.
resource "unifi_network" "failover_wan" {
  name    = "Failover WAN"
  purpose = "wan"

  wan_networkgroup = "WAN2"
  wan_type         = "dhcp"
  wan_type_v6      = "disabled"
  wan_dns          = local.wan_dns

  # TODO: Remove this after https://github.com/paultyng/terraform-provider-unifi/issues/107.
  lifecycle {
    ignore_changes = [dhcp_lease, dhcp_v6_dns_auto, dhcp_v6_lease, ipv6_interface_type, ipv6_ra_preferred_lifetime, ipv6_ra_valid_lifetime, network_group]
  }
}
