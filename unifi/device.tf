// TODO: Manage radio configuration (Config > Radios)
// TODO: Configure band steering (Config > Band steering)
resource "unifi_device" "access_point" {
  name = format("%s Access Point", title(each.key))
  mac  = each.value

  for_each = var.access_points
}

resource "unifi_device" "gateway" {
  name = "Gateway"

  lifecycle {
    ignore_changes = [port_override]
  }
}

// TODO: Disable unused ports.
// TODO: Manage VLAN config (Config > Services > VLAN)
// TODO: Configure network (Config > Network)
resource "unifi_device" "switch" {
  name = "Switch"

  dynamic "port_override" {
    for_each = { for client in var.clients : client.switch_port.number => client.switch_port if client.switch_port != null }
    iterator = port

    content {
      number          = port.key
      port_profile_id = port.value.profile != null ? local.port_profiles[port.value.profile].id : null
    }
  }
}
