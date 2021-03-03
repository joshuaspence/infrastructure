resource "unifi_site" "default" {
  description = "Home"
}

data "unifi_ap_group" "default" {}

resource "unifi_user_group" "default" {
  name = "Default"
}


#===============================================================================
# WAN network
#===============================================================================

resource "unifi_network" "wan" {
  name    = "WAN"
  purpose = "wan"

  wan_networkgroup = "WAN"
  wan_type         = "dhcp"

  # TODO: Remove this after https://github.com/paultyng/terraform-provider-unifi/issues/107.
  lifecycle {
    ignore_changes = [dhcp_lease, ipv6_interface_type, network_group, wan_ip]
  }
}


#===============================================================================
# LAN networks
#===============================================================================

variable "home_networks" {
  type = object({
    main = object({
      subnet = string
      vlan   = number
    })

    iot = object({
      subnet = string
      vlan   = number
    })

    not = object({
      subnet = string
      vlan   = number
    })
  })
}

resource "unifi_network" "main" {
  name    = "LAN"
  purpose = "corporate"

  network_group = "LAN"
  vlan_id       = var.home_networks.main.vlan
  subnet        = var.home_networks.main.subnet

  domain_name  = "local"
  dhcp_enabled = true
  dhcp_start   = cidrhost(var.home_networks.main.subnet, 6)
  dhcp_stop    = cidrhost(var.home_networks.main.subnet, -2)
}

resource "unifi_network" "iot" {
  name    = "IoT"
  purpose = "corporate"

  network_group = "LAN"
  vlan_id       = var.home_networks.iot.vlan
  subnet        = var.home_networks.iot.subnet

  domain_name  = "local"
  dhcp_enabled = true
  dhcp_start   = cidrhost(var.home_networks.iot.subnet, 6)
  dhcp_stop    = cidrhost(var.home_networks.iot.subnet, -2)
}

resource "unifi_network" "not" {
  name    = "NoT"
  purpose = "corporate"

  network_group = "LAN"
  vlan_id       = var.home_networks.not.vlan
  subnet        = var.home_networks.not.subnet

  domain_name  = "local"
  dhcp_enabled = true
  dhcp_start   = cidrhost(var.home_networks.not.subnet, 6)
  dhcp_stop    = cidrhost(var.home_networks.not.subnet, -2)
}


#===============================================================================
# WLAN networks
#===============================================================================

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
  name       = var.home_wifi.main.ssid
  security   = "wpapsk"
  passphrase = var.home_wifi.main.passphrase

  network_id    = unifi_network.main.id
  ap_group_ids  = [data.unifi_ap_group.default.id]
  user_group_id = unifi_user_group.default.id
}

resource "unifi_wlan" "iot" {
  name       = var.home_wifi.iot.ssid
  security   = "wpapsk"
  passphrase = var.home_wifi.iot.passphrase

  network_id    = unifi_network.iot.id
  ap_group_ids  = [data.unifi_ap_group.default.id]
  user_group_id = unifi_user_group.default.id
}

resource "unifi_wlan" "not" {
  name       = var.home_wifi.not.ssid
  security   = "wpapsk"
  passphrase = var.home_wifi.not.passphrase

  network_id    = unifi_network.not.id
  ap_group_ids  = [data.unifi_ap_group.default.id]
  user_group_id = unifi_user_group.default.id
}
