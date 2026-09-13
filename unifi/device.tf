locals {
  # A port with a client uplink takes that client's network as its native VLAN, so the
  # VLAN comes from the port rather than from a per-client override. Ports with no
  # declared uplink are left alone -- this manages the ports we know about, not every
  # port on the device.
  #
  # `client_networks` maps a network to null when it has no VLAN, which is how the
  # default network is handled (the controller rejects overrides on it). Ports on such
  # a network therefore resolve to null and stay unmanaged, same as an unknown port.
  access_point_port_networks = {
    for key, access_point in var.access_points : key => {
      for name, client in var.clients : client.uplink.port => client.uplink.network
      if try(client.uplink.access_point, null) == key && try(client.uplink.network, null) != null
    }
  }

  switch_port_networks = {
    for key, switch in var.switches : key => {
      for name, client in var.clients : client.uplink.port => client.uplink.network
      if try(client.uplink.switch, null) == key && try(client.uplink.network, null) != null
    }
  }

}

resource "unifi_device" "access_point" {
  name = format("%s Access Point", title(replace(each.key, "_", " ")))
  mac  = each.value.mac

  dynamic "port_override" {
    for_each = {
      for idx in range(1, each.value.ports + 1) : idx => {
        name       = null
        network_id = try(local.client_networks[local.access_point_port_networks[each.key][idx]], null)
      }
    }

    content {
      name                  = port_override.value.name
      index                 = port_override.key
      native_networkconf_id = port_override.value.network_id
      setting_preference    = port_override.value.network_id != null ? "manual" : null
    }
  }

  for_each = var.access_points
}

resource "unifi_device" "switch" {
  name = each.value.name == null ? format("%s Switch", title(replace(each.key, "_", " "))) : each.value.name

  dynamic "port_override" {
    for_each = {
      for idx in range(1, each.value.ports + 1) : idx => {
        name              = try(each.value.port_overrides[idx].name, null)
        op_mode           = try(each.value.port_overrides[idx].op_mode, null)
        aggregate_members = try(each.value.port_overrides[idx].aggregate_members, null)
        network_id        = try(local.client_networks[local.switch_port_networks[each.key][idx]], null)
      }
    }

    content {
      name                  = port_override.value.name
      index                 = port_override.key
      op_mode               = port_override.value.op_mode
      aggregate_members     = port_override.value.aggregate_members
      native_networkconf_id = port_override.value.network_id
      setting_preference    = port_override.value.network_id != null ? "manual" : null
    }
  }

  for_each = var.switches
}
