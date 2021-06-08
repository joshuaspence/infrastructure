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

  dynamic "port_override" {
    for_each = var.switch_port_overrides
    iterator = port

    content {
      number          = port.key
      name            = port.value.name
      port_profile_id = port.value.profile != null ? local.port_profiles[port.value.profile].id : null
    }
  }
}
