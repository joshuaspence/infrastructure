locals {
  port_profiles = {
    poe_disabled = unifi_port_profile.poe_disabled
  }
}

resource "unifi_port_profile" "poe_disabled" {
  name     = "POE Disabled"
  poe_mode = "off"
}
