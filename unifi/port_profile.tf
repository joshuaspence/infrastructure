locals {
  port_profiles = {
    all          = data.unifi_port_profile.all
    disabled     = data.unifi_port_profile.disabled
    not_network  = unifi_port_profile.not_network
    poe_disabled = unifi_port_profile.poe_disabled
  }
}

data "unifi_port_profile" "all" {
  name = "All"
}

data "unifi_port_profile" "disabled" {
  name = "Disabled"
}

resource "unifi_port_profile" "not_network" {
  name                  = "NoT Network"
  native_networkconf_id = unifi_network.network["not"].id
}

resource "unifi_port_profile" "poe_disabled" {
  name     = "POE Disabled"
  poe_mode = "off"
}
