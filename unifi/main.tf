resource "unifi_site" "default" {
  description = "Home"
}

resource "unifi_user_group" "default" {
  name = "Default"
}

locals {
  unifi_networks = {
    main = unifi_network.main
    iot  = unifi_network.iot
    not  = unifi_network.not
  }
}

resource "unifi_user" "client" {
  mac  = each.value.mac
  name = coalesce(each.value.name, title(replace(each.key, "_", " ")))
  note = each.value.note

  network_id = each.value.network != null ? local.unifi_networks[each.value.network].id : null
  fixed_ip   = each.value.fixed_ip

  for_each = var.clients
}