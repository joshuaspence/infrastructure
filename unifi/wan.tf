resource "unifi_wan" "primary" {
  name         = "NBN"
  networkgroup = "WAN"
  type         = "dhcp"
  type_v6      = "dhcpv6"

  /*
  dhcpv6 = {
    pd_size = 48
  }
  */

  load_balance = {
    type   = "weighted"
    weight = 50
  }

  provider_capabilities = {
    download_kilobits_per_second = 500 * 1000
    upload_kilobits_per_second   = 50 * 1000
  }

}

# TODO: Create traffic route for `192.168.0.2`.
resource "unifi_wan" "secondary" {
  name         = "LTE"
  networkgroup = "WAN2"
  type         = "dhcp"
  type_v6      = "disabled"

  load_balance = {
    type              = "failover-only"
    failover_priority = 2
  }
}
