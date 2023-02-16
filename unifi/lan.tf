resource "unifi_network" "network" {
  name    = each.value.name
  purpose = each.value.purpose

  network_group = "LAN"
  vlan_id       = each.value.vlan
  subnet        = each.value.subnet
  domain_name   = each.value.domain_name
  igmp_snooping = true

  dhcp_enabled = true
  dhcp_start   = cidrhost(each.value.subnet, 6)
  dhcp_stop    = cidrhost(each.value.subnet, -2)

  dhcp_v6_enabled = true
  dhcp_v6_start   = cidrhost(cidrsubnet(var.network_ipv6_subnet, 16, coalesce(each.value.vlan, 1)), 2)
  dhcp_v6_stop    = cidrhost(cidrsubnet(var.network_ipv6_subnet, 16, coalesce(each.value.vlan, 1)), 2001)

  # TODO: Set `ipv6_interface_type` to `pd`.
  ipv6_interface_type = "static"
  ipv6_static_subnet  = cidrsubnet(var.network_ipv6_subnet, 16, coalesce(each.value.vlan, 1))
  ipv6_ra_enable      = true
  ipv6_ra_priority    = "high"

  lifecycle {
    ignore_changes = [ipv6_pd_start, ipv6_pd_stop]
  }

  for_each = var.networks
}

# TODO: Maybe enable fast roaming.
# TODO: Tweak other settings.
# TODO: Enable BSS transition.
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
  l2_isolation      = each.value.purpose == "guest"

  wpa3_support = each.value.wifi.security == "wpa3"
  pmf_mode     = each.value.wifi.security == "wpa3" ? "required" : "disabled"

  lifecycle {
    ignore_changes = [minimum_data_rate_2g_kbps, radius_profile_id]
  }

  for_each = { for network_name, network in var.networks : network_name => network if network.wifi != null }
}
