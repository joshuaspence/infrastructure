# TODO: Manage `dhcp_ntp_server`.
resource "unifi_network" "network" {
  name    = each.value.name
  purpose = "corporate"

  network_group = "LAN"
  vlan_id       = var.networks[each.key].vlan
  subnet        = var.networks[each.key].subnet
  domain_name   = "local"
  dhcp_enabled  = true
  dhcp_start    = cidrhost(var.networks[each.key].subnet, 6)
  dhcp_stop     = cidrhost(var.networks[each.key].subnet, -2)

  for_each = var.networks
}

resource "unifi_wlan" "wlan" {
  name          = var.networks[each.key].wifi.ssid
  security      = "wpapsk"
  passphrase    = var.networks[each.key].wifi.passphrase
  network_id    = unifi_network.network[each.key].id
  wlan_band     = "both"
  ap_group_ids  = [data.unifi_ap_group.default.id]
  user_group_id = unifi_user_group.default.id
  no2ghz_oui    = false

  for_each = var.networks
}
