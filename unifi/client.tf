locals {
  # We can't override network to the ID of the default network. Attempting to do so fails with 
  # `VirtualNetworkOverrideUnsupportedForDefaultNetwork`.
  client_networks = {
    for name, network in unifi_network.network : name => network.vlan == null ? null : network.id
  }
}

# TODO: Also manage devices.
resource "unifi_client" "client" {
  mac  = each.value.mac
  name = each.value.name == null ? title(replace(each.key, "_", " ")) : each.value.name
  note = each.value.note

  network_id       = each.value.network != null ? local.client_networks[each.value.network] : null
  fixed_ip         = each.value.fixed_ip
  local_dns_record = each.value.dns_record

  for_each = var.clients
}
