resource "unifi_network" "network" {
  name        = each.value.name
  vlan        = each.value.vlan
  subnet      = each.value.subnet
  domain_name = each.value.domain_name

  auto_scale         = false
  multicast_dns      = true
  setting_preference = "manual"

  dhcp_server = {
    enabled = true
    start   = cidrhost(each.value.subnet, 6)
    stop    = cidrhost(each.value.subnet, -2)
  }

  ipv6_interface_type = "pd"
  ipv6_pd_interface   = "wan"

  for_each = var.networks
}

resource "unifi_wlan" "wlan" {
  name       = each.value.wifi.ssid
  security   = "wpapsk"
  passphrase = each.value.wifi.passphrase
  network_id = unifi_network.network[each.key].id

  wlan_band            = each.value.wifi.bands != null ? (length(each.value.wifi.bands) > 1 ? "both" : one(tolist(each.value.wifi.bands))) : null
  wlan_bands           = each.value.wifi.bands
  ap_group_ids         = [data.unifi_ap_group.default.id]
  user_group_id        = data.unifi_client_qos_rate.default.id
  multicast_enhance    = true
  no2ghz_oui           = false
  hide_ssid            = each.value.wifi.hide_ssid
  is_guest             = each.value.purpose == "guest"
  l2_isolation         = each.value.purpose == "guest"
  fast_roaming_enabled = each.value.wifi.fast_roaming
  enhanced_iot         = each.value.wifi.enhanced_iot
  group_rekey          = !each.value.wifi.enhanced_iot ? 3600 : 0

  wpa3_support   = each.value.wifi.security == "wpa3"
  pmf_mode       = each.value.wifi.security == "wpa3" ? "required" : "disabled"
  bss_transition = each.value.wifi.bss_transition

  for_each = { for network_name, network in var.networks : network_name => network if network.wifi != null }
}
