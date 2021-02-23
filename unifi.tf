resource "unifi_site" "default" {
  description = "Default"
}

resource "unifi_network" "lan" {
  name    = "LAN"
  purpose = "corporate"

  subnet       = "10.0.0.1/24"
  domain_name  = "local"

  dhcp_enabled = true
  dhcp_start   = "10.0.0.6"
  dhcp_stop    = "10.0.0.254"
}

data "unifi_ap_group" "default" {}

resource "unifi_user_group" "default" {
  name = "Default"
}

variable "wifi_passphrase" {
  type      = string
  sensitive = true
}

resource "unifi_wlan" "wifi" {
  name       = "spence"
  security   = "wpapsk"
  passphrase = var.wifi_passphrase

  ap_group_ids  = [data.unifi_ap_group.default.id]
  network_id    = unifi_network.lan.id
  user_group_id = unifi_user_group.default.id
}
