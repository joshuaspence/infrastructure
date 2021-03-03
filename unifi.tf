resource "unifi_site" "default" {
  description = "Home"
}

data "unifi_ap_group" "default" {}

resource "unifi_user_group" "default" {
  name = "Default"
}


#===============================================================================
# WAN network
#===============================================================================

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


#===============================================================================
# LAN networks
#===============================================================================

variable "home_networks" {
  type = map(object({
    name    = string
    vlan_id = number
    subnet  = string

    wifi = object({
      ssid       = string
      passphrase = string
    })
  }))
}

resource "unifi_network" "lan" {
  name    = each.value.name
  purpose = "corporate"

  vlan_id       = each.value.vlan_id
  subnet        = each.value.subnet
  network_group = "LAN"

  dhcp_enabled = true
  dhcp_start   = cidrhost(each.value.subnet, 6)
  dhcp_stop    = cidrhost(each.value.subnet, -2)
  domain_name  = "local"

  for_each = var.home_networks
}

resource "unifi_wlan" "wifi" {
  name       = each.value.wifi.ssid
  security   = "wpapsk"
  passphrase = each.value.wifi.passphrase

  ap_group_ids  = [data.unifi_ap_group.default.id]
  network_id    = unifi_network.lan[each.key].id
  user_group_id = unifi_user_group.default.id

  for_each = var.home_networks
}
