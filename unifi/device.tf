// TODO: Manage radio configuration (Config > Radios)
// TODO: Configure band steering (Config > Band steering)
resource "unifi_device" "access_point" {
  name = format("%s Access Point", title(each.key))
  mac  = each.value

  for_each = var.access_points
}

locals {
  client_switch_ports = { for key, client in var.clients : client.switch_port.number => merge(client.switch_port, { name = unifi_user.client[key].name }) if client.switch_port != null }
  device_switch_ports = { for switch_port in var.switch_ports : switch_port.number => switch_port }

  switch_ports = merge(
    { for port in range(1, 24) : port => { name = null, profile = "disabled" } },
    { for switch_port in var.switch_ports : switch_port.number => switch_port },
    { for key, client in var.clients : client.switch_port.number => merge(client.switch_port, { name = unifi_user.client[key].name }) if client.switch_port != null },
  )
}

// TODO: Manage VLAN config (Config > Services > VLAN)
// TODO: Configure network (Config > Network)
resource "unifi_device" "switch" {
  name = "Switch"

  dynamic "port_override" {
    for_each = local.switch_ports
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
    port_profile_id = data.unifi_port_profile.all.id
  }
}
