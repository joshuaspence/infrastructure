resource "unifi_network" "iot" {
  name    = "IoT"
  purpose = "corporate"

  network_group = "LAN"
  vlan_id       = var.networks.iot.vlan
  subnet        = var.networks.iot.subnet
  domain_name   = "local"
  dhcp_enabled  = true
  dhcp_start    = cidrhost(var.networks.iot.subnet, 6)
  dhcp_stop     = cidrhost(var.networks.iot.subnet, -2)
}

resource "unifi_wlan" "iot" {
  name          = var.wlans.iot.ssid
  security      = "wpapsk"
  passphrase    = var.wlans.iot.passphrase
  network_id    = unifi_network.iot.id
  user_group_id = unifi_user_group.default.id

  no2ghz_oui = false
  wlan_band  = "both"
}
