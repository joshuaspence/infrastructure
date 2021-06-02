resource "unifi_device" "access_point" {
  name = format("%s Access Point", title(each.key))
  mac  = each.value

  for_each = var.access_points
}

resource "unifi_device" "gateway" {
  name = "Gateway"
}

resource "unifi_device" "switch" {
  name = "Switch"

  # TODO: Move this to a variable.
  port_override {
    number          = 1
    port_profile_id = unifi_port_profile.poe_disabled.id
  }

  port_override {
    number          = 2
    port_profile_id = unifi_port_profile.poe_disabled.id
  }

  port_override {
    number          = 3
    port_profile_id = unifi_port_profile.poe_disabled.id
  }
}

resource "unifi_port_profile" "poe_disabled" {
  name     = "POE Disabled"
  poe_mode = "off"
}
