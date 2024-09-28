# TODO: Also manage devices.
resource "unifi_user" "client" {
  mac  = each.value.mac
  name = each.value.name == null ? title(replace(each.key, "_", " ")) : each.value.name
  note = each.value.note

  network_id       = each.value.network != null ? unifi_network.network[each.value.network].id : null
  fixed_ip         = each.value.fixed_ip
  local_dns_record = each.value.dns_record

  dev_id_override = each.value.device_fingerprint_id

  for_each = var.clients
}

output "dns_records" {
  value = {
    homeassistant = unifi_user.client["home_assistant"].fixed_ip
    octoprint     = unifi_user.client["octoprint"].fixed_ip
    protect       = unifi_user.client["unifi_protect_nvr"].fixed_ip
    unifi         = unifi_user.client["unifi_network_controller"].fixed_ip
  }
}
