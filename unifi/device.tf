resource "unifi_device" "access_point" {
  name = format("%s Access Point", title(replace(each.key, "_", " ")))
  mac  = each.value.mac

  dynamic "port_override" {
    for_each = {
      for idx in range(1, each.value.ports + 1) : idx => {
        name = null
      }
    }

    content {
      name   = port_override.value.name
      number = port_override.key
    }
  }

  for_each = var.access_points
}

resource "unifi_device" "switch" {
  name = each.value.name == null ? format("%s Switch", title(replace(each.key, "_", " "))) : each.value.name

  dynamic "port_override" {
    for_each = {
      for idx in range(1, each.value.ports + 1) : idx => {
        name    = try(each.value.port_overrides[idx].name, null)
        op_mode = try(each.value.port_overrides[idx].op_mode, null)
      }
    }

    content {
      name    = port_override.value.name
      number  = port_override.key
      op_mode = port_override.value.op_mode
    }
  }

  for_each = var.switches
}
