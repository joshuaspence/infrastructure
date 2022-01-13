# TODO: Manage `dhcp_ntp_server`.
resource "unifi_network" "network" {
  name    = each.value.name
  purpose = "corporate"

  network_group = "LAN"
  vlan_id       = each.value.vlan
  subnet        = each.value.subnet
  domain_name   = "spence.network"
  igmp_snooping = true
  dhcp_enabled  = true
  dhcp_start    = cidrhost(each.value.subnet, 6)
  dhcp_stop     = cidrhost(each.value.subnet, -2)

  ipv6_interface_type = each.value.ipv6_enabled == true ? "pd" : "none"
  ipv6_pd_interface   = each.value.ipv6_enabled == true ? "wan" : null
  ipv6_pd_prefixid    = each.value.ipv6_enabled == true ? 56 : null
  ipv6_ra_enable      = each.value.ipv6_enabled == true ? true : null

  for_each = var.networks
}

resource "unifi_wlan" "wlan" {
  name       = each.value.wifi.ssid
  security   = "wpapsk"
  passphrase = each.value.wifi.passphrase
  network_id = unifi_network.network[each.key].id

  wlan_band         = coalesce(each.value.wifi.band, "both")
  ap_group_ids      = [data.unifi_ap_group.default.id]
  user_group_id     = unifi_user_group.default.id
  multicast_enhance = true
  no2ghz_oui        = false
  hide_ssid         = coalesce(each.value.wifi.hide_ssid, false)

  for_each = var.networks
}
