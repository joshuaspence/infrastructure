resource "unifi_network" "not" {
  name    = "NoT"
  purpose = "corporate"

  network_group = "LAN"
  vlan_id       = var.networks.not.vlan
  subnet        = var.networks.not.subnet
  domain_name   = "local"
  dhcp_enabled  = true
  dhcp_start    = cidrhost(var.networks.not.subnet, 6)
  dhcp_stop     = cidrhost(var.networks.not.subnet, -2)
}

resource "unifi_wlan" "not" {
  name          = var.wlans.not.ssid
  security      = "wpapsk"
  passphrase    = var.wlans.not.passphrase
  network_id    = unifi_network.not.id
  user_group_id = unifi_user_group.default.id

  no2ghz_oui = false
  wlan_band  = "both"
}
