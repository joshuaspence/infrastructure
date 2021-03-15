resource "unifi_network" "main" {
  name    = "LAN"
  purpose = "corporate"

  network_group = "LAN"
  vlan_id       = var.networks.main.vlan
  subnet        = var.networks.main.subnet
  domain_name   = "local"
  dhcp_enabled  = true
  dhcp_start    = cidrhost(var.networks.main.subnet, 6)
  dhcp_stop     = cidrhost(var.networks.main.subnet, -2)
}

resource "unifi_wlan" "main" {
  name          = var.wlans.main.ssid
  security      = "wpapsk"
  passphrase    = var.wlans.main.passphrase
  network_id    = unifi_network.main.id
  ap_group_ids  = [data.unifi_ap_group.default.id]
  user_group_id = unifi_user_group.default.id

  no2ghz_oui = false
  wlan_band  = "both"
}
