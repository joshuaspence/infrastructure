resource "unifi_site" "default" {
  description = "Default"
}

variable "home_lan" {
  type = object({
    domain = string
    subnet = string
  })
}

resource "unifi_network" "lan" {
  name    = "LAN"
  purpose = "corporate"

  vlan_id       = null
  subnet        = var.home_lan.subnet
  network_group = "LAN"

  dhcp_enabled = true
  dhcp_start   = cidrhost(var.home_lan.subnet, 6)
  dhcp_stop    = cidrhost(var.home_lan.subnet, -2)
  domain_name  = var.home_lan.domain
}

data "unifi_ap_group" "default" {}

resource "unifi_user_group" "default" {
  name = "Default"
}

variable "home_wifi" {
  type = object({
    ssid       = string
    passphrase = string
  })
}

resource "unifi_wlan" "wifi" {
  name       = var.home_wifi.ssid
  security   = "wpapsk"
  passphrase = var.home_wifi.passphrase

  ap_group_ids  = [data.unifi_ap_group.default.id]
  network_id    = unifi_network.lan.id
  user_group_id = unifi_user_group.default.id
}
