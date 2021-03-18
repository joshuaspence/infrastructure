locals {
  networks = {
    main = {
      name = "LAN"
    }

    iot = {
      name = "IoT"
    }

    not = {
      name = "NoT"
    }
  }
}

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

  for_each = local.networks
}

resource "unifi_wlan" "wlan" {
  name          = var.wlans[each.key].ssid
  security      = "wpapsk"
  passphrase    = var.wlans[each.key].passphrase
  network_id    = unifi_network.network[each.key].id
  ap_group_ids  = [data.unifi_ap_group.default.id]
  user_group_id = unifi_user_group.default.id

  no2ghz_oui = false
  wlan_band  = "both"

  for_each = local.networks
}
