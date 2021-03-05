resource "unifi_site" "default" {
  description = "Home"
}

resource "unifi_user_group" "default" {
  name = "Default"
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

/**
 * TODO: Manage data from the following API endpoints:
 *
 * - `/api/s/${SITE}/rest/dynamicdns`
 * - `/api/s/${SITE}/rest/routing`
 * - `/api/s/${SITE}/rest/setting`
 * - `/api/s/${SITE}/self`
 * - `/api/s/${SITE}/stat/device` / `/api/s/${SITE}/rest/device/${ID}`
 * - `/api/s/${SITE}/stat/sysinfo`
 */
