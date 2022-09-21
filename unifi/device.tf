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
  device_access_point_ports = {
    for key, device in var.access_points : key => {
      for idx in range(1, coalesce(device.ports, 0) + 1) : idx => {
        name    = null
        number  = idx
        profile = "disabled"
      }
    }
  }
}

// TODO: Manage radio configuration (Config > Radios)
// TODO: Configure band steering (Config > Band steering)
resource "unifi_device" "access_point" {
  name = format("%s Access Point", title(each.key))
  mac  = each.value.mac

  dynamic "port_override" {
    for_each = merge(local.device_access_point_ports[each.key], local.client_access_point_ports[each.key])
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
  client_aggregation_switch_ports = {
    for key, client in var.clients : client.uplink.port => {
      name    = unifi_user.client[key].name
      number  = client.uplink.port
      profile = client.uplink.profile
    } if client.uplink != null && try(client.uplink.switch, null) == "aggregation"
  }
  device_aggregation_switch_ports = {
    for key, device in var.access_points : device.uplink.port => {
      name    = unifi_device.access_point[key].name
      number  = device.uplink.port
      profile = device.uplink.profile
    } if device.uplink.switch == "aggregation"
  }

  aggregation_switch_ports = merge(
    { for port in range(1, 9) : port => { name = null, profile = "disabled" } },
    local.client_aggregation_switch_ports,
    local.device_aggregation_switch_ports,
  )
}

resource "unifi_device" "aggregation_switch" {
  name = "Aggregation Switch"

  dynamic "port_override" {
    for_each = local.aggregation_switch_ports
    iterator = port

    content {
      name            = port.value.name
      number          = port.key
      port_profile_id = port.value.profile != null ? local.port_profiles[port.value.profile].id : null
    }
  }

  lifecycle {
    # TODO: Remove this.
    ignore_changes = [port_override]
  }
}

locals {
  client_switch_ports = {
    for key, client in var.clients : client.uplink.port => {
      name    = unifi_user.client[key].name
      number  = client.uplink.port
      profile = client.uplink.profile
    } if client.uplink != null && try(client.uplink.switch, null) == "main"
  }
  device_switch_ports = {
    for key, device in var.access_points : device.uplink.port => {
      name    = unifi_device.access_point[key].name
      number  = device.uplink.port
      profile = null
    } if device.uplink.switch == "main"
  }

  switch_ports = merge(
    { for port in range(1, 25) : port => { name = null, profile = "disabled" } },
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

  # TODO: Port 25-26 should be aggregated.
  port_override {
    number          = 25
    port_profile_id = data.unifi_port_profile.all.id
  }

  port_override {
    number          = 26
    port_profile_id = data.unifi_port_profile.all.id
  }
}
