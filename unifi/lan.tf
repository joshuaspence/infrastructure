resource "unifi_network" "main" {
  name    = "LAN"
  purpose = "corporate"

  network_group = "LAN"
  vlan_id       = var.networks.main.vlan
  subnet        = var.networks.main.subnet
  domain_name   = "local"
  dhcp_enabled  = true
  dhcp_start    = cidrhost(var.networks.main.subnet, 6)
  dhcp_stop     = cidrhost(var.networks.main.subnet, -2)
}

resource "unifi_network" "iot" {
  name    = "IoT"
  purpose = "corporate"

  network_group = "LAN"
  vlan_id       = var.networks.iot.vlan
  subnet        = var.networks.iot.subnet
  domain_name   = "local"
  dhcp_enabled  = true
  dhcp_start    = cidrhost(var.networks.iot.subnet, 6)
  dhcp_stop     = cidrhost(var.networks.iot.subnet, -2)
}

resource "unifi_network" "not" {
  name    = "NoT"
  purpose = "corporate"

  network_group = "LAN"
  vlan_id       = var.networks.not.vlan
  subnet        = var.networks.not.subnet
  domain_name   = "local"
  dhcp_enabled  = true
  dhcp_start    = cidrhost(var.networks.not.subnet, 6)
  dhcp_stop     = cidrhost(var.networks.not.subnet, -2)
}
