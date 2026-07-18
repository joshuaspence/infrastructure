resource "unifi_network" "network" {
  name        = each.value.name
  vlan        = each.value.vlan
  subnet      = each.value.subnet
  domain_name = each.value.domain_name

  auto_scale         = false
  igmp_snooping      = true
  multicast_dns      = true
  setting_preference = "manual"

  dhcp_server = {
    enabled = true
    start   = cidrhost(each.value.subnet, 6)
    stop    = cidrhost(each.value.subnet, -2)
  }

  ipv6_interface_type = "pd"

  lifecycle {
    ignore_changes = [
      # TODO
      igmp_snooping,
      ipv6_interface_type,
      lte_lan,
      dhcp_server,
    ]
  }

  for_each = var.networks
}

resource "unifi_wlan" "wlan" {
  name       = each.value.wifi.ssid
  security   = "wpapsk"
  passphrase = each.value.wifi.passphrase
  network_id = unifi_network.network[each.key].id

  wlan_band            = each.value.wifi.band
  ap_group_ids         = [data.unifi_ap_group.default.id]
  user_group_id        = data.unifi_client_qos_rate.default.id
  multicast_enhance    = true
  no2ghz_oui           = false
  hide_ssid            = each.value.wifi.hide_ssid
  is_guest             = each.value.purpose == "guest"
  l2_isolation         = each.value.purpose == "guest"
  fast_roaming_enabled = each.value.wifi.fast_roaming

  wpa3_support   = each.value.wifi.security == "wpa3"
  pmf_mode       = each.value.wifi.security == "wpa3" ? "required" : "disabled"
  bss_transition = each.value.wifi.bss_transition

  lifecycle {
    ignore_changes = [minimum_data_rate_2g_kbps, radius_profile_id, mac_filter, minimum_data_rate_5g_kbps]
  }

  for_each = { for network_name, network in var.networks : network_name => network if network.wifi != null }
}
