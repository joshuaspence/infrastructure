locals {
  access_point_ports = {
    for key, device in var.access_points : key => merge(
      {
        for idx in range(1, device.ports + 1) : idx => {
          name    = null
          profile = "disabled"
        }
      },
      {
        for client_key, client in var.clients : client.uplink.port => {
          name    = unifi_user.client[client_key].name
          profile = client.uplink.profile
        } if try(client.uplink.access_point, null) == key
      },
    )
  }
}

resource "unifi_device" "access_point" {
  name = format("%s Access Point", title(replace(each.key, "_", " ")))
  mac  = each.value.mac

  dynamic "port_override" {
    for_each = local.access_point_ports[each.key]
    iterator = port

    content {
      name   = port.value.name
      number = port.key
    }
  }

  for_each = var.access_points
}

locals {
  switch_ports = {
    for key, device in var.switches : key => merge(
      {
        for idx in range(1, device.ports + 1) : idx => {
          name                = null
          profile             = "disabled"
          op_mode             = null
          aggregate_num_ports = null
        }
      },
      {
        for idx, port in device.port_overrides : idx => port
      },
      {
        for client_key, client in var.clients : client.uplink.port => {
          name                = unifi_user.client[client_key].name
          profile             = client.uplink.profile
          op_mode             = null
          aggregate_num_ports = null
        } if try(client.uplink.switch, null) == key
      },
      {
        for device_key, device in var.access_points : device.uplink.port => {
          name                = unifi_device.access_point[device_key].name
          profile             = "all"
          op_mode             = null
          aggregate_num_ports = null
        } if device.uplink.switch == key
      },
    )
  }
}

resource "unifi_device" "switch" {
  name = each.value.name == null ? format("%s Switch", title(replace(each.key, "_", " "))) : each.value.name

  dynamic "port_override" {
    for_each = local.switch_ports[each.key]
    iterator = port

    content {
      name                = port.value.name
      number              = port.key
      op_mode             = port.value.op_mode
      aggregate_num_ports = port.value.aggregate_num_ports
    }
  }

  for_each = var.switches
}
