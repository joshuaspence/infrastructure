locals {
  networks = defaults(var.networks, {
    purpose      = "corporate"
    ipv6_enabled = false

    wifi = {
      band      = "both"
      hide_ssid = false
    }
  })
}

# TODO: Manage `dhcp_ntp_server`.
resource "unifi_network" "network" {
  name    = each.value.name
  purpose = each.value.purpose

  network_group = "LAN"
  vlan_id       = each.value.vlan
  subnet        = each.value.subnet
  domain_name   = each.value.domain_name
  igmp_snooping = true
  dhcp_enabled  = true
  dhcp_start    = cidrhost(each.value.subnet, 6)
  dhcp_stop     = cidrhost(each.value.subnet, -3)

  ipv6_interface_type = each.value.ipv6_enabled ? "pd" : "none"
  ipv6_pd_interface   = each.value.ipv6_enabled ? "wan" : null
  ipv6_pd_prefixid    = each.value.ipv6_enabled ? 56 : null
  ipv6_ra_enable      = each.value.ipv6_enabled ? true : null

  for_each = local.networks
}

resource "unifi_wlan" "wlan" {
  name       = each.value.wifi.ssid
  security   = "wpapsk"
  passphrase = each.value.wifi.passphrase
  network_id = unifi_network.network[each.key].id

  wlan_band         = each.value.wifi.band
  ap_group_ids      = [data.unifi_ap_group.default.id]
  user_group_id     = unifi_user_group.default.id
  multicast_enhance = true
  no2ghz_oui        = false
  hide_ssid         = each.value.wifi.hide_ssid
  is_guest          = each.value.purpose == "guest"

  for_each = local.networks
}
