resource "unifi_user" "client" {
  mac  = each.value.mac
  name = coalesce(each.value.name, title(replace(each.key, "_", " ")))
  note = each.value.note

  network_id = each.value.network != null ? unifi_network.network[each.value.network].id : null
  fixed_ip   = each.value.fixed_ip

  for_each = var.clients
}
