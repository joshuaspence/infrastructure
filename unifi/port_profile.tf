locals {
  port_profiles = {
    all              = data.unifi_port_profile.all
    disabled         = data.unifi_port_profile.disabled
    iot_network      = data.unifi_port_profile.iot_network
    not_network      = data.unifi_port_profile.not_network
    security_network = data.unifi_port_profile.security_network
    poe_disabled     = unifi_port_profile.poe_disabled
  }
}

data "unifi_port_profile" "all" {
  name = "All"
}

data "unifi_port_profile" "disabled" {
  name = "Disabled"
}

data "unifi_port_profile" "iot_network" {
  name = unifi_network.network["iot"].name
}

data "unifi_port_profile" "not_network" {
  name = unifi_network.network["not"].name
}

data "unifi_port_profile" "security_network" {
  name = unifi_network.network["security"].name
}

resource "unifi_port_profile" "poe_disabled" {
  name     = "POE Disabled"
  poe_mode = "off"
}
