/**
 * TODO: There are a lot of extra settings available in the UI.
 */

data "unifi_ap_group" "default" {}

variable "home_wifi" {
  type = object({
    main = object({
      ssid       = string
      passphrase = string
    })

    iot = object({
      ssid       = string
      passphrase = string
    })

    not = object({
      ssid       = string
      passphrase = string
    })
  })
}


resource "unifi_wlan" "main" {
  name          = var.home_wifi.main.ssid
  security      = "wpapsk"
  passphrase    = var.home_wifi.main.passphrase
  network_id    = unifi_network.main.id
  ap_group_ids  = [data.unifi_ap_group.default.id]
  user_group_id = unifi_user_group.default.id
}

resource "unifi_wlan" "iot" {
  name          = var.home_wifi.iot.ssid
  security      = "wpapsk"
  passphrase    = var.home_wifi.iot.passphrase
  network_id    = unifi_network.iot.id
  ap_group_ids  = [data.unifi_ap_group.default.id]
  user_group_id = unifi_user_group.default.id
}

resource "unifi_wlan" "not" {
  name          = var.home_wifi.not.ssid
  security      = "wpapsk"
  passphrase    = var.home_wifi.not.passphrase
  network_id    = unifi_network.not.id
  ap_group_ids  = [data.unifi_ap_group.default.id]
  user_group_id = unifi_user_group.default.id
}
