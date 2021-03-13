data "unifi_ap_group" "default" {}

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

resource "unifi_wlan" "iot" {
  name          = var.wlans.iot.ssid
  security      = "wpapsk"
  passphrase    = var.wlans.iot.passphrase
  network_id    = unifi_network.iot.id
  ap_group_ids  = [data.unifi_ap_group.default.id]
  user_group_id = unifi_user_group.default.id

  no2ghz_oui = false
  wlan_band  = "both"
}

resource "unifi_wlan" "not" {
  name          = var.wlans.not.ssid
  security      = "wpapsk"
  passphrase    = var.wlans.not.passphrase
  network_id    = unifi_network.not.id
  ap_group_ids  = [data.unifi_ap_group.default.id]
  user_group_id = unifi_user_group.default.id

  no2ghz_oui = false
  wlan_band  = "both"
}
