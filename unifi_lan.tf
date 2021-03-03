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
