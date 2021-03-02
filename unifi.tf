resource "unifi_site" "default" {
  description = "Home"
}

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

resource "unifi_network" "wan" {
  name    = "WAN"
  purpose = "wan"

  network_group    = "WAN"
  wan_networkgroup = "WAN"
  wan_ip           = "192.168.1.1"
  wan_type         = "dhcp"
  dhcp_lease       = 0

  # TODO: Remove this.
  lifecycle {
    ignore_changes = [ipv6_interface_type, network_group]
  }
}

data "unifi_ap_group" "default" {}

resource "unifi_user_group" "default" {
  name = "Default"
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
