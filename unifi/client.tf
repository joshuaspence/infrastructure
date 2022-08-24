# TODO: Also manage devices.
resource "unifi_user" "client" {
  mac  = each.value.mac
  name = coalesce(each.value.name, title(replace(each.key, "_", " ")))
  note = each.value.note

  network_id = each.value.network != null ? unifi_network.network[each.value.network].id : null
  fixed_ip   = each.value.fixed_ip

  dev_id_override = each.value.device_fingerprint_id

  for_each = var.clients
}

output "dns_records" {
  value = {
    home_assistant = unifi_user.client["home_assistant"].fixed_ip
    unifi_network  = unifi_user.client["unifi_network_controller"].fixed_ip
    unifi_protect  = unifi_user.client["unifi_protect_nvr"].fixed_ip
  }
}
