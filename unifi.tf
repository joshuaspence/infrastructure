resource "unifi_site" "default" {
  description = "Home"
}

data "unifi_ap_group" "default" {}

resource "unifi_user_group" "default" {
  name = "Default"
}

resource "unifi_network" "wan" {
  name    = "WAN"
  purpose = "wan"

  wan_networkgroup = "WAN"
  wan_type         = "dhcp"

  # TODO: Remove this after https://github.com/paultyng/terraform-provider-unifi/issues/107.
  lifecycle {
    ignore_changes = [dhcp_lease, ipv6_interface_type, network_group, wan_ip]
  }
}





variable "unifi_clients" {
  type = map(object({
    mac  = string
    name = optional(string)
    note = optional(string)

    network  = optional(string)
    fixed_ip = optional(string)
  }))
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

  for_each = var.unifi_clients
}
