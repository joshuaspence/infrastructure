locals {
  port_profiles = merge(
    { for key, value in data.unifi_port_profile.network : "${key}_network" => value },
    {
      all      = data.unifi_port_profile.all
      disabled = data.unifi_port_profile.disabled
    },
  )
}

data "unifi_port_profile" "all" {
  name = "All"
}

data "unifi_port_profile" "disabled" {
  name = "Disabled"
}

data "unifi_port_profile" "network" {
  name     = unifi_network.network[each.key].name
  for_each = local.networks
}
