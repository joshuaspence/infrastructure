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





variable "unifi_users" {
  type = map(object({
    mac      = string
    name     = string
    note     = optional(string)
    network  = optional(string)
    fixed_ip = optional(string)
  }))
}

locals {
  network_ids = {
    main = unifi_network.main.id
    iot  = unifi_network.iot.id
    not  = unifi_network.not.id
  }
}

resource "unifi_user" "client" {
  mac  = each.value.mac
  name = each.value.name
  note = each.value.note

  network_id = each.value.network != null ? local.network_ids[each.value.network] : null
  fixed_ip   = each.value.fixed_ip

  for_each = var.unifi_users
}
