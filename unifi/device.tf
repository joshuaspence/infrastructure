// TODO: Manage radio configuration (Config > Radios)
// TODO: Configure band steering (Config > Band steering)
resource "unifi_device" "access_point" {
  name = format("%s Access Point", title(each.key))
  mac  = each.value

  for_each = var.access_points
}

// TODO: Disable unused ports.
// TODO: Manage VLAN config (Config > Services > VLAN)
// TODO: Configure network (Config > Network)
resource "unifi_device" "switch" {
  name = "Switch"

  dynamic "port_override" {
    for_each = { for key, client in var.clients : client.switch_port.number => merge(client.switch_port, { name = unifi_user.client[key].name }) if client.switch_port != null }
    iterator = port

    content {
      name            = port.value.name
      number          = port.key
      port_profile_id = port.value.profile != null ? local.port_profiles[port.value.profile].id : null
    }
  }

  port_override {
    number          = 25
    port_profile_id = data.unifi_port_profile.all.id
  }

  port_override {
    number          = 26
    port_profile_id = data.unifi_port_profile.disabled.id
  }
}
