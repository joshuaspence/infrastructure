locals {
  client_access_point_ports = {
    for key, device in var.access_points : key => {
      for client_key, client in var.clients : client.uplink.port => {
        name    = unifi_user.client[client_key].name
        number  = client.uplink.port
        profile = client.uplink.profile
      } if client.uplink != null && try(client.uplink.access_point, null) == key
    }
  }
}

// TODO: Manage radio configuration (Config > Radios)
// TODO: Configure band steering (Config > Band steering)
resource "unifi_device" "access_point" {
  name = format("%s Access Point", title(each.key))
  mac  = each.value.mac

  dynamic "port_override" {
    for_each = merge({ for port in each.value.ports : port.number => port }, local.client_access_point_ports[each.key])
    iterator = port

    content {
      name            = port.value.name
      number          = port.key
      port_profile_id = port.value.profile != null ? local.port_profiles[port.value.profile].id : null
    }
  }

  for_each = var.access_points
}

locals {
  client_switch_ports = {
    for key, client in var.clients : client.uplink.port => {
      name    = unifi_user.client[key].name
      number  = client.uplink.port
      profile = client.uplink.profile
    } if client.uplink != null && try(client.uplink.access_point, null) == null
  }
  device_switch_ports = {
    for key, device in var.access_points : device.uplink.port => {
      name    = unifi_device.access_point[key].name
      number  = device.uplink.port
      profile = device.uplink.profile
    }
  }

  switch_ports = merge(
    { for port in range(1, 24) : port => { name = null, profile = "disabled" } },
    { for switch_port in var.switch_ports : switch_port.number => switch_port },
    local.client_switch_ports,
    local.device_switch_ports,
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
